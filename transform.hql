-- Parameters for locations
SET actor_counts_location=${actor_counts_location};
SET actor_names_location=${actor_names_location};
SET output_location=${output_location};

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

-- Export the result to HDFS in JSON format
INSERT OVERWRITE DIRECTORY '${hiveconf:output_location}'
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
SELECT primaryName, primaryProfessionGendered, actedCount
FROM RankedActors
WHERE rank <= 3
UNION ALL
SELECT primaryName, primaryProfessionGendered, directedCount
FROM RankedDirectors
WHERE rank <= 3;
