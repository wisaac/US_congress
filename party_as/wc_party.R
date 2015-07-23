##########################################################
#  William Isaac | July 17, 2015 | Party Asymmetry ML     #
##########################################################


######### Code Chunk 1 | Setting Files ################
#######################################################
library(stats)
library(lattice)
library(tm)
library(wordcloud)
getwd()
path = "/Users/William/Dropbox/Research/party_asymmetry/Data/"
setwd(path)
rawtext  <- read.csv("verbatims.csv", header=TRUE, sep = ",")

################Functions#######################
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


vfreq <-function(var){
  a <- table(var)
  return(a)
}

######### Code Chunk 2 | Cleaning Data ################
#######################################################


#Step one: Reformatting Variables
pid <- NA
pid[rawtext$X=="1. Strong Democrat" ] <- 1
pid[rawtext$X == "7. Strong Republican"] <- 0
rawtext$X <- NULL
rawtext$pid <- pid


#Step two: Split samples into four Categories
#1. Words used by Democrats pro dem
#2. Words used by Dems that are con dem
#3. Words used by reps that are pro rep
#4. Words used by reps that are con rep

rt_dems <- rawtext[ which(rawtext$pid == 1), ]
rt_reps <- rawtext[ which(rawtext$pid == 0), ]


################Dems#######################

#Step Three: Clean text and create TDM

#Taking Text and Creating Document Vector
rt_dems$Like.Dem <- gsub("[^[:alnum:]///' ]", "", rt_dems$Like.Dem) 
doc.vec <- VectorSource(rt_dems$Like.Dem)
doc.corpus <- GetCorpus(doc.vec)

#Creating Document Term Matrix
TDM <- TermDocumentMatrix(doc.corpus, control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE), stopwords = TRUE))
TDM <- as.matrix(TDM)

comparison.cloud(TDM,max.words=10,random.order=FALSE)
commonality.cloud(TDM,max.words=40,random.order=FALSE)

#Need to go back and work on stemming the corpus because error is related to 0's in matrix
