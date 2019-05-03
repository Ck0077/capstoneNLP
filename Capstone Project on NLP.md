Capstone Project on NLP
========================================================
author: Ck
date: 03/05/2019
autosize: true

Overview
========================================================
Capstone is a project that helps us get familiar with NLP. Just like swiftkey keyboard When someone types:

I went to the

the keyboard presents three options for what the next word might be.

Similarly Capstone is the project in which predicts next word as the user types a sentence.

Underlying Algorithm and Process
========================================================

- N-gram model with "Stupid Backoff" ([Brants et al 2007](http://www.cs.columbia.edu/~smaskey/CS6998-0412/supportmaterial/langmodel_mapreduce.pdf)) is used.
- Data source: blogs,twitter and news which is then merged into one.
- Data Cleaning: by conversion to lowercase, strip white space, and removing punctuation and numbers.
- Creation of N-grams: Quadgram,Trigram and Bigram.
- Term-count tables are extracted from the N-Grams and sorted according to the frequency in descending order.
- Rdata files with n-gram objects created.

Prediction model checks if highest-order (in this case, n=4) n-gram has been seen. If not "degrades" to a lower-order model (n=3, 2).

App Demo
========================================================
<div style="align:top"><img src="Capture.png" alt="algorithm flow" /></div>

[Link](https://ck0077.shinyapps.io/PredictTextCapstone/) to App. 



Further Exploration
========================================================

- The code is available on [GitHub](https://github.com/Ck0077/capstoneNLP)
- Further work can expand the main weakness of this approach: long-range context
    1. Current algorithm discards contextual information past 4-grams
    2. We can incorporate this into future work through clustering underlying training corpus/data and predicting what cluster the entire sentence would fall into
    3. This allows us to predict using ONLY the data subset that fits the long-range context of the sentence, while still preserving the performance characteristics of an n-gram and Stupid Backoff model

