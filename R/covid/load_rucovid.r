library(readr)
library(dplyr)
library(tidyr)
library(tibble)

runasel <- read_tsv("runaselsort.txt",col_names = c("region","population"),col_types = "_cc___--__-")
runasel <- runasel %>% mutate_at("population",~parse_number(.,locale=locale(grouping_mark=" ")))

dt <- as.Date("20.07.2021","%d.%m.%Y")
maxdt <- as.Date("30.07.2021","%d.%m.%Y")
ru_covid <- tibble()
while (dt<maxdt)
{
  fn <- paste("RU",format(dt,"%y%m%d"),".txt",sep = '')
  ru_covid_dt <- read_tsv(fn,col_names = c("region","total_cases","new_cases","R_coeff","total_deaths","new_deaths","mortality","total_recoveries"),col_types = "cnndnnnn",locale = locale(grouping_mark = " ",decimal_mark = "."))
  ru_covid_dt <- ru_covid_dt %>% replace_na(list(new_deaths = 0)) %>% add_column(file_date=dt)
  ru_covid <- rbind(ru_covid, ru_covid_dt)
  dt <- dt+1
}
#print (ru_covid,n=180)
ru_covid <- inner_join(ru_covid,runasel)
print(arrange(ru_covid,desc(total_cases)),n=100)

dt <- as.Date("21.07.2021","%d.%m.%Y")
maxdt <- as.Date("30.07.2021","%d.%m.%Y")
v_covid <- tibble()
v_covid_ru <- tibble()

vru_classes <- c("character","numeric","numeric","numeric","numeric","character","numeric","numeric","character","character")
vru_names <- c("region","first","first_percentage", "first_rate","first_rate_percentage", "first_rate_vs_last_week", "days_to_50", "second", "date", "second2first")

vru_classes0729 <- c("character","numeric","numeric","numeric","numeric","numeric","character","numeric","numeric","character","character")
vru_names0729 <- c("region","first","first_percentage","first_adult_percentage", "first_rate","first_rate_percentage", "first_rate_vs_last_week", "days_to_50", "second", "date", "second2first")
vru_date0729 <- as.Date("29.07.2021","%d.%m.%Y")

while (dt<maxdt)
{
  fn <- paste("v",format(dt,"%y%m%d"),".txt",sep = '')
  if (dt >= vru_date0729)
  {
    vru_classes <- vru_classes0729
    vru_names <- vru_names0729
  }
  
  
  vdata <- readLines(fn)
  vdatabreak <- which.min(lapply(vdata,FUN = nchar))
  v_covid_ru_dt <- read.table(text = vdata[1:(vdatabreak-1)],header = FALSE,sep="\t",
      colClasses = vru_classes,
      col.names =  vru_names      ) %>% as_tibble()
  v_covid_ru_dt <- add_column(v_covid_ru_dt,file_date=dt)
  v_covid_ru <- rbind(v_covid_ru, v_covid_ru_dt)
  
  v_covid_dt <- read.table(text = vdata[(vdatabreak+1):length(vdata)],header = FALSE,sep="\t",blank.lines.skip = TRUE,quote="",
      colClasses = c("character","character","character","character","numeric","character","character","character","character","character")
      ) %>% as_tibble()
  v_covid_dt <- rename(v_covid_dt,region=V1,total=V2,rate=V3,first=V4,first_percentage=V5,first_rate=V6,days_to_50=V7,days_to_70=V8,second=V9,date=V10)  
  
  v_covid_dt <- add_column(v_covid_dt,file_date=dt)
  v_covid <- rbind(v_covid, v_covid_dt)
  
  dt <- dt+1
}

v_covid_ru <- inner_join(v_covid_ru,runasel)
print(arrange(v_covid,desc(total)),n=100)
print(arrange(v_covid_ru,desc(first)),n=100)



dt <- as.Date("19.07.2021","%d.%m.%Y")
maxdt <- as.Date("24.07.2021","%d.%m.%Y")
w_covid <- tibble()

while (dt<maxdt)
{
  fn <- paste("W",format(dt,"%y%m%d"),".txt",sep = '')
  w_covid_dt <- read_tsv(fn,col_names = FALSE,na = "N/A",locale = locale(grouping_mark = ","),col_types = "ncnnnnnnnnnnnnnnnn")
  w_covid_dt <- rename(w_covid_dt,ind=X1,region=X2,total_cases=X3,new_cases=X4,total_deaths=X5,new_deaths=X6,total_recovered=X7,new_recovered=X8)
  w_covid_dt <- rename(w_covid_dt,active=X9,serious=X10,total_cases_per_million=X11,total_deaths_per_million=X12)
  w_covid_dt <- rename(w_covid_dt,total_tests=X13,total_tests_per_million=X14,population=X15)
  w_covid_dt <- rename(w_covid_dt,case_per_X_ppl=X16,death_per_X_ppl=X17,test_per_X_ppl=X18)
  w_covid_dt <- w_covid_dt %>% replace_na(list(new_cases=0,total_deaths=0,new_deaths = 0,total_deaths_per_million=0)) %>% add_column(file_date=dt)
 
  w_covid <- rbind(w_covid, w_covid_dt)
  
  dt <- dt+1
}

print(arrange(w_covid,desc(new_cases)),n=100)
