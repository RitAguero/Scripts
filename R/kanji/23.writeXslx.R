wb <- createWorkbook()
kanji_sheet <- createSheet(wb,'kanji')
kanji_font <- Font(wb,heightInPoints = 32, name = "Noto Sans CJK SC")
normal_font <- Font(wb,heightInPoints = 10, name = "Liberation Sans")
alignCenter <- Alignment(horizontal='ALIGN_CENTER', vertical='VERTICAL_CENTER', wrapText=TRUE)
rowindex <- 0
make_kanji_line <- function(line_index) {
   print (str_c("Create rows: ",(rowindex+1), ' to ' ,(rowindex+6)))
   rows <- createRow(kanji_sheet,(rowindex+1):(rowindex+6))
   line_length <- 14
   cells <-  createCell(rows,1:line_length)
   extraRow <- 0
   for (index in 0:(line_length-1)) {
       
       lapply(2:6, function(x)
       { 
           setCellStyle(cells[x,index+1][[1]],CellStyle(wb)+normal_font)
       })

        cindex <- line_index*line_length+index+1
        akanji <- kanji3_1000$kanji[cindex]
        setCellValue(cells[1,index+1][[1]],akanji)
        setCellStyle(cells[1,index+1][[1]],CellStyle(wb)+kanji_font+alignCenter)
        
        setCellStyle(cells[3,index+1][[1]],CellStyle(wb)+normal_font+
                      Fill(pattern = "SOLID_FOREGROUND",foregroundColor = grade_colors[kanji3_1000$grade[cindex]]))
        setCellValue(cells[3,index+1][[1]],kanji3_1000$kinfo[cindex])
        setCellValue(cells[4,index+1][[1]],kanji3_1000$meaning[cindex])
        setCellValue(cells[5,index+1][[1]],kanji3_1000$hinfo[cindex])
        setCellValue(cells[6,index+1][[1]],kanji3_1000$components[cindex])
        
        details <- type_details %>% filter(kanji == akanji)
        if (nrow(details)*3 > extraRow)
        {
           
           
           row_extra <- createRow(kanji_sheet,(rowindex+7+extraRow):(rowindex+6+3*nrow(details)))
           
           cell_extra <- createCell(row_extra,1:line_length)
           
           extraRow <- nrow(details)*3
        }
        
        
        if ((nrow(details) > 0)) {
          row_extra <- getRows(kanji_sheet,(rowindex+7):(rowindex+6+extraRow))
          cell_extra <- getCells(row_extra,index+1)
          lapply(1:extraRow, function(x){ setCellStyle(cell_extra[x][[1]],CellStyle(wb)+normal_font) })
          
           for (dindex in 1:nrow(details)) {
             setCellStyle(cell_extra[dindex*3-1][[1]],CellStyle(wb,fill = Fill(pattern = "SOLID_FOREGROUND", foregroundColor = details[dindex,5][[1]]))
                          +normal_font)
            
             lapply(1:3, function(x)
             { 
               setCellValue(cell_extra[dindex*3-3+x][[1]],details[dindex,x+1])
             })
           }
        }
        
   } 
   
   print (str_c('extraRow =', extraRow) )
   return(6+extraRow)
}

rowindex <- 0
for (line_index in 0:72) 
{
  add_result <- make_kanji_line(line_index)
  rowindex <- rowindex + add_result
}

saveWorkbook(wb, 'kbt.xlsx')