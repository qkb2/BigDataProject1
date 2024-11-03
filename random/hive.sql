CREATE EXTERNAL TABLE actor_counts(
    id STRING,
    actedCount INT,
    directedCount INT
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
    "input.regex" = "([^\\t]+)\\t(\\d+),(\\d+)"
)
STORED AS TEXTFILE
LOCATION 'project/output1';

-- Version for regex
CREATE EXTERNAL TABLE actor_names(
    id STRING, primaryName STRING, birthYear STRING, deathYear STRING, 
    primaryProfession STRING, knownFor STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION 'project/datasource4';

-- Version with arrays
CREATE EXTERNAL TABLE actor_names_array(
    id STRING,
    primaryName STRING,
    birthYear STRING,
    deathYear STRING,
    primaryProfession ARRAY<STRING>,
    knownFor STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
COLLECTION ITEMS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'project/datasource4';

-- Query with regex
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
-- Select the top 3 actors/actresses and directors based on their counts
SELECT primaryName, profession, primaryProfessionGendered, actedCount
FROM RankedActors
WHERE rank <= 3
UNION ALL
SELECT primaryName, profession, primaryProfessionGendered, directedCount
FROM RankedDirectors
WHERE rank <= 3;

-- Version with arrays
WITH RankedActors AS (
    SELECT 
        n.primaryName, 
        CASE 
            WHEN array_contains(n.primaryProfession, 'actor') THEN 'actor' 
            WHEN array_contains(n.primaryProfession, 'actress') THEN 'actress' 
        END AS primaryProfessionGendered,
        'actor/actress' AS profession,
        c.actedCount,
        ROW_NUMBER() OVER (PARTITION BY 'actor/actress' ORDER BY c.actedCount DESC) AS rank
    FROM actor_names_array n
    JOIN actor_counts c ON n.id = c.id
    WHERE array_contains(n.primaryProfession, 'actor') 
       OR array_contains(n.primaryProfession, 'actress')
),
RankedDirectors AS (
    SELECT 
        n.primaryName, 
        'director' AS profession,
        'director' AS primaryProfessionGendered,
        c.directedCount,
        ROW_NUMBER() OVER (PARTITION BY 'director' ORDER BY c.directedCount DESC) AS rank
    FROM actor_names_array n
    JOIN actor_counts c ON n.id = c.id
    WHERE array_contains(n.primaryProfession, 'director')
)
-- Select the top 3 actors/actresses and directors based on their counts
SELECT primaryName, profession, primaryProfessionGendered, actedCount
FROM RankedActors
WHERE rank <= 3
UNION ALL
SELECT primaryName, profession, primaryProfessionGendered, directedCount
FROM RankedDirectors
WHERE rank <= 3;
