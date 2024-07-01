ua_fully_vac <- owid_data[c(3,4,37)] %>% filter(location=='Ukraine')
ua_fully_vac %>% print(n=700)
ua_fully_vac <- ua_fully_vac %>% mutate(fully = people_fully_vaccinated)
ua_fully_vac <- ua_fully_vac[377:629,1:4]

ua_daily <- ua_fully_vac %>% pull(fully) %>% diff 
ua_daily[2:221] <- ua_daily[1:220]
ua_daily[1] <- NA
ua_daily[253] <- NA

ua_weekly <- ua_fully_vac %>% pull(fully) %>% diff(lag=7)
ua_weekly
ua_weekly[8:221] <- ua_weekly[1:214]
ua_weekly[1:7] <- NA
ua_weekly[240:253] <- NA

ua_fully_vac <- ua_fully_vac %>% mutate(daily=ua_daily, weekly=ua_weekly,wday = wday(date,week_start = 1))

ggplot(ua_fully_vac) + geom_line(mapping = aes(x=date,y=daily)) + scale_x_date(date_breaks = "2 weeks") +
  scale_y_continuous(breaks = seq(0,100000,20000))

ggplot(ua_fully_vac) + geom_line(mapping = aes(x=date,y=weekly/7)) + scale_x_date(date_breaks = "2 weeks") +
  scale_y_continuous(breaks = seq(0,100000,20000))