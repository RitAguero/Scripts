wb <- createWorkbook()
kanji_sheet <- createSheet(wb,'kanji')
kanji_font <- Font(wb,heightInPoints = 16, name = "Noto Sans CJK SC")
normal_font <- Font(wb,heightInPoints = 10, name = "Liberation Sans")
alignCenter <- Alignment(horizontal='ALIGN_CENTER', vertical='VERTICAL_CENTER', wrapText=TRUE)
rowindex <- 1
make_kanji_line <- function(line_index) {
   #print (str_c("Create rows: ",(rowindex+1), ' to ' ,(rowindex+6)))
   row <- createRow(kanji_sheet,(rowindex))
   #line_length <- 14
   cells <-  createCell(row,1:15)
   #extraRow <- 0
   #for (index in 0:(line_length-1)) {
       
       lapply(2:15, function(x)
       { 
           setCellStyle(cells[1,x][[1]],CellStyle(wb)+normal_font)
       })

        #cindex <- line_index*line_length+index+1
        akanji <- kanjia_1000$kanji[rowindex]
        setCellValue(cells[1,1][[1]],akanji)
        setCellStyle(cells[1,1][[1]],CellStyle(wb)+kanji_font+alignCenter)
        
        #setCellStyle(cells[3,index+1][[1]],CellStyle(wb)+normal_font+
        #              Fill(pattern = "SOLID_FOREGROUND",foregroundColor = grade_colors[kanji3_1000$grade[cindex]]))
        setCellValue(cells[1,2][[1]],kanjia_1000$kanji1000[rowindex])
        setCellValue(cells[1,3][[1]],kanjia_1000$rad_1000[rowindex])
        setCellValue(cells[1,4][[1]],kanjia_1000$strokes[rowindex])
        setCellValue(cells[1,5][[1]],kanjia_1000$meaning[rowindex])
        setCellValue(cells[1,6][[1]],kanjia_1000$skip_code[rowindex])
        setCellValue(cells[1,7][[1]],kanjia_1000$grade[rowindex])
        setCellValue(cells[1,9][[1]],kanjia_1000$heisig6[rowindex])
        setCellValue(cells[1,10][[1]],kanjia_1000$heisig_lesson[rowindex])
        setCellValue(cells[1,11][[1]],kanjia_1000$reading_on[rowindex])
        setCellValue(cells[1,12][[1]],kanjia_1000$reading_kun[rowindex])
        setCellValue(cells[1,13][[1]],kanjia_1000$explanation[rowindex])
        setCellValue(cells[1,14][[1]],kanjia_1000$keyword_6th_ed[rowindex])
        setCellValue(cells[1,15][[1]],kanjia_1000$components[rowindex])
        
        #details <- type_details %>% filter(kanji == akanji)
        #if (nrow(details)*3 > extraRow)
        #{
        #   row_extra <- createRow(kanji_sheet,(rowindex+7+extraRow):(rowindex+6+3*nrow(details)))
        #   cell_extra <- createCell(row_extra,1:line_length)
        #   extraRow <- nrow(details)*3
        #}
        
        
        # if ((nrow(details) > 0)) {
        #   row_extra <- getRows(kanji_sheet,(rowindex+7):(rowindex+6+extraRow))
        #   cell_extra <- getCells(row_extra,index+1)
        #   lapply(1:extraRow, function(x){ setCellStyle(cell_extra[x][[1]],CellStyle(wb)+normal_font) })
        #   
        #    for (dindex in 1:nrow(details)) {
        #      setCellStyle(cell_extra[dindex*3-1][[1]],CellStyle(wb,fill = Fill(pattern = "SOLID_FOREGROUND", foregroundColor = details[dindex,5][[1]]))
        #                   +normal_font)
        #     
        #      lapply(1:3, function(x)
        #      { 
        #        setCellValue(cell_extra[dindex*3-3+x][[1]],details[dindex,x+1])
        #      })
        #    }
        # }
        
   #} 
   
  
  
}

for (rowindex in 1:1000)
{
  make_kanji_line(0)
}



saveWorkbook(wb, 'k_anki.xlsx')