##########################################################
#  William Isaac | Agust 31, 2015 | Party Asymmetry ML   #
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
platform  <- read.csv("corrected_platforms_9.3.csv", header=TRUE, sep = ",")
platform$text <- gsub("[^[:alnum:]///' ]", "", platform$text)	

#Need to create a single dataframe with both

#For Group Coding
platform_temp <- platform[ which.na(platform$group),]
platform <- platform[ which(platform$group == 1 | platform$group == 0), ]
pf <- cbind( platform[1:921,], platform_temp[ 1:29480,] )
platform <- pf
rm(platform_temp,pf)

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
train_size <- 921
len <- length(platform$text)
t <- train_size+1
container <- create_container(DTM, platform$group, trainSize=1:train_size, testSize=t:len, virgin=TRUE)
models <- train_models(container, algorithms=c("MAXENT","SVM","GLMNET","SLDA","TREE","BAGGING","BOOSTING","RF"))
results <- classify_models(container, models)
analytics <- create_analytics(container, results)
score_summary <- create_scoreSummary(container, results)



# (Policy) merge two data frames by ID and Print to CSV
summary<- analytics@document_summary
meta <- platform[922:30401,8:14]
meta$ID <- 1:29480
summary$ID <- 1:29480
summary <- summary[,17:20]
final <- merge(meta,summary, by="ID")
pre_lab  <- paste("policy","_output_9.5.csv", sep="")
write.csv(final, pre_lab)


