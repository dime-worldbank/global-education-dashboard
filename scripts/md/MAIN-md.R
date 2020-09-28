# MAIN-md.R
# Renders/knits all Rmarkdown files. 


library(rmarkdown)
library(knitr)

md <- "C:/Users/WB551206/local/GitHub/global-edu-dashboard/scripts/md"

md1 <- 1 # IMPUS district controls
md2 <- 1 # Basic Regressions
md3 <- 1 # 
md4 <- 1 #


if (md1 == 1) {
  knit(input  = file.path(md, "district-cntrls-sum.rmd"),
       output = file.path(dataout, "out/html/summary-district-controls.html"),
       quiet  = TRUE)
}


if (md2 == 1) {
  knit(input  = file.path(md, "basic-regs.rmd"),
       output = file.path(dataout, "out/html/basic-regressions.html"),
       quiet  = TRUE)
}