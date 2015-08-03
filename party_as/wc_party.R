###########################################################
#  William Isaac | July 22, 2015 | Party Asymmetry ML     #
###########################################################


######### Code Chunk 1 | Setting Files ################
#######################################################
rm(list=ls())
library(stats)
library(lattice)
library(tm)
library(wordcloud)
library(ggplot2)
getwd()
path = "/Users/William/Dropbox/Research/party_asymmetry/Data/"
setwd(path)
rawtext  <- read.csv("verbatims.csv", header=TRUE, sep = ",")

################Functions#######################
GetCorpus <-function(textVector) {
  
  doc.corpus <- Corpus(doc.vec)
  summary(doc.corpus)
  doc.corpus <- tm_map(doc.corpus, content_transformer(tolower))
  doc.corpus <- tm_map(doc.corpus, removePunctuation)
  doc.corpus <- tm_map(doc.corpus, removeNumbers)
  doc.corpus <- tm_map(doc.corpus, removeWords, stopwords("english"))
  #doc.corpus <- tm_map(doc.corpus, stemDocument)
  doc.corpus <- tm_map(doc.corpus, stripWhitespace)
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


# rt_dems <- rawtext[ which(rawtext$pid == 1), ]
# rt_reps <- rawtext[ which(rawtext$pid == 0), ]

#Creating DF w/ concatenated variables

pid$x <- cbind(pid$Like.Dem,pid$Like.Rep,pid$Dislike.Dem,pid$Dislike.Rep)


################Dems#######################

#Step Three: Clean text and create TDM

#Taking Text and Creating Document Vector
rt_dems$Like.Dem <- gsub("[^[:alnum:]///' ]", "", rt_dems$Like.Dem) 
rt_reps$Like.Rep <- gsub("[^[:alnum:]///' ]", "", rt_reps$Like.Rep)
rt_reps$Dislike.Dem <- gsub("[^[:alnum:]///' ]", "", rt_reps$Dislike.Dem)
rt_reps$Dislike.Dem <- gsub("[^[:alnum:]///' ]", "", rt_reps$Dislike.Dem)
rt_dems$Dislike.Rep <- gsub("[^[:alnum:]///' ]", "", rt_dems$Dislike.Rep)


doc.vec <- VectorSource(rt_reps$Dislike.Dem)
doc.corpus <- GetCorpus(doc.vec)

#Creating Document Term Matrix
TDM <- TermDocumentMatrix(doc.corpus, control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE), stopwords = FALSE))
wordfreq=findFreqTerms(TDM, lowfreq=100)
termFreq <- rowSums(as.matrix(TDM))
termFreq <- subset(termFreq, termFreq>=50)
qplot(names(x = termFreq),y = termFreq, stat="identity", main = "Term Frequencies", geom="bar", xlab="Terms") + coord_flip()
TDM <- as.matrix(TDM)
TDM[is.nan(TDM)] = 0

wordcloud(words=names(wordfreq),freq=wordfreq,min.freq=5,max.words=50,random.order=F,colors="red")

comparison.cloud(TDM,max.word=10, scale = c(3,.5), random.order = FALSE, title.size = 1.5)
commonality.cloud(TDM,max.words=40,random.order=FALSE)

#Need to go back and work on stemming the corpus because error is related to 0's in matrix
