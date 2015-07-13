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
train_docs <- a[ which(a$group == 1 | a$group == 0), ]



###################################################
### Code Chunk 2 | Document Matrix                #
###################################################

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

#Taking Text and Creating Document Vector
train_docs$text <- gsub("[^[:alnum:]///' ]", "", train_docs$text)
doc.vec <- VectorSource(train_docs$text)
doc.corpus <- GetCorpus(doc.vec)

#Creating Document Term Matrix
DTM <- DocumentTermMatrix(doc.corpus)
predict = cbind(train_docs$group,train_docs$ideol,train_docs$policy)
colnames(predict) <- c("group_ref", "ideol_ref", "policy_ref")
container <- create_container(DTM, predict, trainSize=1:750, testSize=751:1495, virgin=FALSE)





###################################################
### Code Chunk 3 | Training and Testing           #
###################################################

# train a SVM Model
SVM <- train_model(container, "SVM", kernel="linear", cost=1)
GLMNET <- train_model(container,"GLMNET")
MAXENT <- train_model(container,"MAXENT")
SLDA <- train_model(container,"SLDA")
BOOSTING <- train_model(container,"BOOSTING")
BAGGING <- train_model(container,"BAGGING")
RF <- train_model(container,"RF")

#Classifying the Models
SVM_CLASSIFY <- classify_model(container, SVM)
GLMNET_CLASSIFY <- classify_model(container, GLMNET)
MAXENT_CLASSIFY <- classify_model(container, MAXENT)
SLDA_CLASSIFY <- classify_model(container, SLDA)
BOOSTING_CLASSIFY <- classify_model(container, BOOSTING)
BAGGING_CLASSIFY <- classify_model(container, BAGGING)
RF_CLASSIFY <- classify_model(container, RF)

#Analytics
analytics <- create_analytics(container, cbind(SVM_CLASSIFY, SLDA_CLASSIFY, BOOSTING_CLASSIFY, BAGGING_CLASSIFY, RF_CLASSIFY, GLMNET_CLASSIFY, MAXENT_CLASSIFY))
summary(analytics)


# CREATE THE data.frame SUMMARIES
topic_summary <- analytics@label_summary
alg_summary <- analytics@algorithm_summary
ens_summary <-analytics@ensemble_summary
doc_summary <- analytics@document_summary

create_ensembleSummary(analytics@document_summary)



#Writing Files to CSV
b <- train_docs[751:1495,]
write.csv(b, "meta_train.csv")
write.csv(analytics@document_summary, "DocumentSummary.csv")
