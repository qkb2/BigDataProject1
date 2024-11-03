hadoop fs -mkdir -p table1 table2 output

hive -hiveconf actor_counts_location='table1' \
     -hiveconf actor_names_location='table2' \
     -hiveconf output_location='output' \
     -f test.hql

hadoop fs -copyToLocal output