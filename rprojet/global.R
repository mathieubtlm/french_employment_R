#import des libraries
library(shiny)
library(gapminder)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(plyr)
library(geojsonio)
options(encoding = "UTF-8")

##Ouverture des csv en dataframe (la gestion de l'encodage est réalisé grace à option plus haut)

salaries=as.data.frame(read.csv("net_salary_per_town_categories.csv"))
geoinf=as.data.frame(read.csv("name_geographic_information.csv"))
firm=as.data.frame(read.csv("base_etablissement_par_tranche_effectif.csv"))

#NETOYAGE DONNEES FIRM (séparation des entreprises en tpe, pme, ete et gi et la représentation de ces données en pourcentages)
firm$tpe=firm$E14TS1+firm$E14TS6
firm$pme=firm$E14TS10+firm$E14TS20+firm$E14TS50+firm$E14TS100
firm$etige=firm$E14TS200+firm$E14TS500
firm$totalwithoutunk=firm$E14TS1+firm$E14TS6+firm$E14TS10+firm$E14TS20+firm$E14TS50+firm$E14TS100+firm$E14TS200+firm$E14TS500 #nous avons écarté les entreprises de taille nulle ou inconnue pour la suite de notre trvail
firm$tpepercent = firm$tpe*100/firm$totalwithoutunk
firm$pmepercent = firm$pme*100/firm$totalwithoutunk
firm$etegipercent = firm$etige*100/firm$totalwithoutunk
firm<-subset(firm, select=-c(E14TS1,E14TS6,E14TS10,E14TS20,E14TS50,E14TS100,E14TS200,E14TS500))#supression ancienne colonne

#NETOYAGE GEOINF(supression données manquantes ou incorecte, passage d'acgument en numeric)

geoinf<-geoinf%>%filter(longitude!='-')
geoinf$lat<- as.numeric(geoinf$latitude)
geoinf$long<- as.numeric(geoinf$longitude)
geoinf <- filter_at(geoinf, vars('lat', 'long'), all_vars(!is.na(.)))
geoinf<-distinct(geoinf,code_insee, .keep_all=TRUE)#supression des code insee dupliqué (on en garde 1)
names(geoinf)[c(3,6)] <- c('nomregion','nomdepartement')#on renomme de colonne pour plus de facilité dans nos appel plus tard


#### merge de geoinf et firm sur le code insee et passage de nom region et nom departement en facteur
df<-as.data.frame(merge(firm, geoinf, by.x="CODGEO", by.y="code_insee"))
df$nomdepartement <- as.factor(df$nomdepartement)
df$nomregion <- as.factor(df$nomregion)

### ici on crée un dataframe qui nous donne le nombre d'entreprise par région et le pourcentage que ca represente par rapport au nombre totale d'entreprise
s<-aggregate(df[,'totalwithoutunk'], by=list(df$nomregion) ,FUN=sum)
s$percent<-s$x/sum(s$x)*100

###### Nettoyage donnée salaries 

#comme pour le dataframe précédent
salaries$CODGEO <- as.numeric(as.character(salaries$CODGEO))
salaries<-salaries%>%distinct(CODGEO, .keep_all=TRUE)

#ici on renomme nos collones pour plus de lisible
names(salaries) <- c("CODGEO",
                      "LIBGEO",
                      "mean_net_salary",
                      "executive",
                      "middle_manager",
                      "employee",
                      "worker",
                      "women",
                      "feminin_executive",
                      "feminin_middle_manager",
                      "feminin_employee",
                      "feminin_worker",
                      "man",
                      "masculin_executive",
                      "masculin_middle_manager",
                      "masculin_employee",
                      "masculin_worker",
                      "18-25_years_old",
                      "26-50_years_old",
                      ">50_years_old",
                      "women_between_18_25_years_old",
                      "women_between_26_50_years_old",
                      "women_>50_years_old",
                      "men_between_18_25_years_old",
                      "men_between_26_50_years_old",
                      "men_>50_years_old")

#création d'un dataframe avec les moyennes pour chaque catégories de salaries

x<- salaries[, c("executive",
                 "middle_manager",
                 "employee",
                 "worker",
                 "women",
                 "feminin_executive",
                 "feminin_middle_manager",
                 "feminin_employee",
                 "feminin_worker",
                 "man",
                 "masculin_executive",
                 "masculin_middle_manager",
                 "masculin_employee",
                 "masculin_worker",
                 "18-25_years_old",
                 "26-50_years_old",
                 ">50_years_old",
                 "women_between_18_25_years_old",
                 "women_between_26_50_years_old",
                 "women_>50_years_old",
                 "men_between_18_25_years_old",
                 "men_between_26_50_years_old",
                 "men_>50_years_old"
)]
mean<-as.data.frame(colMeans(x))

#Pour le moment nos catégories son groupé dans des nom d'index
#On va ajouter des colonnes age, job, sexe pour pouvoir avoir accès à toute les données de manière indépendante par facteur

names(mean)[names(mean) == "colMeans(x)"] <- "meansalary"
mean[c("executive","feminin_executive","masculin_executive"),"job"]="executive"
mean[c("middle_manager","feminin_middle_manager","masculin_middle_manager"),"job"]="middle_manager"
mean[c("employee","masculin_employee","feminin_employee"),"job"]="employee"
mean[c("worker","feminin_worker","masculin_worker"),"job"]="worker"
mean[c( "women",
        "feminin_executive",
        "feminin_middle_manager",
        "feminin_employee",
        "feminin_worker",
        "women_between_18_25_years_old",
        "women_between_26_50_years_old",
        "women_>50_years_old"),"sexe"]="women"
mean[c( "man",
        "masculin_executive",
        "masculin_middle_manager",
        "masculin_employee",
        "masculin_worker",
        "men_between_18_25_years_old",
        "men_between_26_50_years_old",
        "men_>50_years_old"),"sexe"]="men"
mean[c("18-25_years_old","women_between_18_25_years_old","men_between_18_25_years_old"),"age"]="18-25"
mean[c("26-50_years_old","women_between_26_50_years_old","men_between_26_50_years_old"),"age"]="26-50"
mean[c(">50_years_old","women_>50_years_old","men_>50_years_old"),"age"]=">50"
mean$job=as.factor(mean$job)
mean$sexe=as.factor(mean$sexe)
mean$age=as.factor(mean$age)

############ lecture du geojson contenant les donnée géographique nécessaire à notre cloropleth map dans une variable dep
dep <- geojsonio::geojson_read("departements.geojson", what = "sp")
############ création d'un dataframe qui nous donne les salaires moyen par département ainsi que les donnée géographique associé

map2<-as.data.frame(merge(salaries[,c("CODGEO","mean_net_salary")], geoinf, by.x="CODGEO", by.y="code_insee"))
depmean<-aggregate(map2[,'mean_net_salary'], by=list(map2$nomdepartement) ,FUN=mean)
names(depmean)<-c("nom","mean")

####### on va ajouter les salaires moyen correspondant au deépartement dans dep, seulement pour qu'ils correspondent bien au données géographique
####### associé il faut insérer c'est donnée dans le bonne ordre

ordre<-dep@data$code #on conserve donc cette ordre ici
databis<-as.data.frame(merge(dep@data,depmean, by.x="nom", by.y="nom")) #on crée un dataframe avec les donnée de dep plus les salaires moyen 
dep@data<-databis %>%
  slice(match(ordre, code))#on ajoute ce dataframe dans l'ordre précis conservé plu tôt


