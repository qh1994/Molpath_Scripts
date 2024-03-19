#install.packages("tinytex")

list.of.packages <- c("tinytex", "reticulate")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0){install.packages(new.packages)}
require("tinytex")
#install_tinytex(force = TRUE)
tlmgr_install('montserrat')
library(reticulate)


#args <- commandArgs(trailingOnly=TRUE)
args = commandArgs(trailingOnly=TRUE)
  rm(list = ls())

  # Date of run 201119
  date <- "DATEOFRUN"
  run_nbr <- "RUN_NBR"
  #curr_run <- args[2]
  # load run info
  run.info <- read.csv(paste0("/mnt/Molpath/array_data/EPIC/",run_nbr,"/run_info_", date, ".csv"), colClasses = rep("character", 3))
  # load control sheet
  chips <- unique(run.info$Chip)
  for(chip in chips){
  print(chip)
  if(!(file.exists(paste0("/mnt/Molpath/array_data/EPIC/",run_nbr,"/",chip, "_TableControl.txt")))) {
  print("next line 28")
  next}
    folders <- system(paste0("ls /mnt/Molpath/array_data/EPIC/",run_nbr), intern = TRUE)
    run.name <- folders[grepl(chip, folders)]
    run_3 <- folders[!grepl("\\.", folders)]
    run.name <- run_3
    if(grepl("_",run.name)){
    run.name <- strsplit(run.name,"_")[[1]][1]
    }
    print(paste0("/mnt/Molpath/array_data/EPIC/", run.name, "/", chip))
    if(grepl("\\.",paste0("/mnt/Molpath/array_data/EPIC/", run.name, "/", chip))){
    print("next")
    next
    }
    print(paste0("/mnt/Molpath/array_data/EPIC/", run_nbr, "/", chip, "_TableControl.txt"))
    tmp<- read.delim(paste0("/mnt/Molpath/array_data/EPIC/", run_nbr, "/", chip, "_TableControl.txt"))
    control.sheet <- read.delim(paste0("/mnt/Molpath/array_data/EPIC/", run_nbr, "/", chip, "_TableControl.txt"),
                                colClasses = c("integer", "character", rep("numeric", length(tmp)-2)))
    print("line 45")
    run.info.chip <- run.info[run.info$Chip == chip,]
    for(row in run.info.chip$Row){
    tryCatch({
    print(row)
      cols <- grep(row, colnames(control.sheet))

      control.sheet.row <- control.sheet[, c(2, cols)]
      control.sheet.row$Status <- "FAILED"
      colnames(control.sheet.row) <- c("Target", "Signal_Green", "Signal_Red", "p.value", "Status")

      control.sheet.row$Signal_Green <- round(control.sheet.row$Signal_Green, 0)
      control.sheet.row$Signal_Red <- round(control.sheet.row$Signal_Red, 0)
      control.sheet.row$p.value <- round(control.sheet.row$p.value, 4)

      for(i in 1:length(control.sheet.row$Target)){
        if(control.sheet.row$p.value[i] < 0.2){
          control.sheet.row$Status[i] <- "(FAILED)"
        }
        if(control.sheet.row$p.value[i] < 0.1){
          control.sheet.row$Status[i] <- "(PASSED)"
        }
        if(control.sheet.row$p.value[i] < 0.05){
          control.sheet.row$Status[i] <- "PASSED"
        }
      }
    print("line 63")
    run_name_2 <- run.name
    if(grepl("_",run.name)){
    run_name_2 <- strsplit(run.name,"_")[[1]][1]
    }
      #print(paste0(run.info.chip$Block[run.info.chip$Row == row], "_QC.pdf"))
      #print(run.name)
    #print(paste0("file_exists ", chip, "_TableControl.txt"))
    tryCatch({
      if(file.exists(paste0("/mnt/Molpath/array_data/EPIC/",run_nbr,"/",chip, "_TableControl.txt"))){
      print("line 73")
      rmarkdown::render("/mnt/NextSeq/testfolder/MethylationEPIC_QC.Rmd",
                        output_file =  paste0(run.info.chip$Block[run.info.chip$Row == row], "_QC.pdf"),
                        output_dir = paste0("/mnt/Molpath/array_data/EPIC/",run_nbr, ""))
                        }
      }
, warning = function(w) {
}, error = function(e) {
message(conditionMessage(e))
}, finally = {
if(file.exists(paste0("/mnt/Molpath/array_data/EPIC/",run_nbr,'/',paste0(run.info.chip$Block[run.info.chip$Row == row], "_QC.tex")))){
run_name_2 <- run.name
    if(grepl("_",run.name)){
    run_name_2 <- strsplit(run.name,"_")[[1]][1]
    }
  file <- "/mnt/NextSeq/testfolder/correct_file.py"
  #file <- "/home/quirin/MethylationEPIC_QC/MethylationEPIC_QC/correct_file.py"
  source_python(file)
  correct_file((paste0("/mnt/Molpath/array_data/EPIC/",run_nbr,'/',paste0(run.info.chip$Block[run.info.chip$Row == row], "_QC.tex"))),(paste0("/mnt/Molpath/array_data/EPIC/",run_nbr,'/',paste0(run.info.chip$Block[run.info.chip$Row == row], "_QC_2.tex"))))
  xelatex(paste0("/mnt/Molpath/array_data/EPIC/",run_nbr,'/',paste0(run.info.chip$Block[run.info.chip$Row == row], "_QC_2.tex")))

}
})
}, warning = function(w) {
}, error = function(e) {
message(conditionMessage(e))
}, finally = {}
)
}
}
