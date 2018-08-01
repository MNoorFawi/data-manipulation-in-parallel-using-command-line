importing and cleaning data in parallel with command line
================

Importing data from APIs sometimes isn't easy especially when we want to import so much data, as we'll have to make so many requests to the API. This can take so much time if we do it sequentially. In such cases, going parallel is of great help.

##### Parallelism is about distributing all the processes to be executed over the CPU cores in order for them to be executed simultaneously.

Data Parallelism is a great technique in data science problems as it helps save great amount of time when it comes to executing commands over so large data.

Here we're going to explore how we can connect to a web API and importing data in parallel and cleaning it and writing it to disk using the **COMMAND LINE**

**I personally love the Command Line, it is not only so efficient, using it is so much fun and it is able to do magic work.**

We're going to get the temperature of som capitals around the whole world using the **Open Weather Map API** <https://openweathermap.org/api>

You'll need to sign up to get an api-key to use it to retrieve data.

let's get down to business.

**this is a regular call to the api and its result.**

``` bash
curl -s 'http://api.openweathermap.org/data/2.5/weather?q=paris&appid=<your-api-key>'

# {"coord":{"lon":2.35,"lat":48.86},
#  "weather":[{"id":800,"main":"Clear","description":"clear # sky","icon":"01d"}],
#  "base":"stations",
#  "main":{"temp":302.42,"pressure":1020,"humidity":39,"temp_# min":300.15,"temp_max":304.15},
#  "visibility":10000,"wind":{"speed":1.5,"deg":340},"clouds"# :{"all":0},
#  "dt":1533137400,"sys":{"type":1,"id":5617,"message":0.0066# ,"country":"FR",
#  "sunrise":1533097475,"sunset":1533151699},"id":2988507,"na# me":"Paris","cod":200}
```

so many data !!! and we're now and almost all the time not interested in all these data. we sometimes want some elements.

so we're going to use some wonderful command line tools to get only the data we want. here we want **name** and **temp** values.

##### N.B. these values change every moment as the temperature change in these cities, so when you'll try this yourself it might give you other results.

let's get the data we want in parallel and clean it adnd write it to disk.

``` bash
< cities.txt tr ' ' '+' | 
parallel -j400% --progress -C, 'curl -s "http://api.openweathermap.org/data/2.5/weather?q={}&appid=<your-api-key>"' | 
jq '{name: .name, temperature: .main.temp}' | 
json2csv | awk -F, '{print $1","$2-273.15}' | 
header -r city,temperature | 
csvsql --query 'SELECT * FROM stdin ORDER BY temperature DESC;' > temp.csv 

## Computers / CPU cores / Max jobs to run
## 1:local / 4 / 16
## 
## Computer:jobs running/jobs completed/%of started jobs/Average seconds to complete
## local:0/45/100%/0.1s
```

now we have connected and requested data in parallel from a web api, cleaning the data, doing some transformation on it and writing it to disk with almost *five lines of code*.

let's check the data we have and then explain the code chunk by chunk.

``` bash
< temp.csv csvlook
```

| city      | temperature |
|-----------|-------------|
| Abu Dhabi | 37.00       |
| Cairo     | 36.00       |
| Madrid    | 35.57       |
| Rome      | 34.37       |
| New Delhi | 34.00       |

GREAT !!! we now have only the cities and its celsius degree of temperature sorted descreasingly.

so let's explain the code;

1.  **&lt; cities.txt tr ' ' '+'**

here we have the cities.txt file as input and replace the spaces with + sign to use them the url we'll send to the api using the **tr** command line tool.

1.  **parallel -j400% --progress -C 'curl -s "<http://api.openweathermap.org/data/2.5/weather?q>={}&appid=17201c85f66369c680dcbf19352f3530"'**

here we tell the command line to do the following command in **parallel** using 400% of the CPU cores as the number of parallel jobs, i.e, in my machine there's 4 cores so I will run 16 jobs in parallel. --progress command to give me the information as it proceeds. -C to take care of the delimiter in the data file.

1.  **jq '{name: .name, temperature: .main.temp}**

here we use **jq** tool to extract only the fields we want from the json result.

1.  **json2csv | awk -F, '{print $1","$2-273.15}' **

converting the json data to csv and then getting the Celsius degree of the temperature as it comes in Kelvin.

1.  **header -r city,temperature |** **csvsql --query 'SELECT \* FROM stdin ORDER BY temperature DESC;' &gt; temp.csv**

then we give names to the columns and sort the data using SQL commands.

now as we have the data we can do further analysis using our favorite language, which is the command line as well in my case!

so we'll now read the data into R, summarize it and plot a bar plot of the cities and their temperature degrees

``` r
library(scales)
library(ggplot2)

temp <- read.csv('temp.csv', sep = ',', 
                 header = TRUE, stringsAsFactors = FALSE)
summary(temp)
```

    ##      city            temperature   
    ##  Length:45          Min.   :-3.00  
    ##  Class :character   1st Qu.:18.91  
    ##  Mode  :character   Median :23.16  
    ##                     Mean   :21.90  
    ##                     3rd Qu.:27.00  
    ##                     Max.   :33.48

``` r
ggplot(temp, aes(x = reorder(city, temperature), 
                 y = temperature, fill = temperature)) +
  geom_bar(stat = "identity", colour = "black") + 
  scale_fill_gradient2(low = muted("blue"), 
                       mid = "white", high = muted("red"),
                       midpoint = 25) + 
  coord_flip() + theme_bw() + xlab('Capital') +
  theme(legend.position = c(0.9, 0.2)) +
  theme(legend.background=element_rect(
    fill="white", colour="grey77"))
```

![](command_line_parallel_files/figure-markdown_github/bar%20plot-1.png)

this is so simple we can do so many other things with the data using R.

**but the purpose of this post is to show the capabilities the command line has in doing data science jobs.**
