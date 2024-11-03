#!/bin/bash

# Define paths
HADOOP_HOME="/usr/local/hadoop"
INPUT_DIR="../input/datasource1"
OUTPUT_DIR="../output"
MAPPER_SCRIPT="../project_files/mapper2.py"
REDUCER_SCRIPT="../project_files/reducer2.py"
STREAMING_JAR="$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar"

# Remove the output directory if it already exists
rm -rf output

# Run Hadoop streaming
$HADOOP_HOME/bin/hadoop jar $STREAMING_JAR \
    -input $INPUT_DIR \
    -output $OUTPUT_DIR \
    -mapper $MAPPER_SCRIPT \
    -reducer $REDUCER_SCRIPT \
    -combiner $REDUCER_SCRIPT \
    -file $MAPPER_SCRIPT \
    -file $REDUCER_SCRIPT

# Check the job output
if [ $? -eq 0 ]; then
    echo "Hadoop streaming job completed successfully."
else
    echo "Hadoop streaming job failed."
fi