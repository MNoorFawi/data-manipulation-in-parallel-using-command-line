#!/usr/bin/env bash
# < cities.txt ./temp_fetch.sh <your-api-key>
API_KEY="$1"
tr ' ' '+' | 
parallel -j400% --progress -C, 'curl -s "http://api.openweathermap.org/data/2.5/weather?q={}&appid='$API_KEY'"' | 
jq '{name: .name, temperature: .main.temp}' | 
json2csv | awk -F, '{print $1","$2-273.15}' | 
header -r city,temperature | 
csvsql --query 'SELECT * FROM stdin ORDER BY temperature DESC;' | tee temp.csv | 
head -n 6 | csvlook

# parallel has a --delay argument e.g. --delay 0.5
# extract a value from inside a list within json 
# jq '{name: .name, temperature: .main.temp, weather: .weather[].description}'

