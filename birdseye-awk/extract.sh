#!bin/bash
# Fetching all the data from the Search API and storing results in different JSON files
curl -s --basic --user $REED_API_KEY: "https://www.reed.co.uk/api/1.0/search?keywords=data%20engineer&locationName=United%20Kingdom&fullTime=true" >  /data/results_0.json

results_count=$(jq '.totalResults' /data/results_0.json)
iter_num=$((results_count / 100))

for i in $(seq 100 100 $((iter_num * 100))); do
    curl -s --basic --user $REED_API_KEY: "https://www.reed.co.uk/api/1.0/search?keywords=data%20engineer&locationName=United%20Kingdom&fullTime=true&resultsToSkip=$((i))" >  /data/results_$((i / 100)).json
    echo "$((i / 100)) out of ${iter_num}"
done

# Combine all the JSON files into a single one
jq -s 'reduce .[].results as $item ([]; . + $item)' $(ls /data/results_*.json) > /data/$(date +"%d-%m-%y").json

rm /data/results_*.json

gsutil cp /data/$(date +"%d-%m-%y").json gs://${BUCKET_NAME}/data_lake/

# Fetch all individual job data and store in CSV
download_count=0
for id in $(jq '.[].jobId' /data/$(date +"%d-%m-%y").json); do
    response=$(curl -s --basic --user $REED_API_KEY: "https://www.reed.co.uk/api/1.0/jobs/${id}")
    if [[ -e /data/$(date +"%d-%m-%y").csv ]]; then
        echo $response | jq -r '. | flatten | map(if . then . else "" end) | @csv' >> /data/$(date +"%d-%m-%y").csv
    else
        echo $response | jq -r '. | keys_unsorted | @csv' > /data/$(date +"%d-%m-%y").csv
        echo $response | jq -r '. | flatten | map(if . then . else "" end) | @csv' >> /data/$(date +"%d-%m-%y").csv
    fi
    download_count=$((download_count + 1))
    echo "${download_count} out of ${results_count}"
done

# Run AWK Transformations on source data 
gawk -v FPAT='(\"[^\"]+\")|([^,]+)' -v DATE=\"$(date --date='yesterday' +"%d/%m/%Y")\" -f /scripts/transforms.awk /data/$(date +"%d-%m-%y").csv > /data/$(date +"%d-%m-%y")_output.csv

if [[ $(cat data/$(date +"%d-%m-%y")_output.csv | wc -l) -eq 0 && $(cat data/$(date +"%d-%m-%y")_output.csv | wc -l) -eq 0 ]]; then
    exit
fi

# Generate SQL statements using AWK and run them using PSQL
gawk -v FPAT='(\"[^\"]+\")|([^,]+)' -v TNR=$(cat data/$(date +"%d-%m-%y")_output.csv  | wc -l) -f /scripts/generate_insert_statements.awk data/$(date +"%d-%m-%y")_output.csv 

# Convert double quotes in SQL scripts to single quotes
tr \" \' < /scripts/insert_employer.sql > /scripts/insert_employer_tr.sql
tr \" \' < /scripts/insert_location.sql > /scripts/insert_location_tr.sql
sed "s/'/''/g" /scripts/insert_job.sql > /scripts/insert_job_sed.sql
tr \" \' < /scripts/insert_job_sed.sql > /scripts/insert_job_tr.sql

# Load data into data warehouse
psql "sslmode=disable dbname=$DB_NAME user=$DB_USER password=$DB_PASS hostaddr=$DB_HOST" -f /scripts/insert_employer_tr.sql
psql "sslmode=disable dbname=$DB_NAME user=$DB_USER password=$DB_PASS hostaddr=$DB_HOST" -f /scripts/insert_location_tr.sql
psql "sslmode=disable dbname=$DB_NAME user=$DB_USER password=$DB_PASS hostaddr=$DB_HOST" -f /scripts/insert_job_tr.sql
