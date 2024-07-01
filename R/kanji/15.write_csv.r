kanji2_nelson <- kanji2_tbl %>% filter(.,!is.na(rad_nelson))
kanji2_nelson <- mutate(kanji2_nelson,by_nelson=-1,rad_nelson_complete=rad_class)
kanji2_tbl <- kanji2_tbl %>% mutate(by_nelson=ifelse(is.na(rad_nelson),0,1))
kanji2_all <- rbind(kanji2_tbl,kanji2_nelson)
kanji2_all <- kanji2_all %>% mutate(kanji1000 = NA) %>% arrange(rad_nelson_complete,strokes,freq)
kanji2_all <- kanji2_all %>% mutate(num=1:2519)
write_csv(kanji2_all,"kanji2_all.csv")


# run once to fix ';' {
kanji2_tbl <- kanji2_tbl %>% mutate(meaning=str_replace_all(meaning,';','; '))
kanji2_tbl <- kanji2_tbl %>% mutate(reading_on=str_replace_all(reading_on,';','; '))
kanji2_tbl <- kanji2_tbl %>% mutate(reading_kun=str_replace_all(reading_kun,';','; '))
# }