-- Parameters for locations
SET actor_counts_location=${actor_counts_location};
SET actor_names_location=${actor_names_location};
SET output_location=${output_location};

-- Create sample actor_counts table with dummy data
CREATE EXTERNAL TABLE IF NOT EXISTS actor_counts(
    id STRING,
    actedCount INT,
    directedCount INT
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '${hiveconf:actor_counts_location}';

-- Insert dummy data into actor_counts
INSERT INTO actor_counts VALUES
('nm0001', 5, 2),
('nm0002', 10, 1),
('nm0003', 3, 8),
('nm0004', 7, 5);

-- Create sample actor_names table with dummy data
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

-- Insert dummy data into actor_names
INSERT INTO actor_names VALUES
('nm0001', 'John Doe', '1970', '2020', 'actor,director', 'tt0001,tt0002'),
('nm0002', 'Jane Smith', '1985', '\\N', 'actress', 'tt0003,tt0004'),
('nm0003', 'Mike Johnson', '1960', '\\N', 'director', 'tt0005,tt0006'),
('nm0004', 'Alice Brown', '1990', '\\N', 'actor,actress', 'tt0007,tt0008');

CREATE EXTERNAL TABLE IF NOT EXISTS outputs(
    name STRING,
    role STRING,
    actedCount INT,
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '${hiveconf:output_location}';

-- CTEs for ranked actors and directors with dummy ranking
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

-- Insert the test data result into JSON format on HDFS
INSERT INTO outputs
SELECT primaryName, primaryProfessionGendered, actedCount
FROM RankedActors
WHERE rank <= 3
UNION ALL
SELECT primaryName, primaryProfessionGendered, directedCount
FROM RankedDirectors
WHERE rank <= 3;
