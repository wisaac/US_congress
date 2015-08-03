###################################################################
#  William Isaac | July 28, 2015 | Party Asymmetry ML Revised     #
###################################################################


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

BigramTokenizer <- function(x){
    unlist(lapply(ngrams(words(x), 2), paste, collapse = " "), use.names = FALSE)
}

######### Code Chunk 2 | Cleaning Data ################
#######################################################


#Step one: Reformatting Variables
pid <- NA
pid[rawtext$X=="1. Strong Democrat" ] <- 1
pid[rawtext$X == "7. Strong Republican"] <- 0
rawtext$X <- NULL
rawtext$pid <- pid


#Step Two: Creating Individual

l.dem <- lapply(rawtext$Like.Dem, as.character)
l.rep <- lapply(rawtext$Like.Rep, as.character)
dl.dem <- lapply(rawtext$Dislike.Dem, as.character)
dl.rep <- lapply(rawtext$Dislike.Rep, as.character)



rawtext$text <- paste(l.dem, l.rep, dl.dem, dl.rep, sep = " ")

#Creating DF w/ concatenated variables

df.1 <- data.frame(rawtext$pid, rawtext$text)

#Step Three: Split samples in two based on R Pid
 rt_dems <- df.1[ which(rawtext$pid == 1), ]
 rt_reps <- df.1[ which(rawtext$pid == 0), ]

rm(dl.rep,dl.dem, l.dem, l.rep, pid, rawtext)

################Dems#######################

#Step Four: Clean text and create TDM

#Taking Text and Creating Document Vector
rt_dems$text <- gsub("[^[:alnum:]///' ]", "", rt_dems$rawtext.text) 
rt_reps$text <- gsub("[^[:alnum:]///' ]", "", rt_reps$rawtext.text)


doc.vec <- VectorSource(rt_dems$text)
doc.corpus.dem <- GetCorpus(doc.vec)
doc.vec <- VectorSource(rt_reps$text)
doc.corpus.rep <- GetCorpus(doc.vec.rep)


#Creating Document Term Matrix
TDM.D <- TermDocumentMatrix(doc.corpus.dem, control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE), stopwords = TRUE))
wordfreq=findFreqTerms(TDM.D, lowfreq=100)


TDM.R <- TermDocumentMatrix(doc.corpus.rep, control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE), stopwords = TRUE))
wordfreq=findFreqTerms(TDM.R, lowfreq=100)

termFreq.D <- as.matrix(TDM.D)
termFreq.D <- sort(rowSums(termFreq.D),decreasing=TRUE) 


termFreq.R <- as.matrix(TDM.R)
termFreq.R <- sort(rowSums(termFreq.R),decreasing=TRUE) 


#This will help us find the frequent and related terms in the matrix
#findFreqTerms(TDM.D, 200)
#findAssocs(TDM.D, "class", .2) 

wc_rep <- data.frame(term = names(termFreq.R), freq = termFreq.R)
wc_dem <- data.frame(term = names(termFreq.D), freq = termFreq.D)

#rm(doc.vec,doc.corpus.dem,doc.corpus.rep)


######### Code Chunk 3 | Creating Graphics ##############
#########################################################


# The problem I see is that we need to create a dataframe that contains the count of the top 50 Dem and Rep words.
# Then we need to correct the word counts for the fact that democrats have higher counts than reps.


#In order to create the final graph, I need to create the dataframe using an inner merge
wc_total <- merge(wc_dem,wc_rep,by=c("term"))
names(wc_total) <- c("term","freq.dem","freq.rep")
wc_total <- wc_total[order(-wc_total$freq.dem),] 
wc_total$freq.dem <- log(wc_total$freq.dem)
wc_total$freq.rep <- log(wc_total$freq.rep)
wc_total$diff <- log((wc_total$freq.dem/wc_total$freq.rep)) #This is D-Lot Score
wc_total <- subset(wc_total, diff >= 1.85 | diff <= -.8)
wc_total <- wc_total[order(-wc_total$diff),] 

#Now I need to reshape the dataset in order to plot it the way I want
wc_total <- reshape(wc_total, 
           varying = c("freq.dem","freq.rep"), 
           v.names = "pid",
           timevar = "freq", 
           times = c("freq.dem","freq.rep"), 
           direction = "long")
wc_total <- with(wc_total, data.frame(term,pid,freq,diff))
wc_total <- wc_total[order(-wc_total$diff),] 
names(wc_total) <- c("term","freq","pid", "diff")
wc_total$name <- factor(wc_total$term, levels = wc_total$term[order(wc_total$diff)])

# I think I want a dot plot that is red for reps and blue for dems
g <- ggplot(wc_total, aes(x = name, y = freq, colour = pid)) + geom_point()
g <- g + coord_flip()
g <- g+theme(legend.title=element_blank())
g <- g + scale_color_manual(values=c("dodgerblue4", "red2"))



termFreq <- subset(termFreq, termFreq>=50)
term.freq <- subset(term.freq, term.freq >= 15)

qplot(names(x = termFreq),y = termFreq, stat="identity", main = "Term Frequencies", geom="bar", xlab="Terms") + coord_flip()
TDM <- as.matrix(TDM)
TDM[is.nan(TDM)] = 0

wordcloud(words=names(wordfreq),freq=wordfreq,min.freq=5,max.words=50,random.order=F,colors="red")

comparison.cloud(TDM,max.word=10, scale = c(3,.5), random.order = FALSE, title.size = 1.5)
commonality.cloud(TDM,max.words=40,random.order=FALSE)


######### Code Chunk 4 | Bi-Gram Plots ##################
#########################################################
# Create an n-gram Word Cloud ----------------------------------------------

tdm.ng <- TermDocumentMatrix(doc.corpus.rep, control = list(tokenize = BigramTokenizer, weighting = function(x) weightTfIdf(x, normalize = FALSE)))
#dtm.ng <- DocumentTermMatrix(ds5.1g, control = list(tokenize = BigramTokenizer))

# Try removing sparse terms at a few different levels
tdm4.ng <- removeSparseTerms(tdm.ng, 0.985)
#tdm9.ng  <- removeSparseTerms(tdm.ng, 0.9)
#tdm91.ng <- removeSparseTerms(tdm.ng, 0.91)
#tdm92.ng <- removeSparseTerms(tdm.ng, 0.92)

notsparse <- tdm4.ng
m = as.matrix(notsparse)
v = sort(rowSums(m),decreasing=TRUE)
d = data.frame(word = names(v),freq=v)


# Create the word cloud
pal = brewer.pal(9,"BuPu")
wordcloud(words = d$word, 
          freq = d$freq, 
          scale = c(3,.8), 
          random.order = F,
          colors = pal)


