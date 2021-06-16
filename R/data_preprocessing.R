#' Data preprocessing.
#'
#' @param inputs Input a gene expression matrix normalized as CPM values as a data.frame object. Each row represent a sample and each column represent a gene.
#' @return a preprocessed gene expression matrix for model prediction.
#'
#' @NoRd
#'
#' @exmaples
#' data_filt <- data_preprocessing(data)
data_preprocessing <- function(inputs){
	library(torch)
	library(data.table)
	library(glue)
  #inputs <- read.csv("/home/shenxilin/sc_immune/data/glioma_sets/expr_orignal/CGGA-B.csv", row.names = 1)
  
  # preprocessing
  inputs = t(inputs)
  inputs = log(inputs +1)
  max <- quantile(inputs,0.99, na.rm = T)[[1]]
  min <- quantile(inputs,0.01, na.rm = T)[[1]]
  inputs = (inputs - min)/(max - min)
  
  
  if (length(unique(row.names(inputs))) != length(row.names(inputs))){
    inputs_group = aggregate(inputs,list(row.names(inputs)),mean)
    row.names(inputs_group) = row.names(inputs)
    inputs = inputs_group[,c(2:ncol(inputs_group))]
  }
  
  load(system.file("data/immune_genes.rda",package = "brammer"))
  
  dr = 0
  input_filter <- data.frame(row.names = colnames(inputs))
  for (gene in immune_genes){
    if (gene %in% rownames(inputs)){
      input_filter[[gene]] = inputs[gene,]
    }else{
      input_filter[[gene]] = 0
      dr = dr+1
      
    }
  }
  if (dr == 2616){
    return("Gene names invalid; Make sure HuGo Symbol as column names.")
  }else{
    if (dr > 1000){
      return(glue("{dr}/ 2616 genes needed for classification are not availed."))      
    }
  }
  return(input_filter)
  #return(glue("{strsplit(file_name,'.csv')[[1]]}_summary.csv"))
}