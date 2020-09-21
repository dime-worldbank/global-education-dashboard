# sumstats.R
# generates summary HTML docs from summary objects generated in the project

library(summarytools)

# load main data 
load(file = file.path(repo.encrypt, "main/final_main_data_ipums.Rdata"))


# export summary objects
view(sum.raw,           file = file.path(html, "ipums-raw.html"),
                        footnote = "Raw IPUMS Data")
view(sum.raw.bycountry, file = file.path(html, "ipums-raw-bycountry.html"),
                        footnote = "Raw IPUMS Data by Country")
view(sum.av,            file = file.path(html, "ipums-district-averages.html"),
                        footnote = "IPUMS Conditional Variables Averaged by District")
