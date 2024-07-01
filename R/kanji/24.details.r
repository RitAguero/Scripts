type_details <- read_csv('kanji_by_type_det.csv')
type_details %>% print (n=50)
type_index <- unique(type_details[c(2,3)])
# tomato- abstract: 
# dodgerblue - dynamic abstract:
# lightgreen - geo:
# orange - things:
# lightblue - living things:
# lightpink - human related
# yellow - culture and positive interactions
# gray - negative interactions
#  1 1.1     Colours      tomato
# 2 1.2     Shapes       tomato
# 3 1.3     Misc props  orange
# 4 2       Directions  lightgreen
# 5 2.1     Movement    dodgerblue
# 6 3       Numbers      tomato
# 7 3.1     Counters    orange
# 8 3.2     Calculation  tomato
# 9 3.3.1   Length units  tomato
# 10 3.3.2   Area units   tomato
# 11 3.3.3   Volume units   tomato
# 12 3.3.4   Weight units  tomato    
# 13 4       Time         dodgerblue     
# 14 4.1     Seasons lightgreen           
# 15 4.2     Week days  lightgreen       
# 16 5.1     Sky        lightgreen       
# 17 5.2     Natural substances orange
# 18 5.3     Weather/natural   lightgreen
# 19 5.4     Landscape         lightgreen
# 20 5.5     Animals           lightblue
# 21 5.5.1   Fish              lightblue
# 22 5.5.2   Birds             lightblue
# 23 5.5.3   Animal parts      orange
# 24 5.6     Plants and trees  lightblue
# 25 6.1     General            yellow
# 26 6.2     Roles and status   yellow
# 27 6.3     Family             yellow
# 28 6.4     Groups             yellow
# 29 7.1     Body              lightpink
# 30 7.2     Head and neck     lightpink
# 31 7.3     Torso and organs  lightpink
# 32 7.4     Arms and legs     lightpink
# 33 7.5     Body functions    lightpink
# 34 7.6     Health            lightpink
# 35 7.7     Movement actions  dodgerblue
# 36 8.1     Emotions          lightpink
# 37 8.2     Senses            lightpink
# 38 8.3     Judgment          lightpink
# 39 9       Food and drink     yellow
# 40 10.1    Towns             gray
# 41 10.2    Vehicles          orange
# 42 10.3    Clothing          orange
# 43 10.4    Manufactured items orange
# 44 11.1    Money             gray
# 45 11.2    Culture            yellow
# 46 11.3    Language           yellow
# 47 11.4    Religion          gray
# 48 11.4.1  Zodiac       dodgerblue     
# 49 11.5    War              gray
type_color <- c("tomato","tomato","orange","lightgreen","dodgerblue","tomato","orange"
                ,"tomato","tomato","tomato","tomato","tomato","dodgerblue"
                ,"lightgreen","lightgreen","lightgreen","orange"
                ,"lightgreen","lightgreen","lightblue","lightblue","lightblue"
                ,"orange","lightblue","yellow","yellow","yellow","yellow"
                ,"lightpink","lightpink","lightpink","lightpink","lightpink"
                ,"lightpink","dodgerblue","lightpink","lightpink","lightpink"
                ,"yellow","gray","orange","orange","orange","gray","yellow"
                ,"yellow","gray","dodgerblue","gray"
                )
type_index <- mutate(type_index,type_color=type_color)
type_details <- inner_join(type_details, type_index,by="c_index")
type_details <- type_details[c(1:4,6)] %>% rename(c_name = c_name.x)