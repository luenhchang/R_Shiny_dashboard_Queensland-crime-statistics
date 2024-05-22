#-------------------------------------------------------------------------------------------------------------------
# Program: C:/GoogleDrive/scripts/R-Shinyapp_data-gov-au_police/server.R
# Date created: 17-MAY-2024
# Author(s): Lun-Hsien Chang
# Modified from: C:/GoogleDrive/scripts/R-shinyapp_internet-speed-test/server.R
# References
## [How to set different text and hoverinfo text](https://stackoverflow.com/questions/49901771/how-to-set-different-text-and-hoverinfo-text)
## [Plot.ly in R: Unwanted alphabetical sorting of x-axis](https://stackoverflow.com/questions/40701491/plot-ly-in-r-unwanted-alphabetical-sorting-of-x-axis)

## Date       Changes:
##--------------------------------------------------------------------------------------------------------------
##--------------------------------------------------------------------------------------------------------------

# Color
color.global.infoBox <- "olive"
color.global.valueBox <- "orange"

server <- function(input, output, session) {
  
  # Stop running shiny app when closing browser window
  ## [How to stop running shiny app by closing the browser window?](https://stackoverflow.com/questions/35306295/how-to-stop-running-shiny-app-by-closing-the-browser-window)
  ## This is a bad idea! If multiple users are connected to the app, then one user (or browser tab) exiting will cause everyone to be kicked off! b
  #------------------------------------------------------------------------------------------------
  # Create functions for output
  ## [Create Function for output in Shiny](https://stackoverflow.com/questions/53590526/create-function-for-output-in-shiny)
  ## ["Correct" way to specifiy optional arguments in R functions](https://stackoverflow.com/questions/28370249/correct-way-to-specifiy-optional-arguments-in-r-functions)
  ## [How do you use "<<-" (scoping assignment) in R?](https://stackoverflow.com/questions/2628621/how-do-you-use-scoping-assignment-in-r)
  #------------------------------------------------------------------------------------------------
  # Define function for renderValueBox()
  function.renderValueBox <- function(output.id
                                      ,argument.value
                                      ,argument.subtitle
                                      ,argument.icon
                                      ,argument.icon.lib
                                      ,argument.color){
    # Write default values to optional arguments
    if(missing(argument.icon)){argument.icon <- "th-list"}
    if(missing(argument.icon.lib)){argument.icon.lib <- "glyphicon"}
    if(missing(argument.color)){argument.color<-"orange"}
    
    output[[output.id]] <<- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        value = argument.value
        ,subtitle = argument.subtitle
        #,icon = icon(argument.icon, lib = argument.icon.lib)
        ,color = argument.color)
    }) # Close renderValueBox()
  } # Close function{}
  
  # Define function for renderInfoBox()
  function.renderInfoBox <- function(output.id, arg.title, arg.value, arg.icon, arg.color, arg.fill){
    # Write default values to optional arguments
    if(missing(arg.icon)){arg.icon<-"list"}
    if(missing(arg.color)){arg.color<-"olive"}
    if(missing(arg.fill)){arg.fill <- TRUE}
    
    output[[output.id]] <<- shinydashboard::renderInfoBox({
      shinydashboard::infoBox(
        title = arg.title
        ,value = arg.value
        #,icon=icon(arg.icon)
        ,color = arg.color
        ,fill = arg.fill)
    }) # Close renderInfoBox()
  } # Close function{}
    
    #*****************************************
    # Outputs to use under menuItem "Crime"
    #*****************************************
  
    #--------------------------
    # Output dataTables
    #--------------------------
  output$dataTable.top10.offences.count.year.exclud.Other <- DT::renderDataTable({
    top10.offences.count.year.exclud.Other|> 
      dplyr::rename(Year=year
                    ,Offence=crime.name
                    ,Total=total)
    })
    output$dataTable.top10.offences.count.age.sex.exclud.Other <- DT::renderDataTable({
      top10.offences.count.age.sex.exclud.Other.1 <- top10.offences.count.age.sex.exclud.Other |>
        dplyr::select(crime.name, age.sex, count.percent, total) |>
        dplyr::rename(Offence=crime.name
                      ,Group=age.sex
                      ,`Count (%)`=count.percent
                      ,Total=total)
      })
    #--------------------------
    # Output plotly plots
    #--------------------------
    # Top 10 offences in each year
    output$plotly.top10.offences.count.year.exclud.Other <- plotly::renderPlotly({
      plotly::plot_ly( data = top10.offences.count.year.exclud.Other
                       ,x= ~year #total
                       ,y= ~total #year
                       ,group= ~crime.name
                       #,color= ~crime.name
                       #,name = ~crime.name
                       ,type = "bar"
                       ,orientation="v"
                       ,text=~total
                       ,textposition="auto"
                       ,hoverinfo="text"
                       ,hovertext=paste("Year :", top10.offences.count.year.exclud.Other$year
                                        ,"<br> Offence :", top10.offences.count.year.exclud.Other$crime.name
                                        ,"<br> Count :", top10.offences.count.year.exclud.Other$total)
                       ) |>
      plotly::layout(barmode="stack"
                     ,xaxis = list( title = 'Year'
                                   ,titlefont= list(size=50)
                                   ,tickvals= 2001:2021)
                     ,yaxis = list(title = 'Count'
                                   ,titlefont= list(size=50)
                                   #,categoryorder="array"
                                   #,categoryarray=top10.offences.count.age.sex.exclud.Other$year
                                   )
                     )
    })
    output$plotly.top10.offences.count.age.sex.exclud.Other <- plotly::renderPlotly({
        plotly::plot_ly( data=top10.offences.count.age.sex.exclud.Other
                      , x=~count
                      , y=~crime.name
                      , color = ~age.sex
                      , name = ~age.sex
                      , type = "bar"
                      , orientation="h"
                      , text=~total
                      ,textposition="auto"
                      ,hoverinfo="text"
                      ,hovertext=paste("Offence :",top10.offences.count.age.sex.exclud.Other$crime.name
                                       ,"<br> Group :",top10.offences.count.age.sex.exclud.Other$age.sex
                                       ,"<br> Count (%):", top10.offences.count.age.sex.exclud.Other$count.percent)
                      ) %>%
        plotly::layout( barmode="stack"
                        ,xaxis = list( title = 'Count'
                                      ,titlefont= list(size=50))
                        ,yaxis = list(title = 'Offence'
                                      ,titlefont= list(size=50)
                                      ,categoryorder="array"
                                      ,categoryarray=top10.offences.count.age.sex.exclud.Other$crime.name)
                        )
    }) # Close renderPlotly()
    output$text.align <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(tags$p(tags$span("Hello")
                                      ,tags$span("World!", style = "float:right")
                                      ,style ="color : black"), "Hi!")
    })
  
} # Close the server function

#************************************************************************************************#
#---------------------------------This is the end of this file ----------------------------------#
#************************************************************************************************#