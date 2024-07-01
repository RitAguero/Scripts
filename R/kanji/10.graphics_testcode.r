# run as much as needed

print(kanji2_tbl[-3],n=500)
print(arrange(kanji2_tbl[-3],heisig6),n=500)

ggplot(data=(kanji2_tbl %>% filter(freq<1000 & rad_nelson_complete!=rad_class ))) +
  geom_point(mapping = aes(y=freq,x=rad_class))
ggplot(data=(kanji2_tbl %>% filter(rad_nelson_complete!=rad_class ))) + 
  geom_point(mapping = aes(y=freq,x=rad_class,color=rad_nelson_complete)) +
  geom_text(aes(label=kanji,y=freq,x=rad_class),hjust=0,vjust=0)
rlang::last_error()
rlang::last_trace()



p <- ggplot(data=(kanji2_tbl %>% filter(rad_class < 51) %>% 
                    filter(rad_nelson_complete!=rad_class)),
            mapping = aes(x=freq,y=rad_class,color=rad_nelson_complete,label=paste(kanji,rad_nelson_complete)))
p + geom_text(size=3)
p + geom_text(size=3) + facet_grid(rad_class ~ strokes)
