##########################################################
#  William Isaac | Sept. 6, 2015 | Party Asymmetry ML   #
##########################################################




######### Code Chunk 1 | Functions ################
###################################################

library(stats)
library(lattice)
library(RTextTools)
library(SnowballC)
library(tm)
library(muStat)
options("scipen" = 10)
getwd()
path = "/Users/William/Dropbox/Research/party_asymmetry/Data/"
setwd(path)


#This Function processes the corpus into container format
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

#This function allows me to see counts of discrete variables
vfreq <-function(var){
  a <- table(var)
  return(a)
}



######### Code Chunk 2 | Building Dataset ################
##########################################################


#First, I want to load the sample platform data to serve as my training dataset
train  <- read.csv("platforms_9.8.csv", header=TRUE, sep = ",")
train$text <- gsub("[^[:alnum:]///' ]", "", train$text)
test <- train[ which.na(train$ideol),]	
train <- train[ which(train$ideol == 1 | train$ideol == 0),]
platform <- rbind(train[1:1485,], test[ 1:28926,] )
platform <- platform[,c("id","text_year","paragraph_no","issue","subissue","text","group", "ideol", "policy")]


#This is the way to clean up the dups in the file
#n_occur <- data.frame(table(platform$text))
#View(n_occur)
#n_occur[n_occur$Freq > 1,]
#platform <- platform[!duplicated(platform$text), ]

########### Code Chunk 3 | Classifying Documents ##############
###############################################################


#Taking Text and Creating Document Vector
doc.vec <- VectorSource(platform$text)
doc.corpus <- GetCorpus(doc.vec)

#Creating Document Term Matrix
DTM <- DocumentTermMatrix(doc.corpus)

#Creating Container
train_size <- len(train$ideol)
len <- length(platform$text)
t <- train_size+1
container <- create_container(DTM, platform$ideol, trainSize=1:1485, testSize=1486:28926, virgin=TRUE)
models <- train_models(container, algorithms=c("MAXENT","SVM","GLMNET","SLDA","TREE","BAGGING","BOOSTING","RF"))
results <- classify_models(container, models)
analytics <- create_analytics(container, results)



############ Code Chunk 4 | Writing CSV FIle ##################
###############################################################


summary<- analytics@document_summary
meta <- platform[1486:30411,1:6]
meta$ID <- 1:28926
summary$ID <- 1:28926
summary <- summary[,17:20]
final <- merge(meta,summary, by="ID")
pre_lab  <- paste("ideol","_output_9.11.csv", sep="")
write.csv(final, pre_lab)



