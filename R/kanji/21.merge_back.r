kanji_1000 <- kanji2_all[src1000,1]
kanji_1000 <- kanji_1000 %>% mutate(kanji1000=1:1000)
kanji2_tbl <- as_tibble(merge(kanji2_tbl,kanji_1000,by="kanji",all=T))
kyouki20pref <- as_tibble(read_tsv("kyouki20pref.txt",col_names = c('index','kanji','strokes','english','on','kun')))
heisig_lessons <- c(15,34,54,74,98,109,133,184,206,249,264,294,320,345,376,395,422,514,547)
heisig_lessons <- c(heisig_lessons,553,619,686,828,858,957,1022,1103,1123,1166,1205)
heisig_lessons <- c(heisig_lessons,1267,1304,1336,1389,1430,1496,1533,1595,1650,1710,1742,1776,1812,1845,1893)
heisig_lessons <- c(heisig_lessons,1913,1945,1969,1996,2024,2052,2076,2131,2161,2181,2200)

heisig_lesson <- integer(2200)
kanji2_tbl <- kanji2_tbl %>% mutate(heisig_lesson=NA)
kanji2_tbl <- kanji2_tbl %>% mutate(heisig_lesson=case_when(heisig6<=heisig_lessons[1]~1)) 
for (i in 1:55) {
  kanji2_tbl <- kanji2_tbl %>% mutate(heisig_lesson
                                      = case_when(
                                            heisig6<=heisig_lessons[i] ~ heisig_lesson,
                                            (heisig6>heisig_lessons[i] & heisig6<=heisig_lessons[i+1])~i+1)
                                        ) 
}

kanji_by_type <- read_csv('kanji_by_type.csv')
kanji2_tbl <- as_tibble(merge(kanji2_tbl,kanji_by_type,by="kanji",all=T))

rtk_data <- read_csv('KANJI_INDEX.csv',col_types = 'c_-_cc-_')
kanji2_tbl <- as_tibble(merge(kanji2_tbl,rtk_data %>% filter(!is.na(keyword_6th_ed)),all.x = T))

kanji2_tbl[c(1,7,10,16,18,17,15)] %>% filter(!is.na(kanji1000)) 
kanji2_tbl$hinfo <- str_c(kanji2_tbl$heisig6,"(",kanji2_tbl$heisig_lesson,"); ",kanji2_tbl$keyword_6th_ed)
#kanji2_tbl[c(1,7,15,17,20)] %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000) %>% print(n=50)
#kanji2_tbl[c(1,7,15,17,20)] %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000) %>% slice_head(n=100) %>% filter(row_number()<31) %>% t() %>% as_tibble(.name_repair = "minimal") %>% write_csv(stdout())
#kanji2_tbl[c(1,7,15,17,20)] %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000) %>% slice_head(n=100) %>% filter(row_number()<31) %>% t() %>% write.csv()
#kanji2_tbl[c(1,7,15,17,20)] %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000) %>% slice_head(n=100) %>% filter(row_number()<31) %>% t() %>% write.table(row.names = F, col.names = F)

kanji2_tbl[c(1,22,17,20,19,15)] %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000) %>% subset(select = kanji:components)  %>% filter(row_number()<21) %>% t() %>% write.table(row.names = F, col.names = F, sep = ',',file='kanji1000intable.csv')
for (col in 1:49) { kanji2_tbl[c(1,22,17,20,19,15)] %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000)  %>% subset(select = kanji:components) %>%  filter(row_number()>col*20) %>% filter(row_number()<21) %>% t() %>% write.table(row.names = F, col.names = F, sep = ',',file='kanji1000intable.csv',append = T) }

r1000 <- read_csv('r1000.csv')
#kanji2_tbl <- as_tibble(merge(kanji2_tbl,r1000,by="kanji1000", all.x = T))
kanji2_tbl <- left_join(kanji2_tbl,r1000,by="kanji1000")

# left_join(kanji2_tbl,r1000,by="kanji1000") %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000) %>% subset(select = c(21,22)) %>% print(n=100)
# transmute удаляет неиспользуемые колонки
# transmute(kanji2_tbl,rad_1000 = ifelse(is.na(rad_1000.y),rad_1000.x,rad_1000.y))
kanji2_tbl <- kanji2_tbl %>% mutate(rad_1000 = ifelse(is.na(rad_1000.y),rad_1000.x,rad_1000.y)) 
kanji2_tbl <- kanji2_tbl[c(1:20,23)]  
kanji2_tbl$kinfo <- str_c(kanji2_tbl$kanji1000,". ",kanji2_tbl$rad_1000,"(",kanji2_tbl$strokes,"); g",kanji2_tbl$grade,"; f",kanji2_tbl$freq)


ggplot(kanji2_tbl %>% filter(!is.na(kanji1000)), mapping = aes(x=heisig_lesson,y=rad_1000, colour=as.factor(rad_1000 %/% 5))) + geom_count()
 ggplot(kanji2_tbl %>% filter(!is.na(kanji1000)), mapping = aes(x=heisig_lesson,y=rad_1000, colour=as.factor(rad_1000 %% 5))) + geom_count()
 ggplot(kanji2_tbl %>% filter(!is.na(kanji1000)), mapping = aes(x=heisig_lesson,y=rad_1000, colour=as.factor(rad_1000 %% 5), shape = as.factor(floor(rad_1000/5)%%5))) + geom_count()
 ggplot(kanji2_tbl %>% filter(!is.na(kanji1000)), mapping = aes(x=heisig_lesson,y=rad_1000, colour=as.factor(rad_1000 %% 5), fill = as.factor(floor(rad_1000/5)%%5))) + geom_count()
 ggplot(kanji2_tbl %>% filter(!is.na(kanji1000)), mapping = aes(x=heisig_lesson,y=rad_1000, colour=as.factor(rad_1000 %% 5), shape = as.factor(floor(rad_1000/5)%%5))) + geom_count()
 vignette("ggplot2-specs")
 ggplot(kanji2_tbl %>% filter(!is.na(kanji1000)), mapping = aes(x=heisig_lesson,y=rad_1000, colour=as.factor(rad_1000 %% 5), shape = as.factor(floor(rad_1000/5)%%5))) + geom_count() + geom_text(aes(label=rad_1000))
 ggplot(kanji2_tbl %>% filter(!is.na(kanji1000)), mapping = aes(x=heisig_lesson,y=rad_1000, shape = as.factor(floor(rad_1000%%25)) + geom_count() + geom_text(aes(label=rad_1000))
 ggplot(kanji2_tbl %>% filter(!is.na(kanji1000)), mapping = aes(x=heisig_lesson,y=rad_1000, shape = as.factor(floor(rad_1000%%25)))) + geom_count() + geom_text(aes(label=rad_1000))


ggplot(kanji2_tbl, mapping = aes(x=heisig_lesson,y=kanji1000,shape=as.factor(rad_1000/10))) + geom_point()
ggplot(kanji2_tbl, mapping = aes(x=heisig_lesson,y=kanji1000,shape=as.factor(floor(rad_1000/10)))) + geom_point()
Warning messages:
  1: The shape palette can deal with a maximum of 6 discrete values because more than 6 becomes difficult to discriminate; you
have 22. Consider specifying shapes manually if you must have them. 
2: Removed 1872 rows containing missing values (geom_point). 
> ggplot(kanji2_tbl, mapping = aes(x=heisig_lesson,y=kanji1000,colour=as.factor(floor(rad_1000/10)))) + geom_point()
Warning message:
  Removed 1221 rows containing missing values (geom_point). 
> ggplot(kanji2_tbl, mapping = aes(x=heisig_lesson,y=kanji1000,colour=as.factor(floor(rad_1000/5)))) + geom_point()
Warning message:
  Removed 1221 rows containing missing values (geom_point). 
> ggplot(kanji2_tbl, mapping = aes(x=heisig_lesson,y=rad_1000)) + geom_point()
Warning message:
  Removed 88 rows containing missing values (geom_point). 
> ggplot(kanji2_tbl, mapping = aes(x=heisig_lesson,y=rad_1000)) + geom_density()
Error: geom_density requires the following missing aesthetics: y
Run `rlang::last_error()` to see where the error occurred.
In addition: Warning message:
  Removed 88 rows containing non-finite values (stat_density). 
> ggplot(kanji2_tbl, mapping = aes(x=heisig_lesson,y=rad_1000)) + geom_density_2d()

#kanji2_tbl[c(1,7,11,15,17,19,20,22)] %>% print(n=100,width=1000)
#kanji2_tbl%>% print(n=30,width=1000)
#kanji2_tbl[c(20,22)]
#kanji2_tbl[c(1,21,5,7,11,15,17,19,20,22)] %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000)%>% print(n=100,width=1000)
kanjia_1000 <- kanji2_tbl %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000)
kanjia_1000 %>% print(n=100,width=1000)
kanjia_1000[c(10,18,19)] %>% filter(is.na(components)) %>% print(n=100,width=1000)

kanji3_1000 <- kanji2_tbl[c(1,7,11,15,17,19,20,22)] %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000)
grade_colors <- c("green","lightgreen","lightyellow","yellow","orange","red","plum")