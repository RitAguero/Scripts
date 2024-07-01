Makekn <- function(n) {
  kn <- tibble(kanji2_all[(100*n+1):(100*n+35),c(16,1,4,5,11)],
               kanji2_all[(100*n+36):(100*n+70),c(16,1,4,5,11)],
               kanji2_all[(100*n+71):(100*n+105),c(16,1,4,5,11)],.name_repair = "unique")
  names(kn) <- c("m1","k1","c1","s1","r1","m2","k2","c2","s2","r2","m3","k3","c3","s3","r3")
  print(kn,n=35)
}

Makeko <- function(n) {
  kn <- tibble(kanji2_all[(100*n+1):(100*n+35),c(16,1,12,13)],
               kanji2_all[(100*n+36):(100*n+70),c(16,1,12,13)],
               kanji2_all[(100*n+71):(100*n+105),c(16,1,12,13)],.name_repair = "unique")
  names(kn) <- c("m1","k1","n1","r1","m2","k2","n2","r2","m3","k3","n3","r3")
  print(kn,n=35)
}

Makekt <- function(n) {
  kn <- tibble(kanji2_all[(100*n+1):(100*n+35),c(16,1,3,4,5,11)],
               kanji2_all[(100*n+36):(100*n+70),c(16,1,3,4,5,11)],
               kanji2_all[(100*n+71):(100*n+105),c(16,1,3,4,5,11)],.name_repair = "unique")
  names(kn) <- c("m1","k1","n1","c1","s1","r1","m2","k2","n2","c2","s2","r2","m3","k3","n3","c3","s3","r3")
  print(kn,n=35)
}