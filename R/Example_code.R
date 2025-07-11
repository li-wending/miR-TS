#' This script demonstrates how to compute miR-TS
#' for a publicly available dataset on hepatitis C,
#' for which the small RNA microarray was performed.
#' Note that the miR-TS was built and tested on
#' small RNA sequencing data; this was intentionally
#' chosen to demonstrate that miR-TS was platform-independent.
#'
# hepatitis_C #####
# Reference: Matsuura K, De Giorgi V, Schechterly C, Wang RY et al. Circulating let-7 levels in plasma and extracellular vesicles correlate with hepatic fibrosis progression in chronic hepatitis C. Hepatology 2016 Sep;64(3):732-45. PMID: 27227815
# Available from: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE74872

temp = read.csv(file = "GSE74872.csv", header = TRUE)
test <- read.table("GPL19117-74051.txt", sep = "\t")
test <- test %>% select(V1, V4)
temp <- temp%>%
  inner_join(., test, by="V1")
temp <- temp %>%
  rename(miRNA=V4) %>%
  filter(grepl("hsa", miRNA)) %>%
  select(-V1)
temp <- temp %>%
  column_to_rownames("miRNA")
temp <- 2^temp # Convert back to the count scale
temp[is.na(temp)] <- 0
hepatitis_C <- temp
dim(hepatitis_C)

# create the miRNA matrix:

miR_TS.output <- miR_TS.createDF(
  Input_df = "hepatitis_C",
  Dtct_cutoff = 0.1)

dim(miR_TS.output$mix)
dim(hepatitis_C)

# ADD META data:
hepatitis_C.meta <- read.csv(file = "GSE74872_meta.csv", header = TRUE)
table(hepatitis_C.meta$sample_type)

# combine with metadata ('sample_type'):
Input_mix= paste0(Input_df, ".qc_TMMcpm.dtct", Dtct_cutoff)
Public_datasets.miR_TS <- Add_metadata(miR_TS.output, hepatitis_C.meta)
assign(paste0(Input_mix, "__Abs.public"),
       Public_datasets.miR_TS)
# View(hepatitis_C.qc_TMMcpm.dtct0.1__Abs.public)
dim(Public_datasets.miR_TS)

# Plotting ####
tissue_type="liver"
plot_df <- Public_datasets.miR_TS
cat.sample_type <- as.character(unique(plot_df$sample_type))
if (sum(grepl("control|low$|no|Healthy", cat.sample_type, ignore.case = T))>0 ){
  plot_df$sample_type <-
    factor(plot_df$sample_type,
           levels=
             unique(c(cat.sample_type[grepl("control|low$|no|Healthy", cat.sample_type, ignore.case = T)],
                      sort(cat.sample_type))))
}

paste(names(table(plot_df$sample_type)), table(plot_df$sample_type), sep = ": ", collapse = ", ")
{
  # create gradient colors for the boxes to indicate severity:
  table(plot_df$sample_type)
  pairwise_combinations <- combn(unique(sort(plot_df$sample_type)), 2, simplify = FALSE)
  if (length(unique(plot_df$sample_type)) == 2){
    color_str <- c("grey70", "#d4242a")
  } else if (length(unique(plot_df$sample_type)) == 3){
    color_str <- c("grey70", "#FF4400", "#d4242a")
  } else if (length(unique(plot_df$sample_type)) == 4){
    color_str <- c("grey70", "#FEA600", "#FF4400", "#d4242a")
  } else {
    color_str <- "Nothing"
  }
}
# scale the min miR-TS score to zero:
plot_df[,tissue_type] <- plot_df[,tissue_type] - min(plot_df[,tissue_type])
plot_df$y <- (log(plot_df[,tissue_type] + 1))
# ggplot:
ggplot(plot_df %>% filter(!is.na(y))
       , aes(x = sample_type, y = y ))  +
  geom_boxplot(aes(fill = sample_type),
               width = 0.65,
               outlier.shape = NA) +
  # stat_compare_means(
  #   comparisons = pairwise_combinations,
  #   method = "t.test"
  # ) +
  labs(x = "", y = tissue_type) +
  scale_fill_manual(values = color_str) +  # Define custom colors
  scale_y_continuous(labels = number_format(accuracy = 0.1)) + # breaks = seq(0, 0.2, 0.1)
  scale_x_discrete(labels = c(1:length(unique(plot_df$sample_type)))) +
  theme(legend.position = "none",
        axis.title.y = element_text(size=14, color = "black"),
        axis.title.x = element_blank(),
        axis.text.x = element_text(
          angle = 45, hjust = 1,
          size=12, color = "black"
        ),
        plot.margin = margin(rep(5,4))
  )
