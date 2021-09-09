BEGIN {print "INSERT INTO employer (name) VALUES " > "/scripts/insert_employer.sql"}
NR < TNR {printf "(%s),",$2 >> "/scripts/insert_employer.sql"}
NR == TNR || TNR == 0 {printf "(%s)",$2 >> "/scripts/insert_employer.sql"}
END {print " ON CONFLICT (name) DO NOTHING;" >> "/scripts/insert_employer.sql"}

BEGIN {print "INSERT INTO location (description) VALUES " > "/scripts/insert_location.sql"}
NR < TNR {printf "(%s),",$5 >> "/scripts/insert_location.sql"}
NR == TNR || TNR == 0 {printf "(%s)",$5 >> "/scripts/insert_location.sql"}
END {print " ON CONFLICT (description) DO NOTHING;" >> "/scripts/insert_location.sql"}

BEGIN {print "SET datestyle = dmy;\nINSERT INTO job SELECT hash, new_jobs.id, title, new_jobs.description, min_salary::numeric(8,2), max_salary::numeric(8,2), date::date, expiration_date::date, external_url, url, employer.id, location.id, salary_type.id, contract_type.id FROM (VALUES " > "/scripts/insert_job.sql"}
$6 == "\"\"" {$6 = "NULL"}
$7 == "\"\"" {$7 = "NULL"}
$10 == "\"\"" {$10 = "NULL"}
$11 == "\"\"" {$11 = "NULL"}q
NR < TNR {printf "(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s),",$1,$3,$4,$14,$6,$7,$9,$10,$11,$12,$2,$5,$8,$13 >> "/scripts/insert_job.sql"}
NR == TNR || TNR == 0{printf "(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",$1,$3,$4,$14,$6,$7,$9,$10,$11,$12,$2,$5,$8,$13 >> "/scripts/insert_job.sql"}
END {print " ) AS new_jobs (hash, id, title, description, min_salary, max_salary, date, expiration_date, external_url, url, employer, location, salary_type, contract_type) INNER JOIN employer ON new_jobs.employer=employer.name INNER JOIN location ON new_jobs.location=location.description INNER JOIN salary_type ON new_jobs.salary_type=salary_type.description INNER JOIN contract_type ON new_jobs.contract_type=contract_type.description ON CONFLICT (hash) DO NOTHING;" >> "/scripts/insert_job.sql"}