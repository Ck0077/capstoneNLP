#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


suppressPackageStartupMessages({
  library(tidytext)
  library(tm)
  library(tidyr)
  library(dplyr)
  library(ggplot2)
  library(stringr)
  library(knitr)
  library(shiny)
})

# Load Quadgram,Trigram & Bigram & Unigram Data frame files

quadgram <- readRDS("quadgram.RData");
trigram <- readRDS("trigram.RData");
bigram <- readRDS("bigram.RData");
unigram <- readRDS("unigram.RData");
mesg <<- ""


bi_words <- readRDS("bi_words_fast.rds")
tri_words  <- readRDS("tri_words_fast.rds")
quad_words <- readRDS("quad_words_fast.rds")

bigram <- function(input_words){
  num <- length(input_words)
  filter(bi_words, 
         word1==input_words[num]) %>% 
    top_n(1, n) %>%
    filter(row_number() == 1L) %>%
    select(num_range("word", 2)) %>%
    as.character() -> out
  ifelse(out =="character(0)", "?", return(out))
}


trigram <- function(input_words){
  num <- length(input_words)
  filter(tri_words, 
         word1==input_words[num-1], 
         word2==input_words[num])  %>% 
    top_n(1, n) %>%
    filter(row_number() == 1L) %>%
    select(num_range("word", 3)) %>%
    as.character() -> out
  ifelse(out=="character(0)", bigram(input_words), return(out))
}


quadgram <- function(input_words){
  num <- length(input_words)
  filter(quad_words, 
         word1==input_words[num-2], 
         word2==input_words[num-1], 
         word3==input_words[num])  %>% 
    top_n(1, n) %>%
    filter(row_number() == 1L) %>%
    select(num_range("word", 4)) %>%
    as.character() -> out
  ifelse(out=="character(0)", trigram(input_words), return(out))
}


ngrams <- function(input){
  # Create a dataframe
  input <- data_frame(text = input)
  # Clean the Inpput
  replace_reg <- "[^[:alpha:][:space:]]*"
  input <- input %>%
    mutate(text = str_replace_all(text, replace_reg, ""))
  # Find word count, separate words, lower case
  input_count <- str_count(input, boundary("word"))
  input_words <- unlist(str_split(input, boundary("word")))
  input_words <- tolower(input_words)
  # Call the matching functions
  out <- ifelse(input_count == 0, "Please input a phrase",
                ifelse(input_count == 3, quadgram(input_words),
                       ifelse(input_count == 2, trigram(input_words), bigram(input_words))))
  
  # Output
  return(out)
}



# Cleaning of user input before predicting the next word

Predict <- function(x) {
  xclean <- removeNumbers(removePunctuation(tolower(x)))
  xs <- strsplit(xclean, " ")[[1]]
  
  # Back Off Algorithm
  # Predict the next term of the user input sentence
  # 1. For prediction of the next word, Quadgram is first used (first three words of Quadgram are the last three words of the user provided sentence).
  # 2. If no Quadgram is found, back off to Trigram (first two words of Trigram are the last two words of the sentence).
  # 3. If no Trigram is found, back off to Bigram (first word of Bigram is the last word of the sentence)
  # 4. If no Bigram is found, back off to the most common word with highest frequency 'the' is returned.
  
  
  if (length(xs)>= 3) {
    xs <- tail(xs,3)
    if (identical(character(0),head(quadgram[quadgram$unigram == xs[1] & quadgram$bigram == xs[2] & quadgram$trigram == xs[3], 4],1))){
      Predict(paste(xs[2],xs[3],sep=" "))
    }
    else {mesg <<- "Next word is predicted using 4-gram."; head(quadgram[quadgram$unigram == xs[1] & quadgram$bigram == xs[2] & quadgram$trigram == xs[3], 4],1)}
    
  }
  else  if (length(xs) == 2){
    xs <- tail(xs,2)
    if (identical(character(0),head(trigram[trigram$unigram == xs[1] & trigram$bigram == xs[2], 3],1))) {
      Predict(xs[2])
    }
    else {mesg<<- "Next word is predicted using 3-gram."; head(trigram[trigram$unigram == xs[1] & trigram$bigram == xs[2], 3],1)}
  } 
  else if (length(xs) == 1){
    xs <- tail(xs,1)
    if (identical(character(0),head(bigram[bigram$unigram == xs[1], 2],1))) {mesg<<-"No match found. Most common word 'the' is returned."; head("the",1)}
    else {mesg <<- "Next word is predicted using 2-gram."; head(bigram[bigram$unigram == xs[1],2],1)}
  }
 
}



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$prediction <- renderPrint({
    result <- ngrams(input$inputString)
    #result <- Predict(input$inputString)
    output$text2 <- renderText({mesg})
    result
  });
  
  output$text1 <- renderText({
    input$inputString});
  
})
