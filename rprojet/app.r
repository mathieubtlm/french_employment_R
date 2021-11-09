#import
library(shiny)
library(shinydashboard)
source('global.R')
library(leaflet)
library(gapminder)
library(plotly)
library(plyr)
library(tidyverse)
library(devtools)
library(shinyWidgets)
options(encoding = "UTF-8")





ui <- dashboardPage(
  skin="blue",  #theme de la page
 
   dashboardHeader(
    titleWidth=300,
    tags$li(class = "dropdown",
            tags$style(".main-header {max-height: 80px}"),
            tags$style(".main-header .logo {height: 80px}")
                  ),

                  title = h1("Dashboard")
                  ),#header dropdown legerement plus gros que celui de base
  
  ###Sidebar contenant 3 pages et des input
  dashboardSidebar(
    tags$style(".left-side, .main-sidebar {padding-top: 80px}"),
    width=300,#padding pour pas dépasser sur le headeur et sidebar plus large
    
    sidebarMenu(
      
      #dans les menuItem le tabname nous permettra d'acceder à la page dans tabItem dans le body
      menuItem(h3("Répartition des entreprise"), tabName = "1"),
      shinyWidgets::sliderTextInput(inputId ="slider1", label = h5("Number of firm by town"),
                  choices = c(1,50,200,500,1000,1500,2000,2500,3500,4000,4500,6000,10000,111000),
                  selected=c(2000,111000)
                  ),#shynyWidgets vas nous permettre d'ajuster la slideBar comme on le souhaite, la slidebar sera utiliser pour regler le nombre de firm par ville sur notre map


      menuItem(h3("Visualisation salaire"), tabName = "2"),
      menuItem(h3("Inégalités"), tabName = "3"),
      fluidRow(
        selectInput("selectage", h5("Select age"),
                    choices = list("18-25" ='18-25', "26-50" = '26-50','>50'='>50','all'='all'), selected = 'all'),
        selectInput("selectjob", h5("select type of job"),
                    choices = list("employee" ='employee', "executive"='executive','middle_manager'='middle_manager', 'worker'='worker','all'), selected = 'all'))

      )#deux select input qui permettent de régler l'age et le type de métier dans nos barplot
    #on recuperera les données des input avec la structure input$Idinput dans notre partie serveur
  ),
  
  ####Partie principale de notre dashboard, chaque tabItem s'affiche selon le menuItem sur le quel à cliqué l'user
  dashboardBody(

    tags$head(tags$style(HTML('
      .content-wrapper {
        background-color: #ffffff;
      }
    '
    ))),
#####On utilise des box pour gerer ou sont nos sorties
#### les output renvoient les plot et graph de la partie serveur
    tabItems(
      tabItem(tabName = "1",

              box(
                fluidRow(leafletOutput('mymap',height="1000px",width="100%")),
                title = "Carte répertoriant le nombre d'entreprise par ville", status = "primary", solidHeader = TRUE,
                background = "light-blue",
                collapsible = TRUE,
                width=6,
                height=1000),
              
              box(
                fluidRow(plotOutput('barplot',height="1000px",width="100%")),
                  title = "Classement des régions en fonction du pourcentage des entreprises françaises présentent",
                             solidHeader = TRUE,
                             background = "light-blue",
                collapsible = TRUE,
                width=6,
                height=1000
                  )
                  
      ),


    # Second tab content
    tabItem(tabName = "2",

            box(
              title = "Carte répertoriant le salaire/h moyen par département", status = "primary", solidHeader = TRUE,
              background = "light-blue",
              collapsible = TRUE,
              leafletOutput('salaire'),
              width = 12
            ),

               box(
                 numericInput("bin", "Ajustement des bins", value = 0.3, min = 0.1, max = 1),
                 solidHeader = TRUE,
                 background = "light-blue",
                 plotOutput('histsalary'),
                 width=12


            )
    ),

    tabItem(tabName = "3",
            
              box(plotOutput('barplotage',height="480px",width="100%"),width=12,height=500,solidHeader = TRUE,
                  background = "light-blue"),
              box(plotOutput('barplotjob',height="480px",width="100%"),width=12,height=500,solidHeader = TRUE,
                  background = "light-blue")

    )
  )
)
)

    



############ partie serveur qui génère les map et plot


server <- function(input, output, session) { 
  
  #####dataframe reactif selon la sliderbar de la première page, on l'utilisera pour avoir le nombre de firm par ville dans notre map
  sliderData <- reactive({
    subset(df, totalwithoutunk >= input$slider1[1] & totalwithoutunk <= input$slider1[2])
  })
  
  ### les deux reactive suivant donne les dataframe du salaire moyen selon l'age, le job et le sex suivant les envies de l'utilisateur
  selectage<- reactive(
    {
      if (input$selectage=="all") {
        mean[!is.na(factor(mean$age)) &  !is.na(factor(mean$sexe)), ]
      } else {
        mean[  factor(mean$age)==input$selectage &  !is.na(factor(mean$sexe)), ]%>%drop_na(meansalary)
      }
      
      
    }  
)
  
  selectjob<- reactive(
    {
      if (input$selectjob=="all") {
        mean[!is.na(factor(mean$job)) &  !is.na(factor(mean$sexe)), ]
      } else {
        mean[  factor(mean$job)==input$selectjob &  !is.na(factor(mean$sexe)), ]%>%drop_na(meansalary)
      }
      
      
    }  
  )
  
  ########Barplot de comparaison salaire moyen homme femme
  output$barplotage <- renderPlot(
    {
        age<-selectage()#variable qui récupère le dataframe reactif précèdent
        ggplot(data =age, aes(x = factor(age), y = as.numeric(format(round(meansalary, 2)), nsmall = 2), fill = sexe)) + #choix données
        
        geom_bar(stat="identity", position = "dodge") + #réglage du barplot
        scale_fill_brewer(palette = "Set2") + #choix couleur
        
        geom_text(data=age, aes(x = factor(age), label = format(round(meansalary, 2), nsmall = 2)), size = 4, stat="identity", 
                  position = position_dodge(width = 0.9), vjust = -0.25) + #affiche les valeurs sur le graph
        
        ggtitle("Average Mean Net Salary for each Age and Gender Group") +
        labs(x="Age",y="Mean Net Salary") + 
        scale_y_continuous(limits=c(0,18))+
          theme_light() #titre et thèmes 
  }
)
##### exactement le même principe que le barplot précèdent mais avec le dataframe réactif des job
  output$barplotjob <- renderPlot(
    {
      job<-selectjob()
      ggplot(data =job, aes(x = factor(job), y = as.numeric(format(round(meansalary, 2)), nsmall = 2), fill = sexe)) + 
        
        geom_bar(stat="identity", position = "dodge",) + 
        scale_fill_brewer(palette = "Set2") +
        
        geom_text(data=job, aes(x = factor(job), label = format(round(meansalary, 2), nsmall = 2)), size = 4, stat="identity", 
                  position = position_dodge(width = 0.9), vjust = -0.25) +
        
        ggtitle("Average Mean Net Salary for each job and Gender Group") +
        labs(x="job",y="Mean Net Salary") + 
        scale_y_continuous(limits=c(0,30))+
        theme_light()
    }
  )
  
  #######map du nombre de firm par ville avec buble plus ou moins grosse, échelle de couleur et slidebar
  output$mymap <- renderLeaflet({
    
      qpal <- colorQuantile("RdYlBu", sliderData()$totalwithoutunk, n = 3)#échelle de couleur en quantiles
    
      map<-leaflet(data=sliderData(),#recupère le dataset de la slidebar
              options=leafletOptions(attributionControl=FALSE
        ))%>%
        addProviderTiles(providers$OpenStreetMap.France)%>%
        setView(lng = 2.80, lat = 46.80, zoom = 5)%>%#on fait un fond de map de la france et on centre dessus avec setView
        addCircleMarkers(lng=~long,lat=~lat,weight=1, radius =~sqrt(totalwithoutunk)/10,
                         color = ~qpal(totalwithoutunk),
                         fillOpacity = 0.7
                         )%>%#ajout des cercles en fonction du nombre d'entreprises dans la ville
        addLegend(pal = qpal, values = ~totalwithoutunk, opacity = 1,title = ("division en 3 quantiles"))%>%
        addScaleBar(position='bottomleft')%>%
        addMiniMap(width = 100,
                  height = 100,
                  tiles = providers$OpenStreetMap.France,
                  toggleDisplay = TRUE)#ajout de quelque feature comme la minimap et une légende 

      })
      
  output$barplot <- renderPlot({
    s%>%
      mutate(reg = fct_reorder(Group.1, x)) %>%
      ggplot( aes(x=reg, y =percent)) +
      geom_bar(stat="identity",fill="#4897C0", width=.9)+
      coord_flip() +
      theme_classic()
  }
    )
  
  ##### histogramùe des salaires de notre jeux de données
  output$histsalary<- renderPlot(
    {
      str(salaries)
  ggplot(salaries, aes(x =mean_net_salary)) +
    geom_histogram(binwidth=input$bin,fill="#4897C0",color="white")+
    ggtitle("test")+
    scale_y_continuous(
      trans='log'#on utilise un log pour des questions de lisibilités du graph
    ) +
    scale_x_continuous(
      breaks = c(10,15,mean(salaries$mean_net_salary),20,25,30,35,40)
    ) +
    geom_vline(aes(xintercept=mean(mean_net_salary)),
               color="black", linetype="dashed", size=1)+#on ajoute une ligne représentant la moyenne
    theme_light()
    }
  )
  
  
  ####map cloropleth des salaires en fonction du departement
  output$salaire<- renderLeaflet(
    {
  pal <- colorBin("Blues", domain = dep@data$mean, 4, pretty = FALSE)#échelle de couleur

  m <- leaflet(dep) %>%
    setView(lng = 2.80, lat = 46.80, zoom = 5) %>%
    addTiles()

  m %>% addPolygons(fillColor = ~pal(dep@data$mean),#ajout des limites des département en utilisant l'échelle de couleur en foction du salaire moyen
                    weight = 2,
                    opacity = 1,
                    color = "white",
                    dashArray = "3",
                    fillOpacity = 0.7)%>%
    addLegend(pal = pal, values = ~mean, opacity = 1,title = ("legende"))
    })
}

shinyApp(ui, server)