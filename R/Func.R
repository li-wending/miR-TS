
# 1. CIBERSORT prerequisite ####
#' miR-TS is optimized from the CIBERSORT code.
#' CIBERSORT is licensed but free of charge for non-commercial use only.
#' Following registration, the CIBERSORT source code is available via the
#' [cibersort website](https://cibersortx.stanford.edu/).
#' The function in the following file is essential for
#' the successful execution of miR-TS:
#' "CIBERSORT.R"

# 2. Key functions of miR-TS: ####
## 2.0 ancillary functions: ####
# Convert the output to the absolute mode:
CIBERSORT.conv_ABS <- function(Input_mix,
                               Input_Signature,
                               Output_rel,
                               Suppress_note = FALSE){
  if (Suppress_note==FALSE){
    print("Input mixture: rownames= miRs, colnames= sample names!")
    print("Input Signature: rownames= miRs, colnames= tissue types! -- note: these miRs should overlap with Input mixture!")
    print("Cibersort relative mode output to be converted: rownames= sample names, colnames= tissue types!")
  }
  Output_rel <- as.data.frame(Output_rel)
  if (any(grepl("RMSE", colnames(Output_rel)))){
    Output_rel <- Output_rel %>%  select(-c("P-value", "Correlation", "RMSE"))
  }
  Input_Signature=Input_Signature[, colnames(Output_rel)]
  if (!all.equal(colnames(Input_Signature), colnames(Output_rel) ) |
      !all.equal( rownames(Output_rel), colnames(Input_mix))){
    stop("Error: Check and confirm that the sample names are consistent in input mix and CIBERSORT output,
       and tissue types are consistent in input sig and CIBERSORT output!")
  }
  miR_overlap <- intersect(rownames(Input_Signature), rownames(Input_mix))
  if (sjmisc::is_empty(miR_overlap)) {stop("Error: no overlapping miRs!")}
  sample_mean <- apply(Input_mix[miR_overlap, ], 2, function(x) mean(x))
  sample_avg = ifelse(median(as.matrix(Input_mix))==0, # To avoid 0 in the denominator.
                      mean(as.matrix(Input_mix)),
                      median(as.matrix(Input_mix)))
  scaling_factor <- as.numeric(sample_mean/sample_avg)
  sweep(Output_rel, MARGIN = 1, scaling_factor, `*`)
}

# replace the 0 with min/2:
Transform_cibersort <- function(df) {
  df <- df[, colSums(df)!=0] %>% select(-any_of(c("P-value","Correlation", "RMSE")))
  min_tissue <- apply(df,2,function(x){ifelse(min(x)==0,unique(sort(x))[2], min(x)) }) #get the second minimum value
  for (i in 1:ncol(df)) {df[df[,i]==0,i] <- min_tissue[i]/2}
  df
}

#Add meta data to the miR-TS output:
Add_metadata <- function(
    miR_TS.output,
    meta_data
){

  if(!all(c("Col_names", "sample_type") %in% colnames(meta_data))) {
    stop("Column names not found: Col_names, sample_type")
  }

  output_df <- miR_TS.output$proportions %>%
    rownames_to_column("Col_names") %>%
    mutate(Col_names=gsub("\\.", "-", Col_names)) %>%
    inner_join(
      ., meta_data%>%
        select(
          Col_names, sample_type
        )
      , by="Col_names") %>%
    column_to_rownames("Col_names") %>%
    mutate(miR_using=nrow(miR_TS.output$mix) )

  print(table(output_df$sample_type))

  output_df
}

# 2.1 miR_TS:
#' @param Input_df Input miRNAs data with miRNA names on the row
#'  and sample names on the column. Read counts should be used.
#' @param Dtct_cutoff Detect rate cutoff to include a subset of
#' miRNAs to be considered as reliably measured, default is 10%;
#'  note that a miRNA with read count being 0 still inform the miR-TS,
#'  so it is advised to keep this number low (10% or 20%) to include
#'  as many signature miRNAs as possible.
#' @param outlier_sample Cutoff of the MAD folds of the library sizes
#' to define outlier samples. Default to NA.
#' @param useAbsolute Use Absolute mode or not. Default is 1.
#'

miR_TS.createDF <- function(
    Input_df,
    Dtct_cutoff = 0.1,
    outlier_sample = NA,
    useAbsolute = 1
) {
  temp <- get(Input_df)
  rownames(temp) <- gsub("-","_",rownames(temp))
  df_using.qc <- temp

  if (!is.na(outlier_sample)){

    libSizes <- colSums(as.data.frame(df_using.qc))

    filtersamples <- function(filterParam, times= outlier_sample ){
      samplesToRemove <- which(filterParam > median(filterParam) + times * mad(filterParam) | filterParam < median(filterParam) - times * mad(filterParam) )
      samplesToRemove
    }

    lapply(list(libSizes = libSizes), filtersamples) %>%
      unlist() %>%
      unique() -> samplesToRemove
    tt <- colnames(df_using.qc)[samplesToRemove]
    if (length(tt)>0) {print("Samples removed:"); print(paste( tt,collapse = ", "))}
    df_using.qc <- df_using.qc[,-samplesToRemove]
  }
  # detection rate cutoff:
  keep <- which(Matrix::rowSums(df_using.qc > 0) >= round( Dtct_cutoff * ncol(df_using.qc)))
  df_using.qc = df_using.qc[keep,]

  # Normalize the input data with TMM; this will NOT affect the miR-TS output.
  matrix <- as.data.frame(df_using.qc)
  matrix <- edgeR::DGEList(counts=matrix)
  matrix <- edgeR::calcNormFactors(matrix, method = "TMM")
  Y <- edgeR::cpm(matrix)
  # Export the TMM-normalized raw data for later use
  assign(paste0(Input_df, ".qc_TMMcpm.dtct", Dtct_cutoff),
         envir = .GlobalEnv,
         as.data.frame(Y))

  # check % of miRNAs overlapping with signature matrix:
  X_TA2 <- read.csv(
    "./Signature_matrix.csv", row.names = 1
  )

  rownames(X_TA2) <- gsub("-","_",rownames(X_TA2))
  { # Data cleaning:
    if (sjmisc::is_empty(intersect(rownames(X_TA2), rownames(Y)))){
      if (any(grepl("-", rownames(X_TA2)))){
        rownames(X_TA2) <- gsub("-","_",rownames(X_TA2))
      } else {
        rownames(X_TA2) <- gsub("_","-",rownames(X_TA2))
      }
    }
    Num_inSig <- sum(rownames(Y) %in% rownames(X_TA2))
    Prop_inSig <- round(Num_inSig/nrow(X_TA2),digits = 2)

    X = X_TA2
    rownames(X) <- gsub("-","_",rownames(X))
    rownames(Y) <- gsub("-","_",rownames(Y))
  }

  # Deconvolution:####
  deconv.res <- (CIBERSORT(X = X,Y = Y, perm = 0, QN = F))

  # abs mode: ####
  {
    X=X[rownames(X) %in% rownames(Y), ] #!!!!!!!!!!!!!! This is the key!!!!!!!!!!!

    ### !!! use Absolute Mode??? (RECOMMENDED)
    if (useAbsolute == 1) {
      print("Using absolute mode!")
      res.abs <- CIBERSORT.conv_ABS(Input_mix=Y,
                                    Input_Signature= X,
                                    Output_rel=deconv.res$proportions,
                                    Suppress_note = TRUE)

      deconv.res$proportions <- cbind(res.abs,
                                      as.data.frame(deconv.res$proportions) %>%
                                        select(c("P-value", "Correlation", "RMSE")) )
    }

    # plot_TA2(deconv.res, y_top = 20, log_trans = F)

    deconv.res$proportions <- Transform_cibersort(as.data.frame(deconv.res$proportions))
    deconv.res

  }

}

