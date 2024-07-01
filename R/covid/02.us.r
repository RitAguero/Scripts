us_fully_vac <- owid_data[c(3,4,37)] %>% filter(location=='United States')
us_fully_vac <- us_fully_vac %>% mutate(fully = people_fully_vaccinated)

get_fully_vac <- function(country) {
  df_fully_vac <- owid_data[c(3,4,37)] %>% filter(location==country)
  df_fully_vac <- df_fully_vac %>% mutate(fully = people_fully_vaccinated)
}

us_fully_vac <- get_fully_vac('United States')

us_fully_vac %>% print(n=700)

modify_fully_vac <- function(df,start,end) {
  df <- df[start:end,1:4]
  df_length <- end - start + 1
  
  daily <- df %>% pull(fully) %>% diff 
  daily[2:df_length] <- daily[1:(df_length-1)]
  daily[1] <- NA

  weekly <- df %>% pull(fully) %>% diff(lag=7)
  weekly[8:df_length] <- weekly[1:(df_length-7)]
  weekly[1:7] <- NA

  df <- df %>% mutate(daily=daily, weekly=weekly,wday = wday(date,week_start = 1))  
}

us_fully_vac <- us_fully_vac[357:638,1:4]

us_daily <- us_fully_vac %>% pull(fully) %>% diff 
us_daily[2:282] <- us_daily[1:281]
us_daily[1] <- NA
us_daily

us_weekly <- us_fully_vac %>% pull(fully) %>% diff(lag=7)
us_weekly
us_weekly[8:282] <- us_weekly[1:275]
us_weekly[1:7] <- NA

us_fully_vac <- us_fully_vac %>% mutate(daily=us_daily, weekly=us_weekly,wday = wday(date,week_start = 1))

ggplot(us_fully_vac) + geom_line(mapping = aes(x=date,y=daily)) + scale_x_date(date_breaks = "2 weeks") +
  scale_y_continuous(breaks = seq(0,2000000,200000))

ggplot(us_fully_vac) + geom_line(mapping = aes(x=date,y=weekly/7)) + scale_x_date(date_breaks = "2 weeks") +
  scale_y_continuous(breaks = seq(0,2000000,200000))

owid_data[3] %>% filter(grepl("United K",location))

uk_fully_vac <- get_fully_vac('United Kingdom')
uk_fully_vac %>% print(n=640)
uk_fully_vac <- modify_fully_vac(uk_fully_vac,345,628)
ggplot(uk_fully_vac) + geom_line(mapping = aes(x=date,y=daily)) + scale_x_date(date_breaks = "2 weeks") +
  scale_y_continuous(breaks = seq(0,2000000,200000))

ggplot(uk_fully_vac) + geom_line(mapping = aes(x=date,y=weekly/7)) + scale_x_date(date_breaks = "2 weeks") +
  scale_y_continuous(breaks = seq(0,2000000,200000))
