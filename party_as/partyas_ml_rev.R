##########################################################
#  William Isaac | July 17, 2015 | Party Asymmetry ML     #
##########################################################




######### Code Chunk 1 | Functions ################
###################################################
rm(list=ls())
GetCorpus <-function(textVector) {

	doc.corpus <- Corpus(doc.vec)
	summary(doc.corpus)
	doc.corpus <- tm_map(doc.corpus, content_transformer(tolower), lazy=TRUE)
	doc.corpus <- tm_map(doc.corpus, removePunctuation, lazy=TRUE)
	doc.corpus <- tm_map(doc.corpus, removeNumbers, lazy=TRUE)
	doc.corpus <- tm_map(doc.corpus, removeWords, stopwords("english"), lazy=TRUE)
	doc.corpus <- tm_map(doc.corpus, stemDocument, lazy=TRUE)
	doc.corpus <- tm_map(doc.corpus, stripWhitespace, lazy=TRUE)
	doc.corpus <- tm_map(doc.corpus,content_transformer(function(x) iconv(x, to='UTF-8', sub= 'NA')), mc.cores=2)
	return(doc.corpus)
}

GetContainer <- function(textvar, train_size, class_var){
	#Taking Text and Creating Document Vector
	doc.vec <- VectorSource(platform$text)
	doc.corpus <- GetCorpus(doc.vec)

	#Creating Document Term Matrix
	DTM <- DocumentTermMatrix(doc.corpus)

	#Creating Container
	len <- length(textvar)
	t <- train_size+1
	container <- create_container(DTM, class_var[1], trainSize=1:train_size, testSize=t:len, virgin=FALSE)
	out <- list("container" = container, "train_size" = train_size, "length" = len)
	return(out)
}

vfreq <-function(var){
  a <- table(var)
  return(a)
}


# #function to create random sample from revised DF

# write_df <- function(){

# 	# RESULTS WILL BE REPORTED BACK IN THE analytics VARIABLE.
# 	# analytics@algorithm_summary: SUMMARY OF PRECISION, RECALL, F-SCORES, AND ACCURACY SORTED BY TOPIC CODE FOR EACH ALGORITHM
# 	# analytics@label_summary: SUMMARY OF LABEL (e.g. TOPIC) ACCURACY
# 	# analytics@document_summary: RAW SUMMARY OF ALL DATA AND SCORING
# 	# analytics@ensemble_summary: SUMMARY OF ENSEMBLE PRECISION/COVERAGE. USES THE n VARIABLE PASSED INTO create_analytics()
# 	analytics@ensemble_summary

# 	#Creating new dataframe


# 	#Writing Files to CSV
# 	b <- train_docs[751:1495,]
# 	write.csv(b, "meta_train.csv")
# 	write.csv(analytics@document_summary, "DocumentSummary.csv")
# }




######### Code Chunk 2 | Main Code ################
###################################################

library(stats)
library(lattice)
library(RTextTools)
library(SnowballC)
library(tm)
options("scipen" = 10)
getwd()
path = "/Users/William/Dropbox/Research/party_asymmetry/Data/"
setwd(path)
platform  <- read.csv("platform.csv", header=TRUE, sep = ",")
platform$text <- gsub("[^[:alnum:]///' ]", "", platform$text)	
# train_docs_group <- platform[ which(platform$group == 1 | platform$group == 0), ]
# train_docs_policy <- platform[ which(platform$policy == 1 | platform$policy == 0), ]
# train_docs_ideol <- platform[ which(platform$ideol == 1 | platform$ideol == 0), ]


predict = cbind(platform$group,platform$ideol,platform$policy)

pre_lab  <- paste("predict",i,"_output.csv" sep="")
container <- GetContainer(platform$text, 1300, platform$group)
models <- train_models(container$container, algorithms=c("MAXENT","SVM","GLMNET","SLDA","TREE","BAGGING","BOOSTING","RF"))
results <- classify_models(container$containercontainer, models)
analytics <- create_analytics(container$container, results)

#What should be the output?
analytics@ensemble_summary
t <- container$train_size+1
len <- container$length
b <- train_docs[t:len,]
write.csv(b, "meta_train.csv")
write.csv(analytics@document_summary, pre_lab[1])







for (i in 1:length(predict)) {
	pre_lab  <- paste("predict",i,"_output.csv" sep="")
	container <- GetContainer(platform$text, 1300, predict[i])
	models <- train_models(container$container, algorithms=c("MAXENT","SVM","GLMNET","SLDA","TREE","BAGGING","BOOSTING","RF"))
	results <- classify_models(container$containercontainer, models)
	analytics <- create_analytics(container$container, results)
	#What should be the output?
	analytics@ensemble_summary
	t <- container$train_size+1
	len <- container$length
	b <- train_docs[t:len,]
	write.csv(b, "meta_train.csv")
	write.csv(analytics@document_summary, pre_lab[1])

}