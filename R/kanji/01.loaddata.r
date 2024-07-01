allkanji = read_xml("/home/Rit/Japanese/Dict/kanjidic2.xml")
h1vol <- xml_find_all(allkanji,".//character[.//dic_ref[@dr_type='heisig6']<2201]") 
jojokanji <- xml_find_all(allkanji,".//character[./misc/grade<9]")
Join_xml <- function(kanji,xpath){xml_find_all(kanji,xpath) %>% xml_text %>% paste(collapse = ';')}

kanjia_1000 <- kanji2_tbl %>% filter(!is.na(kanji1000)) %>% arrange(kanji1000)
