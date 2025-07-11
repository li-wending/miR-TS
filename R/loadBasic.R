## INSTALL
# packages <- c("ggplot2", "tibble", "reshape2", "edgeR", "dplyr")
#
# installed_packages <- rownames(installed.packages())
# for (pkg in packages) {
#   if (!(pkg %in% installed_packages)) {
#     install.packages(pkg, dependencies = TRUE)
#   }
# }
# rm(list = c("installed_packages", "packages", "pkg"))

#CLEAN UP SPACE
rm(list = ls(all.names = TRUE))
gc()

# LOAD
library(scales)  # For number_format()
library(ggpubr)
library(ggplot2)
library(tibble)
library(reshape2)
library(dplyr)

source("./Func.R")
source("./CIBERSORT.R")

