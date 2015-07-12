##########################################################
#  William Isaac | July 9, 2015 | Party Asymmetry ML 	  #
##########################################################


###################################################
### Code Chunk 1 | Setting File Dir & Libraries   #
###################################################

library(stats)
library(lattice)
library(RTextTools)
library(SnowballC)
library(tm)
rm(list=ls())
options("scipen" = 10)
getwd()
path = "/Users/William/Dropbox/Research/party_asymmetry/"
setwd(path)
a  <- read.csv("platform.csv", header=TRUE, sep = ",")
# a$coder_name <- NULL 
# a$coder_date <- NULL 
# a$text_name <- NULL
# a$text_date <- NULL
# a$notes <- NULL
#a <- a[2:501,]
train_docs <- a[ which(a$group == 1 | a$group == 0), ]
test_docs <- train_docs[(751:1495),]
train_docs <- train_docs[(1:750),]




###################################################
### Code Chunk 2 | Document Matrix                #
###################################################

GetCorpus <-function(textVector) {
#Taking Text and Creating Document Vector
test_docs$text <- gsub("[^[:alnum:]///' ]", "", test_docs$text)
doc.vec <- VectorSource(test_docs$text)
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
#Creating Document Term Matrix
DTM <- DocumentTermMatrix(doc.corpus)
container <- create_container(DTM, train_docs$group, trainSize=1:400, testSize=401:750, virgin=FALSE)





###################################################
### Code Chunk 3 | Training and Testing           #
###################################################

MAXENT <- train_model(container,"MAXENT")
RF <- train_model(container,"RF")
GLMNET <- train_model(container,"GLMNET")
MAXENT_CLASSIFY <- classify_model(container, MAXENT)


analytics <- create_analytics(container, MAXENT_CLASSIFY)
summary(analytics)
