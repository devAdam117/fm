# Rebalancing model
- is usuful for stocks which has low risk or standard deviation
- model will make critical boundaries for each stock made by historical data 
- model indicates to sell when you cross critical up boundry
- modell indicates to buy when you cross critical down boundry

##Prerquisites
- in R console type  install.packages("quantmod") and hit enter
- in R console type library(quantmod) and hit enter
- 
### How the process works?
|Initiation|Convertion|
|-------------|-------------|
|Get the latest adjPrice of stock/s for past n-months you have entered as argument in function|From adjData we make highly correlated 3 dimensionals vectors from which we make mean values devided by the first element of the same vector
*1|
|![1](https://user-images.githubusercontent.com/78803735/141456206-7501a8a1-7201-46f3-8311-63192b488e4f.jpg)|![2](https://user-images.githubusercontent.com/78803735/141457030-5ca2a221-9c9e-4431-8fd5-6b8c004e8e73.jpg)
|

