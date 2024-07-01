library("tidyverse")
#library(lubridate, lib.loc = "/usr/lib/R/site-library")
owid_data <- read_csv("owid-covid-data.csv")
owid_data[3] %>% filter(grepl("United St",location))
ru_fully_vac <- owid_data[c(3,4,37)] %>% filter(location=='Russia')
ru_fully_vac <- ru_fully_vac %>% mutate(fully = people_fully_vaccinated)
ru_fully_vac <- ru_fully_vac[397:629,1:4]
daily <- ru_fully_vac %>% pull(fully) %>% diff 
daily[233] <- NA
ru_fully_vac <- ru_fully_vac %>% mutate(daily=daily)
ru_fully_vac <- ru_fully_vac %>% mutate(wday = wday(date,week_start = 1))

theme_set(theme_bw())
ggplot(ru_fully_vac) + geom_point(mapping = aes(x=date,y=daily,colour=as.factor(wday)))
ggplot(ru_fully_vac) + geom_line(mapping = aes(x=date,y=daily))
ggplot(ru_fully_vac) + geom_line(mapping = aes(x=date,y=daily)) +
  +     geom_smooth(method = "lm",mapping = aes(x=date,y=daily))
date_from <- ru_fully_vac[1,2]
date_to <- ru_fully_vac[233,2]
ggplot(ru_fully_vac) + geom_line(mapping = aes(x=date,y=daily)) + scale_x_date(date_breaks = "2 weeks") + scale_y_continuous(breaks = seq(0,1800000,200000))
weekly <- ru_fully_vac %>% pull(fully) %>% diff(lag=7)
weekly[8:233] <- weekly[1:226]
weekly[1:7]<-NA
ru_fully_vac <- ru_fully_vac %>% mutate(weekly=weekly)
ggplot(ru_fully_vac) + geom_line(mapping = aes(x=date,y=weekly/7)) + scale_x_date(date_breaks = "2 weeks") + 
  scale_y_continuous(breaks = seq(0,1000000,50000))