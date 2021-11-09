                                            ## User Guide

Bienvenue sur notre Dashboard.

Avant de démarer il serra nécessaire d'installer les packages suivant :
install.packages(c('shiny,'shinydashboard','leaflet','gapminder','plotly','plyr','tidyverse', 'devtools','shinyWidgets'))

Ensuite pour lancer le dashboard placez-vous dans le répértoire du projet et tapez " runApp(getwd()) "
Le dashboard sera visible à l'adresse http://127.0.0.1:8050/

Vous êtes maintenant devant notre dashboard, vous pouvez intéragir avec la sidebar pour vous déplacez dans les 3 pages du dashboard.
N'hésitez pas à utiliser les input comme la slidebar ou les select implémentés pour mieux profiter des maps et graphiques.


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 ##Rapport D'analyse 

La question de l'accès à l'emploi ainsi que des inégalités dans le monde tu travail est aujourd'hui centrale dans notre société.
Nous allons essayer de visualiser si trouver un emploi est plus ou moins facile en fonction de notre localisation ? 
Ece que notre âge influe sur notre salaire ? Le genre peut t-il avantager ou désaventager ? 
Le salaire est t-il répartit de manière simillaire sur tout le territoire ?

Sur la première page de notre dashboard on voit avec la carte et un barplot que les région et département ne sont pas du tout loger à la même enseigne. 
La concentration d'entreprise est drastiquement supérieur dans les endroits proche de la mer, des frontières et de la capitale.
De plus quand on observe la map on peut constater que la diagonale du vide est une zone connue pour sa population plus faible mais c'est aussi 
le cas pour la quantité d'entreprise.


On peu à présent se demander si cet différence se ressent aussi dans les salaires des français ?

Sur la deuxième parti du dashboard on voit clairement sur l'histogramme une différence drastique entre la moyenn qui est de ... euros par heure et les villes les mieux payées.
La majorité du territoire se situe au alentour de cet moyenne mis à part au alentour de quelque ville qui se démarque légerment.
Ce qui a du attirer votre attention tout de suite en revanche c'est l'écart drastique à paris qui à une moyenne à 22,2. Cette statisques doit être nuancé avec 
le coup de la vie qui y est bien plus cher cependant l'écart reste notable. Il est aussi intéressant de remarquer à quel point
paris rayonne sur l'île de france qui à des valeur bien plus élevé que la moyenne.

On a donc vu que les clichés sur l'accès à l'emploi et les salaires s'avèrent plutôt vrais. Quant est t'il des inégalité entre les femmes et les hommes ?

Dans la troisième page du dashboard vous pouvez choisir de comparer le salaire entre homme et femme en fonction de la tanche d'âge et du type métier.
Malheureusement on se rend compte que peut importe le type de métier les hommes sont systématiquement mieux payer. Pire encore, quand on affiche toutes les tranches d'âge
on voit que les inégalités entre homme et femme on tendance à s'empirer.
Concernant l'âge, sans surprise on observe que le salaire évolue et grandit avec l'âge


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        
                                                                    ##Developper Guide

Le code est structuré en 3 fichiers : 

				      global.R <- ouverture csv, traitement des données
 				      ui.R<- interface utilisateur
				      app.R<- côté serveur de l'app 

les données des input réactifs de la partie ui renvoit des informations à la partie serveur, les séléctions de données sont gérées dans dest output$nomoutput <- reactive({})
et ces output sont ensuite utilisé pour réaliser les plot et map. reactive permet une recalculation de l'output à chaque fois que l'user interagit avec les input de la partie ui.

Les données proviennent de kaggle : https://www.kaggle.com/etiennelq/french-employment-by-town

Pour améliorer/étendre l'analyse de ce dashboard, l'utilisation de populations.csv pourrait permettre de mettre en perspective nos résultat
avec une analyse de la population française.

 

