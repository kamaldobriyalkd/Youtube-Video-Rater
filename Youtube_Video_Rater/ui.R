library(shiny)
library(shinycssloaders)

shinyUI(fluidPage(
    tags$head(
        tags$style(
            HTML(
                "
                p{
                    font-size:20px;
                    font-weight:bold;
                    text-align:center;
                }
                .dot {
                     height: 100px;
                     width: 100px;
                     background-color: #bbb;
                     border-radius: 50%;
                     margin:0 auto;
                     font-size:30px;
                     font-weight:bold;
                     vertical-align: middle;
                     line-height: 100px;
                     text-align:center;
                }
                "
            )
        )
    ),
    titlePanel("Youtube Video Rater"),

    fixedRow(
        column(9,
               wellPanel(
                   textInput("link", label = "", placeholder = "paste YouTube video link here"),
                   submitButton("Get ratings")
               )),
        column(3,wellPanel(
            p("Rating:"),
            div(id="videoRating",class="dot shiny-text-output")
        ))
    ),
    fixedRow(
        wellPanel(
                   withSpinner(
                       plotOutput("sentimentGraph")
                   )
        )
        
    ),
    fixedRow(
        wellPanel(
            p("Word cloud for all words"),
            withSpinner(
                plotOutput("wordCloud")
            )
        )
        
    ),
    fixedRow(
        wellPanel(
            p("Plot for most frequent words"),
            withSpinner(
                plotOutput("wordFreqPlot")
            )
        )
        
    )
))
