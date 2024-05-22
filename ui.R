#----------------------------------------------------------------------------------------------------------------
# Program: C:/GoogleDrive/scripts/R-Shinyapp_data-gov-au_police/ui.R
# Date created: 17-May-2024
# Author(s): Lun-Hsien Chang
# Modified from: C:/GoogleDrive/scripts/R-shinyapp_internet-speed-test/ui.R
# Dependency:
# Input: [barcode-scan.gsheet](https://docs.google.com/spreadsheets/d/1hnIOmXw6s56lX-J7IEY3SUBHM2ySd3Usn82bQNxruto/edit?usp=sharing)
# Output: https://luenhchang.shinyapps.io/internet-speed-test/
# References
## [Horizontal Rule hr() in R Shiny Sidebar](https://stackoverflow.com/questions/43592163/horizontal-rule-hr-in-r-shiny-sidebar)
## Date       Changes:
##---------------------------------------------------------------------------------------------------------------
## 2024-05-20 Deployed app to https://luenhchang.shinyapps.io/data-gov-au_police/
##---------------------------------------------------------------------------------------------------------------

#---------------------------------
# Webpage title on top left corner
#---------------------------------
#application.title <- "Data in everyday lives"
application.title <- tags$a(href="#top" # A destination to go to. Can be a URL or locations in this app 
                            ,icon('chart-line')
                            ,"Queensland Crime Trends")

#--------------------------------------------
# Define dashboardPage() function components
## Reference [https://stackoverflow.com/questions/67237358/set-font-size-and-color-in-title-of-shinydashboard-box](https://stackoverflow.com/questions/67237358/set-font-size-and-color-in-title-of-shinydashboard-box)
## [R-Shiny-Dashboards/USArrestDashboard/ui.R](https://github.com/aagarw30/R-Shiny-Dashboards/blob/main/USArrestDashboard/ui.R)
#--------------------------------------------
header <- shinydashboard::dashboardHeader(
  title = application.title
  ,titleWidth = 650
  ,tags$li(class="dropdown"
           ,tags$a(href="https://www.linkedin.com/in/lunhsienchang/", icon("linkedin", "My profile", target="_blank")))
  )

sidebar <- shinydashboard::dashboardSidebar(
  width = 200
  ,shinydashboard::sidebarMenu(
    # Change font size to 30
    ## Reference [shinydashboard: change font size of menuItem in sidebarMenu [duplicate]](https://stackoverflow.com/questions/53559195/shinydashboard-change-font-size-of-menuitem-in-sidebarmenu)
    tags$style(HTML(".sidebar-menu li a { font-size: 20px; }"))
    ,shinydashboard::menuItem(text = "Crime Stat", tabName = "tabCrime", icon = icon("chart-line"))
  )
)

body <- shinydashboard::dashboardBody(
  shinydashboard::tabItems(
    #************************************
    # menuItem "Crime"
    ## [How to have shiny dashboard box fill the entire width of my dashbaord](https://stackoverflow.com/questions/70689513/how-to-have-shiny-dashboard-box-fill-the-entire-width-of-my-dashbaord)
    ## [Set font size and color in title of shinydashboard box](https://stackoverflow.com/questions/67237358/set-font-size-and-color-in-title-of-shinydashboard-box)
    #************************************
    shinydashboard::tabItem(
      tabName = "tabCrime"
      ,fluidRow(
        box(
          title = HTML(
            paste("A: Top 10 most common offences from 2001 to 2021 in Queensland"
                  ,"<br> Other * offences not included")
          )
          ,status = "primary"
          ,width = 12
          ,solidHeader = TRUE
          ,collapsible = TRUE
          ,plotly::plotlyOutput(outputId = "plotly.top10.offences.count.year.exclud.Other", width = "100%", height = "100%")
        ) # Close box()
      ) # Close fluidRow()
      ,fluidRow(
        box(
          title = HTML(
            paste("B: Top 10 most common offences in 6 age and sex groups from 2001 to 2021 in Queensland"
                  ,"<br> Other * offences not included")
          )
          ,status = "primary"
          ,width = 12
          ,solidHeader = TRUE
          ,collapsible = TRUE
          ,plotly::plotlyOutput(outputId = "plotly.top10.offences.count.age.sex.exclud.Other", width = "100%", height = "100%")
        ) # Close box()
      ) # Close fluidRow()
      ,fluidRow(
        box(
          title = "Data used by plot A"
          ,status = "primary"
          ,width = 4
          ,solidHeader = TRUE
          ,collapsible = TRUE
          ,DT::dataTableOutput(outputId = "dataTable.top10.offences.count.year.exclud.Other"
                               , width = "100%"
                               , height = "100%")
          ) # Close box()
        ,box(
          title = "Data used by plot B"
          ,status = "primary"
          ,width = 5
          ,solidHeader = TRUE
          ,collapsible = TRUE
          ,DT::dataTableOutput(outputId = "dataTable.top10.offences.count.age.sex.exclud.Other"
                               , width = "100%"
                               , height = "100%")
        ) # Close box()
      )# Close fluidRow()
    ) # Close tabItem()
  ) # Close tabItems
) # Close dashboardBody()

#-------------------------------------------------------------------------------------
# User interface by shinydashboard
## The dashboardPage() function expects three components: a header, sidebar, and body:
## References [shinydashboard](https://rstudio.github.io/shinydashboard/index.html)
#-------------------------------------------------------------------------------------
ui <- shinydashboard::dashboardPage(
  title = "Everyday Data" # A title to display in the browser's title bar. If no value is provided, it will try to extract the title from the dashboardHeader.
  #title = span(tagList(icon("calendar")),"Everyday Data")
  ,header=header
  ,sidebar=sidebar
  ,body=body
  ,skin = "black")

#************************************************************************************************#
#---------------------------------This is the end of this file ----------------------------------#
#************************************************************************************************#