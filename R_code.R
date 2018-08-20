library(scales)
library(ggplot2)

temp <- read.csv('temp.csv', sep = ',', 
                 header = TRUE, stringsAsFactors = FALSE)
summary(temp)

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
