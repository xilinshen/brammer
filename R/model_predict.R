#' Subtyping brain tumor patients with different immune infiltration signatures based on expression profiles.
#'
#' @param An expression matrix of brain tumor transcriptomes. The gene expression should be normalized as CPM values. Please make sure each row of expression matrix represent a patient and each column represent a Hugo Symbol of human gene.

#' @return A dataframe of subtyping result.  
#'
#' @export
#'
#' @exmaples
#' cggab = load(system.file("data/CGGA-B_toydata.rda", package = "brammer"))
#' cggab_predict = model_predict(cggab)
#'
model_predict = function(data){
	library(torch)
	library(data.table)
	library(glue)

    data = data_preprocessing(data)
    if (class(data) == "character"){
        message(data)
        return()
    }
    MocoDataset <- dataset(
	  "mydataset",
	  initialize = function(df) {
		self$df <- df
	  },
	  .getitem = function(index) {
		x <- torch_tensor(as.numeric(self$df[index,]))
		
		# note that the dataloaders will automatically stack tensors
		# creating a new dimension
		list(x = x)
	  },
	  .length = function() {
		nrow(self$df)
	  }
	)
	model = load_model()
	
	#load(system.file("data/resnet18fc.rda",package = "brammer"))
	load_model()  
	#data = fread(file_name,header = T)
	#setDF(data)
	#row.names(data) = data[,1]
	#data = data[,-1]
	
	val_dataset = MocoDataset(data)
	val_loader <- dataloader(val_dataset, batch_size = 1, shuffle = F)
	  
	data_names = row.names(data)
	results <- list()
	a = 1
	logsoftmax = nn_log_softmax(dim = 2)
	for(batch in enumerate(val_loader)) {
		result <- model(batch[[1]])
		result <- logsoftmax(result)
		results[[data_names[a]]] <- as.numeric(result)
		a = a+1
	}
	results <- lapply(results,exp)
	results <- data.frame(results)
	results <- t(results)
	results <- data.frame(results)
	  
	row.names(results) = data_names
	colnames(results) = c("C1 probability (%)","C2 probability (%)")
	pred_subtype = apply(results,1,function(x){
		if (x[1]> x[2]){
		return ("C1")
		}else{
		return ("C2")
	}
	})
	results[["C1 probability (%)"]] <- round(results[["C1 probability (%)"]], 3)
	results[["C2 probability (%)"]] <- round(results[["C2 probability (%)"]], 3)
	results['subtype'] = pred_subtype
	return(results)
	#write.csv(file = file.path(glue("{strsplit(file_name,'.csv')[[1]]}_result.csv")),x = results)
}