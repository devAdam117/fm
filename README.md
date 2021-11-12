# Rebalancing model
- is usuful for stocks which has low risk or standard deviation
- is usually applied on daily basis
- model will make critical boundaries for each stock made by historical data 
- model indicates to sell when you cross critical up boundry
- modell indicates to buy when you cross critical down boundry
- model calculates with your wallet, if you don't have money to buy it won't recommend you to buy

## Prerequisites
- in R console type  install.packages("quantmod") and hit enter
- in R console type library(quantmod) and hit enter

## Function explained
- in R type rebalance(stocks,amountOfStocks,wallet,monthsToLearn)
- ### stocks
  - typeOf: vector of strings 
  - write all stocks symbols you want to rebalance 
  - example: c("AAPL","AMC","TSLA") or for single one: "AAPL"
- ### amountOfStocks 
  - typeOf: vector of integres
  - are paired with stocks (first parameter of function)
  - write all numbers of already owned stocks for each  stock from first argument
  - example: c(10,5,10) (meaning you have 10 stocks of "AAPL", 5 of "AMC", 10 of "TSLA") or for single one: 10 (meaning you have 10 stocks of "AAPL")
- ### wallet
  - typeOf: number 
  - write total amount of money that is ready to invest
  - example: 500
 - ### monthsToLearn
  - typeOf: integer
  - write number of historical month of stocks for which should model learn, make critical lines and all other stuff till the end of evaluation. (Different monthsToLearn can lead to different result of recommendation)
  - example: 6
  
  

## How the process works after running script?
|Initiation|Convertion|Setting Critical Boundries|Checking Todays Crossover|Checking Trend|
|-------------|-------------|-------------|-------------|-------------|
|Get the latest adjPrice of stock/s for past n-months you have entered as argument in function|From adjData we make highly correlated 3 dimensionals vectors from which we make mean values devided by the first element of the same vector (Explained in (a))|For highly correlated vector are created critical boundries which will indicates, whether sell or buy|Now we are checking whether the newest vector is over/below up/down critical line if so we pick vector right before this one and we will check if he is over/below up/down critical line also (Explained in (b))|If (b) is TRUE then model checks for the angle between newest two points and compare it to mean of all angles of all two points combination, the more significant difference between these two is, the bigger recommendation give us model to sell or buy stock|
|![1](https://user-images.githubusercontent.com/78803735/141456206-7501a8a1-7201-46f3-8311-63192b488e4f.jpg)|![2](https://user-images.githubusercontent.com/78803735/141457030-5ca2a221-9c9e-4431-8fd5-6b8c004e8e73.jpg)|![3](https://user-images.githubusercontent.com/78803735/141457870-5982b5f5-edea-44b4-941a-ce8de1c964d1.jpg)|![4](https://user-images.githubusercontent.com/78803735/141464584-bd814776-88ac-4051-8a04-99ac06121180.jpg)|![5](https://user-images.githubusercontent.com/78803735/141467450-bc6a10e3-693d-4497-a251-b0fdcddb2d7d.jpg)|

### (a)
We have n adjClose data of stock ,naming them adjClose_1, adjClose_2, ..., ajClose_n. From this we will make highly correlated 3 dimensional vectors v_1,v_2,...,v_n-2
where v_i = (adjClose_i, adjClose_{i+1},adjClose_{i+2}). For the final step we create new vector x, where x_i = v_i/adjClose_i and the plot of x is mentioned in the table.
### (b)
- If the newest x_n crossover over top line we check if x_{n-1} is bellow top line if so, we can continue in our proccess else the execution ends here. Reason is that the previous point is also above top line so we asume our script already sold some amount of stocks "yesterday" or the day when x_{n-1} was the newest value.
- If the newest x_n crossover bellow bottom line we check if x_{n-1} is above bottom line if so, we can continue in our proccess else the execution ends here. Reason is that the previous point is also bellow bottom line so we asume our script already bought som amount of stocks "yesterday" or the day when x_{n-1} was the newest value.









