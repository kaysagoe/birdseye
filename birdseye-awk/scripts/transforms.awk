BEGIN {OFS=","} 
$13 == DATE && $4 !~ /.*[Ss]enior.*/ && $4 !~ /.*[Ss]taff.*/ && $4 !~ /.*[Pp]rincipal.*/ && $4 !~ /.*[Ll]ead.*/ && ($4 ~ /.*[Dd]ata [Ee]ngineer.*/ || $4 ~ /.*[Aa]nalytics [Ee]ngineer.*/) { "echo -n " $2 " " $4 " " $6 " " $7 " | sha1sum" | getline hash; split(hash, hash_array, " "); printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n","\"" hash_array[1] "\"",$2,$3,$4,$5,$6,$7,$11,$13,$14,$15,$16,$19,$20 }

