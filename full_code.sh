< cities.txt tr ' ' '+' | 
parallel -j400% --progress -C, 'curl -s "http://api.openweathermap.org/data/2.5/weather?q={}&appid=<your-api-key>"' | 
jq '{name: .name, temperature: .main.temp}' | 
json2csv | awk -F, '{print $1","$2-273.15}' | 
header -r city,temperature | 
csvsql --query 'SELECT * FROM stdin ORDER BY temperature DESC;' > temp.csv 

