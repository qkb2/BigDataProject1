CREATE EXTERNAL TABLE actor_counts(
    id STRING, actedCount INT, directedCount INT
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
    WITH SERDEPROPERTIES (
        "input.regex" = "([^\\t]+)\\t([^,]+),([^]+)"
    )
STORED AS TEXTFILE
LOCATION 'input_dir3';

CREATE EXTERNAL TABLE actor_names(
    id STRING, primaryName STRING, birthYear STRING, deathYear STRING, 
    primaryProfession STRING, knownFor STRING
)
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION 'input_dir4';

CREATE table actors_orc(
    id STRING, primaryName STRING, primaryProfession STRING, actedCount INT, directedCount INT
)
CLUSTERED BY id SORTED BY primaryProfession INTO 32 BUCKETS
STORED AS ORC;

INSERT OVERWRITE TABLE actors_orc
SELECT id, primaryName, primaryProfession, actedCount, directedCount FROM actor_names A
JOIN acted_count B ON A.id = B.id
WHERE primaryProfession IN ('actor', 'actress', 'director');

SELECT primaryName, primaryProfession, actedCount FROM actors_orc
WHERE primaryProfession IN ('actor', 'actress')
ORDER BY actedCount DESC LIMIT 3;

SELECT primaryName, primaryProfession, directedCount FROM actors_orc
WHERE primaryProfession IN ('director')
ORDER BY directedCount DESC LIMIT 3;