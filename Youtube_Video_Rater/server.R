library(shiny)
library(tidytext)
library(textstem)
library(syuzhet)
library(tm)
library(vosonSML)
library(ggplot2)
library(wordcloud)

shinyServer(function(input, output) {
    #getting video Id
    videoId<-reactive({
        validate(need(input$link != "",
                      ""))
        videoId<-GetYoutubeVideoIDs(input$link)
        videoId
    })
    
    #connecting with YouTube api {vosonSML}      
    data<-reactive({
        apikey<-"<your api key here>"
        key<-Authenticate("youtube",apiKey=apikey)
        if(videoId()!=""){
            data<-tryCatch({Collect(key,videoId())},
                           error=function(e){
                               validate("**Video link not found")})
        }
        data
    })
    
    #wrangling and cleaning comments data    
    comments<-reactive({
        comments<-data()$Comment
        comments<-gsub("[^A-Za-z]"," ",comments)
        comments<-tolower(comments)
        comments<-removeWords(comments,tidytext::stop_words$word)
        comments<-gsub("\\b[a-z]\\b{1}"," ",comments)
        comments<-stripWhitespace(comments)
        comments<-lemmatize_strings(comments)
        comments
    })
    
    
    
    #classifying sentiments
    sentiments<-reactive({
        #using {syuzhet}
        sentiments<-get_nrc_sentiment(comments())
    })
    
    #rating the video
    output$videoRating <- renderText({
        positivity<-sum(sentiments()$positive)
        negativity<-sum(sentiments()$negative)
        
        #rating the video
        rating<-positivity/(positivity+negativity)*100 #percent of positive comments
        rating<-rating/100*5 #calculate 'above' percent of 5
        paste0(rating,"/5")
    })
    
    #making sentiment graph
    output$sentimentGraph<-renderPlot({
        s<-sentiments()
        sentiDF<-data.frame(names=names(s),sentiments=colSums(s)/sum(s)*100)
        sentiDF$names<-factor(sentiDF$names,levels = sentiDF$names)
        ggplot(data = sentiDF,aes(y=sentiments,x=names))+
            geom_bar(stat = "identity",fill=rainbow(10))+
            labs(title = "Sentiment category scores of comments plot",
                 y="Sentiment scores (in %)", x="Sentiment category")+
            theme(text = element_text(size = 20), axis.text.x = element_text(angle = 90),
                  plot.title = element_text(hjust = 0.5))+
            geom_text(label=round(sentiDF$sentiments,2),vjust=-0.3)+
            ylim(0,max(sentiDF$sentiments)+5)
    })
    
    #creating document term matrix and word bag
    wordbag<-reactive({
        corpus<-Corpus(VectorSource(comments()))
        tdm<-as.matrix(TermDocumentMatrix(corpus))
        rowSums(tdm)
    })
    
    #creating word cloud
    output$wordCloud<-renderPlot({
        meanFreq<-mean(wordbag())
        wordcloud(names(wordbag()),wordbag(),
                  random.order = FALSE,
                  min.freq = meanFreq, 
                  colors = rainbow(length(wordbag())),scale=c(6,0.5))
    })
    
    #creating word frequency bar plot
    output$wordFreqPlot<-renderPlot({
        meanFreq<-mean(wordbag())
        wordbagSorted<-sort(wordbag()[wordbag()>meanFreq], decreasing=T)[1:25]
        wordbagSorted<-wordbagSorted[!is.na(wordbagSorted)]
        barplot(wordbagSorted,las=2,col=rainbow(25))
    })
    
    
})