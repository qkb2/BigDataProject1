-- Parameters for locations
SET actor_counts_location=${input_dir3};
SET actor_names_location=${input_dir4};
SET output_location=${output_dir6};

-- External table definitions
CREATE EXTERNAL TABLE IF NOT EXISTS actor_counts(
    id STRING,
    actedCount INT,
    directedCount INT
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
    "input.regex" = "([^\\t]+)\\t(\\d+),(\\d+)"
)
STORED AS TEXTFILE
LOCATION '${actor_counts_location}';

CREATE EXTERNAL TABLE IF NOT EXISTS actor_names(
    id STRING, 
    primaryName STRING, 
    birthYear STRING, 
    deathYear STRING, 
    primaryProfession STRING, 
    knownFor STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '${actor_names_location}';

-- Step 1: Create a view to rank actors and actresses
CREATE VIEW RankedActors AS
SELECT 
    n.primaryName, 
    CASE 
        WHEN n.primaryProfession REGEXP '(^|,)actor(,|$)' THEN 'actor' 
        WHEN n.primaryProfession REGEXP '(^|,)actress(,|$)' THEN 'actress' 
    END AS primaryProfessionGendered,
    'actor/actress' AS profession,
    c.actedCount,
    ROW_NUMBER() OVER (PARTITION BY 'actor/actress' ORDER BY c.actedCount DESC) AS rank
FROM actor_names n
JOIN actor_counts c ON n.id = c.id
WHERE n.primaryProfession REGEXP '(^|,)actor(,|$)|(^|,)actress(,|$)';

-- Step 2: Create a view to rank directors
CREATE VIEW RankedDirectors AS
SELECT 
    n.primaryName, 
    'director' AS profession,
    'director' AS primaryProfessionGendered,
    c.directedCount,
    ROW_NUMBER() OVER (PARTITION BY 'director' ORDER BY c.directedCount DESC) AS rank
FROM actor_names n
JOIN actor_counts c ON n.id = c.id
WHERE n.primaryProfession REGEXP '(^|,)director(,|$)';

-- Step 3: Output JSON lines with top-ranked actors/actresses and directors
CREATE TABLE combined_results AS
SELECT CONCAT(
        '{',
        '"name": "', primaryName, '", ',
        '"role": "', primaryProfessionGendered, '", ',
        '"movies": ', CAST(actedCount AS STRING),
        '}'
    ) as jsonl
FROM RankedActors
WHERE rank <= 3

UNION ALL

SELECT CONCAT(
        '{',
        '"name": "', primaryName, '", ',
        '"role": "', primaryProfessionGendered, '", ',
        '"movies": ', CAST(directedCount AS STRING),
        '}'
    ) as jsonl
FROM RankedDirectors
WHERE rank <= 3;

INSERT OVERWRITE DIRECTORY '${output_location}'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\n'
STORED AS TEXTFILE
SELECT * FROM combined_results;