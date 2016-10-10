#!/bin/bash
# bash command-line arguments are accessible as $0 (the bash script), $1, etc.
# echo "Running" $0 "on" $1
printf "title,author,release_date,ebook_id,language,body\r\n" > ebook.csv
printf "ebook_id,token\r\n" > tokens.csv
printf "token,count\r\n" > token_counts.csv
printf "token,count\r\n" > name_counts.csv

python parse_input.py $1 2> \
  >(tee -a tokens.csv | \
      cut -d',' -f2 | \
      sort | \
      uniq -c | \
      sed -e 's/[[:space:]]*\([[:digit:]]\+\)[[:space:]]*\([[:alpha:]]\+\)/\2,\1/g' | \
      tee -a token_counts.csv | \
      python check_membership.py popular_names.txt >> name_counts.csv \
  ) >> ebook.csv
# "^($(tr '[:upper:]' '[:lower:]' < popular_names.txt | awk '{ print "(" $1 ")"}' | paste -s -d '|' -)),[0-9]+$"

exit 0