# init
py_dir <- '/home/Rit/Projects/covid'
lpr_file <- paste(py_dir,"/lpr.txt",sep='')

lpr_data <- read_csv(lpr_file,col_types = 'cci')
lpr_data$td <- as.Date(lpr_data$date,format = "%d.%m.%Y")

date_range <- seq(min(lpr_data$td), max(lpr_data$td), by='days')
date_expanded <- expand.grid(date_range, c('dth','cov'))
colnames(date_expanded) <- c("td", "type")

# lpr_data # 680 = 340*2
# lpr_data %>% filter(type=='cov') # 342
# lpr_data %>% filter(type=='dth') # 338
# date_range # 489
dc <- length(date_range)

lpr_data <- merge(lpr_data, date_expanded, by=c("td", "type"), all.y = T) %>% as_tibble
lpr_data <- lpr_data %>% arrange(td, type)

# усредняем число случаев за неделю...
weekly_lpr_t <- lpr_data %>% filter(type=='cov') %>% arrange(td) %>% pull(count) %>% diff(lag=7)
weekly_lpr_t <- weekly_lpr_t/7

weekly_lpr_t[8:dc] <- weekly_lpr_t[1:(dc-7)]
weekly_lpr_t[1:7] <- NA
# weekly_lpr_t

# ... и записываем в lpr_data
lpr_data <- lpr_data %>% mutate(weekly_lpr = NA) 

lpr_data <- within(lpr_data, {
  slice <- (type == 'cov') 
  weekly_lpr[slice] <- weekly_lpr_t
}) 

lpr_data <- lpr_data[c(1:5)]

# lpr_data %>% print(n=1000)
# date_range
# upd_tibble <- tibble(weekly_lpr,td = date_range,type='cov')
# lpr_data <- merge(lpr_data,upd_tibble,all = T) %>% as_tibble %>% print(n=300)

# усредняем число смертей за неделю...
lpr_dth <- lpr_data %>% filter(type=='dth') %>% arrange(td) %>% pull(count)
# lpr_dth
lpr_cumul_dth <- cumsum(coalesce(lpr_dth,0))
lpr_week_dth <- lpr_cumul_dth %>% diff(lag=7)

lpr_week_dth[8:dc] <- lpr_week_dth[1:(dc-7)]
lpr_week_dth[1:7] <- NA
# lpr_week_dth

# ... и записываем в lpr_data
lpr_data <- within(lpr_data, {
  slice <- (type == 'dth') 
  weekly_lpr[slice] <- lpr_week_dth/7
}) 

# Проверяем результат
lpr_data %>% print(n=1000)

# Графики
ggplot(lpr_data) + 
  geom_line(mapping = aes(x=td,y=weekly_lpr,colour=factor(type))) + 
  geom_smooth( mapping = aes(x=td,y=weekly_lpr,colour=factor(type)), span=0.5) + 
  scale_x_date(date_breaks = "6 weeks") +
  scale_color_manual(values = c("cov"="blue","dth"="red"))

ggplot(lpr_data %>% filter(td>'2021-07-05')) + 
  geom_line(mapping = aes(x=td,y=weekly_lpr,colour=type)) + 
  geom_smooth(mapping = aes(x=td,y=weekly_lpr,colour=type)) + 
  scale_x_date(date_breaks = "2 weeks")+
  scale_color_manual(values = c("cov"="blue","dth"="red"))

ggplot(lpr_data %>% filter(td<='2021-07-05')) + 
  geom_line(mapping = aes(x=td,y=weekly_lpr,colour=type)) + 
  geom_smooth(mapping = aes(x=td,y=weekly_lpr,colour=type)) + 
  scale_x_date(date_breaks = "6 weeks") +
  scale_y_continuous(breaks = seq(0,30,4)) +
  scale_color_manual(values = c("cov"="blue","dth"="red"))

ggplot(lpr_data %>% filter(type=='dth')) + geom_line(mapping = aes(x=td,y=count)) 
ggplot(lpr_data %>% filter(type=='cov')) + geom_line(mapping = aes(x=td,y=weekly_lpr)) + scale_x_date(date_breaks = "2 weeks")

lpr_data %>% filter(type=='dth') %>% pull(count) %>% sum(na.rm = T)


?read_csv

lpr_wide <- spread(lpr_data[c(1,2,4)],type,count) 
lpr_wide <- lpr_wide %>% mutate(weekly_lpr = weekly_lpr) 
cum_dth <- cumsum(coalesce(lpr_wide$dth,0))
lpr_wide <- lpr_wide %>% mutate(cum_dth = cum_dth)
lpr_wide %>% print(n=160)
weekly_dth_lpr <- lpr_wide %>% pull(cum_dth) %>% diff(lag=7)
weekly_dth_lpr[8:152] <- weekly_dth_lpr[1:145]
weekly_dth_lpr[1:7] <- NA
lpr_wide <- lpr_wide %>% mutate(weekly_dth_lpr = weekly_dth_lpr/7)

ggplot(lpr_wide) + geom_line(mapping = aes(x=td,y=weekly_dth_lpr)) 

lpr_wide[c(1,4,6)] %>% gather(td,weekly_lpr:weekly_dth_lpr)
?gather

lpr_new_data <- lpr_wide[c(1,4,6)] %>% pivot_longer(!td, names_to = "type", values_to = "count") 
 
ggplot(lpr_new_data, mapping=aes(x=td, y=count, colour=type)) + geom_line()
lpr_new_data <- lpr_new_data %>% mutate(c2 = ifelse(type=="weekly_lpr",count,count*5)) 
ggplot(lpr_new_data, mapping=aes(x=td, y=c2, colour=type)) + geom_line() + scale_x_date(date_breaks = "2 weeks")