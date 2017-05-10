library(shiny)
library(leaflet)
library(ggplot2)
library(tidyr)
library(plotly)
# library(d3heatmap)
# library(wordcloud2)
# library(RWeka)

if(!require(wordcloud2)){
  install.packages("wordcloud2")
  library(wordcloud2)
}

if(!require(RWeka)){
  install.packages("RWeka")
  library(RWeka)
}

if(!require(d3heatmap)){
  install.packages("d3heatmap")
  library(d3heatmap)
}

# setwd("~/MSAN/SpringModule2/622Visual/legendary_legends-final/")

ui <- fluidPage(
  headerPanel("Las Vegas Restaurant Visualizations"),
  sidebarPanel(
    conditionalPanel(condition = "input.conditionedPanels == 1", 
                     sliderInput("num_reviews", "Number of reviews:", min = 0, max = 1000, value = 200),
                     radioButtons("vars", "Select Category:",c("All", "Mexican","Pizza","Italian","Chinese","Indian","Japanese","Bars"), 
                                  selected = c("All")),
                     width = 2),
    conditionalPanel(condition = "input.conditionedPanels == 2", 
                     radioButtons("wc1", "Select stars for wordcloud:",c("5", "4","3","2","1"), selected = c("5")),
     #                radioButtons("wc2", "Select Category:",c("5", "4","3","2","1"), selected = c("1")),
                     width = 2)
    
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Plot 1", leafletOutput("mymap", width = "80%",height = "350px"),plotlyOutput("histPlot",height = '250px',width='80%'), value = 1),
      tabPanel("Plot 2", wordcloud2Output("WCmap1",width = "80%"),
                            d3heatmapOutput("heatmap"),
                           value = 2),
      id = "conditionedPanels"
    )
  ) 
)





#######server##########
server <- function(input, output, session) {
  d <- read.csv("Data/Restaurants_business.csv")
  d <- d[complete.cases(d),]
  d <- separate(d,categories,into = c('a','b'), sep=',')
  df_count <- read.csv("Data/word_count.csv",stringsAsFactors=FALSE)
  num_of_reviews = reactive(input$num_reviews)
  df <- reactive({
    d <- d[complete.cases(d),]
    d <- subset(d, review_count >= num_of_reviews())
    if (input$vars=='All'){
      d <- d
    } else{
      d <- subset(d,d$a== input$vars |d$b==input$vars)
    }
    
    d_agg <- aggregate(stars~neighborhood, d, mean)
    colnames(d_agg)[2] <- "avg_star"
    total <- merge(d, d_agg, by = "neighborhood")
    total[,'avg_star']=round(total[,'avg_star'],2)
    total=subset(total,total$neighborhood!="")
    total
  })

  ##### Getting the map #####3
  output$mymap <- renderLeaflet({
    
    pal <- colorNumeric(
      palette = "Oranges",
      domain = d$stars)
    
    m <- leaflet(df()) %>%
      
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers( lng = ~longitude, lat = ~latitude,fillOpacity = 0.9,
                        color = ~pal(stars),weight = 5, opacity = 0.8,
                        radius = ~0.003*review_count,
                        popup = ~paste("<h4>", name, "</h4>", 
                                       "Star: ", stars, "</h4>", "</br>",
                                       "Reviews: ", review_count)) %>%
      addLegend(pal = pal, values = ~stars)
    
    
  })
  
  ####getting heatmap df########
  df_heatmap <- reactive({
    d_heatmap <- aggregate(stars~neighborhood + b, d, mean)
    d_heatmap <- subset(d_heatmap,d_heatmap$neighborhood!="")
    data_wide <- spread(d_heatmap, b, stars)
    rownames(data_wide) <- data_wide$neighborhood
    data_wide <- data_wide[, !(colnames(data_wide) %in% c("neighborhood"))]
    data_wide <- data_wide[, -which(colMeans(is.na(data_wide)) > 0.5)]
    
    data_wide
  })
  
  ##Histogram plot########3
  
  output$histPlot <- renderPlotly({ 
    
    p <- ggplot(data=df(), aes(x = neighborhood, text =  paste("Avg reviews:", avg_star))) + 
      theme(text = element_text(size=9), 
            axis.text.x = element_text(angle = 45, hjust = 1),
            axis.title=element_text(size=9),
            axis.title.y=element_text(margin=margin(0,20,0,0))
            ) +
      geom_bar(fill = "firebrick", alpha = 0.6) + scale_x_discrete() + 
      xlab("\nNeighborhood") +
      ylab("Number of restaurants")
    ggplotly(p)
  })
  
  output$WCmap1 <- renderWordcloud2({
    df_filter <- subset(df_count,df_count$type==as.integer(input$wc1))
    freq.df = data.frame(word=df_filter$word, freq=df_filter$freq)
    wordcloud2(head(freq.df,300),figPath = "YELP-LOGO.png" ,color = "firebrick",backgroundColor = "white",size=0.5,shape='circle',ellipticity = 1) 
  })
  
  ########heatmap output#############
  
  output$heatmap <- renderD3heatmap({
    d3heatmap(df_heatmap(), scale = "column",dendrogram = "none", colors = 'Oranges' )
  })

}

# Run the application
shinyApp(ui = ui, server = server)