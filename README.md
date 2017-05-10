# Project Prototype: Las Vegas Yelp Restaurant Visualizations
### Team:
    Yige Liu : yliu225@usfca.edu
    Anshika Srivastava : asrivastava3@usfca.edu
    
### Instructions

The following packages must be installed prior to run this code:

  - ggplot2
  - shiny
  - reshape
  - tidyr
  - leaflet
  -wordcloud2

To run this code, please enter the following commands in R:

shiny::runGitHub("legendary_legends-final", "usfviz")
### Dataset 
Yelp data is taken from https://www.yelp.com/dataset_challenge
It mainly contains all business data (filtered the restaurant data), check in data, user data and review data. The data is in JSON format. We converted them to CSV. There were some missing neighbourhoods, which were removed.
### Discussions
Below are screenshots of the interface of the shiny app.
![alt text](screenshot3.png)
![alt text](screenshot4.png)

### Techniques
#### Las Vegas Map

Geospatial map to indicate the distribution of restaurant by category and by popularity. The popularity (total number of reviews) is represented by the size of point and average is shown by color.

#### Bar chart
A Bar chart of distribution of restaurants by Neighborhood. The hover on the plot can give valuable information like avergae score in that neighbourhood, total number of restaurants in the neighbourhood etc. 

#### Heat Map
 To show the density of restaurants in each neghbourhood by the category/cuisine

#### Word cloud
It shows the yelp reviews for the selected star/review






