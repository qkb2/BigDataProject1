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
LOCATION '${hiveconf:actor_counts_location}';

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
LOCATION '${hiveconf:actor_names_location}';

-- Query with CTEs to get top actors and directors
WITH RankedActors AS (
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
    WHERE n.primaryProfession REGEXP '(^|,)actor(,|$)|(^|,)actress(,|$)'
),
RankedDirectors AS (
    SELECT 
        n.primaryName, 
        'director' AS profession,
        'director' AS primaryProfessionGendered,
        c.directedCount,
        ROW_NUMBER() OVER (PARTITION BY 'director' ORDER BY c.directedCount DESC) AS rank
    FROM actor_names n
    JOIN actor_counts c ON n.id = c.id
    WHERE n.primaryProfession REGEXP '(^|,)director(,|$)'
)

-- Generate JSON lines with column names directly from the CTEs
INSERT OVERWRITE DIRECTORY '${hiveconf:output_location}'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\n'
STORED AS TEXTFILE
SELECT 
    CONCAT(
        '{',
        '"name": "', primaryName, '", ',
        '"role": "', primaryProfessionGendered, '", ',
        '"movies": ', CAST(actedCount AS STRING),
        '}'
    )
FROM RankedActors
WHERE rank <= 3
UNION ALL
SELECT 
    CONCAT(
        '{',
        '"name": "', primaryName, '", ',
        '"role": "', primaryProfessionGendered, '", ',
        '"movies": ', CAST(directedCount AS STRING),
        '}'
    )
FROM RankedDirectors
WHERE rank <= 3;