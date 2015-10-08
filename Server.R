library(shiny)
library(leaflet)
library(DT)
library(RColorBrewer)

#### prepare tool data ####

# read in full data for input tool, map won't run with any missing values
location_data <- read.csv("Corrected Location Code Data.csv")
table_data <- location_data
location_data <- location_data[complete.cases(location_data),]

# items for drop down menus used later
const_menu <- levels(location_data$Constituency)
code_menu <- sort(unique(location_data$Code))
region_menu <- sort(unique(levels(location_data$region_name)))


shinyServer(function(input, output) {
  
#### Producing Second Input Dropdown ####
  
  # code is nit-picky. Only works when set up using 'else' statements as below. No idea why.
  output$constControls <- renderUI({
    if(input$selectionLevel == "Constituency"){
      selectInput("Constit", label = h3("Select Constituency"), 
                  choices = const_menu, 
                  selected = "Aberavon")
      
    } else if(input$selectionLevel == "Location Code"){
      selectInput("Locations", label = h3("Select Location Code"), 
                  choices = code_menu)
      
    } else {
      selectInput("regional", label = h3("Select Region"), 
                 choices = region_menu,
                 selected = "South West")
      }
    })
  
  output$map <- renderLeaflet({

#### Select Mapping Data ####
    
    # Data used for mapping is pulled out here depending on user input
    if(input$selectionLevel == "Location Code"){
      mapping_data <- location_data[
        location_data$Code == input$Locations,]
    }
    
    if(input$selectionLevel == "Constituency"){
       mapping_data <- location_data[
       as.character(location_data$Constituency) == input$Constit,]
           
          }
      
    if(input$selectionLevel == "GORs"){
      mapping_data <- location_data[
        as.character(location_data$region_name) == input$regional,]
    }

#### Leaflet Map Code ####  
    
    # Set good colour palette 
    colourCode <- colorFactor(brewer.pal(12, "Paired"), mapping_data$Code)
    
    leaflet(data=mapping_data) %>%
      
    # map tile selected for clarity and minimalist look
    addProviderTiles("CartoDB.Positron") %>% 
    
    # Add Circles and set their display options  
    addCircleMarkers(lng=~lon, lat=~lat, popup = ~as.character(Location),
                     color = ~colourCode(Code),
                     stroke = FALSE, fillOpacity = 0.75) %>%
    
    # Add and format the legend (listing location codes)  
    addLegend("topleft", pal = colourCode, values = ~Code,
              title = "Area Code",
              opacity = .35)
    })
  
#### Data Table Code ####  
  output$Location_Table <- renderDataTable({
    datatable(table_data)
  })

#### Download Button Code ####  
  output$downloadData <- downloadHandler(
    filename = 'Location Code Data.csv',
    content = function(file) {
      write.csv(table_data, file)
      }
    )
  
  })