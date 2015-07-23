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
	
}

vfreq <-function(var){
  a <- table(var)
  return(a)
}


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

#For Group Coding
platform <- platform[ which(platform$group == 1 | platform$group == 0), ]

#For policy coding
#platform <- platform[ which(platform$policy == 1 | platform$policy == 0), ]

#For Ideology coding
#platform <- platform[ which(platform$ideol == 1 | platform$ideol == 0), ]


#Taking Text and Creating Document Vector
doc.vec <- VectorSource(platform$text)
doc.corpus <- GetCorpus(doc.vec)

#Creating Document Term Matrix
DTM <- DocumentTermMatrix(doc.corpus)

#Creating Container
train_size <- 1200
len <- length(platform$text)
t <- train_size+1
container <- create_container(DTM, platform$group, trainSize=1:train_size, testSize=t:len, virgin=FALSE)
models <- train_models(container, algorithms=c("MAXENT","SVM","GLMNET","SLDA","TREE","BAGGING","BOOSTING","RF"))
results <- classify_models(container, models)
analytics <- create_analytics(container, results)

#What should be the output?
analytics@ensemble_summary
t <- train_size+1
b <- platform[1201:1468,]

# merge two data frames by ID
test <- analytics@document_summary
test$ID <- 1:268
b$ID <- 1:268
pre_lab  <- paste("policy","_output.csv", sep="")
final <- merge(test,b, by="ID")
write.csv(final, pre_lab)
