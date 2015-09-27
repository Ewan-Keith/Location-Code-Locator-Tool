library(shiny)
library(leaflet)
library(DT)

## page type has a toolbar at the top for different pages
shinyUI(navbarPage("Location Codes", id = "nav",

#### Map Panel Code ####                       
tabPanel("Interactive map",        

         # The 'div' and associated CSS is needed to full screen the map  
         div(class="outer",
      
             tags$head(
               includeCSS("styles.css")
              ),

             # Calls the map from the Server file and displays it
             leafletOutput("map", width="100%", height="100%"),
      
             # Sets the tolbox for sub-selecting data.  
             absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                    draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                    width = 330, height = "auto",
                    
                    # selection box for grouping type, e.g. Constituency or GORs region
                    selectInput("selectionLevel", label = h3("Choose Selection Level"), 
                                choices = c("Location Code", "Constituency", "GORs"), 
                                selected = "Location Code"),
                    
                    # second input box is reactive, depending on user choice for first 'SelectionLevel'
                    # the code for this control is stored in the Server file
                    uiOutput("constControls")
                    )
             )                        
         ),

#### data table code #####
tabPanel("Data Table",
         
         # add data table
         DT::dataTableOutput("Location_Table"),
         
         # add download button
         downloadButton('downloadData', 'Download')
         )
)                   
)