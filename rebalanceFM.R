
# natalia -> rebalance(c("BOLT","RDS-B","F","LI","DAL","WMT","CVX","KO","VWAGY","NSRGY"),c(1000,225,511,326,229,67,87,175,302,70),55.37,3)
# ja -> rebalance(c("AMZN","PFE","DELL","NSRGY","NVDA","MDC","MSFT","VWAGY","EBAY","RDS-B","KO","BA","WMT","DAL","PEP","IBM","F","MMM","SBUX","TM","ADBE","AMD","TSM","TSLA","MA","V","COIN","BOLT","PYPL","LI"),c(1,69,60,25,11,65,10,101,45,74,58,15,22,75,20,27,166,18,29,18,5,22,27,3,9,15,9,287,14,91),43.70,6)


#1)  napis  do konzoly iba a daj enter - "install.packages("quantmod")"
#2) napis do konzoly a daj enter  - "library(quantmod)"
#3) potom naitaj tento skript, a nasledne zavolaj funkciu rebalance(), hore mas prikaz ktory mozes aktualne pouzit
#4) parametre funkcie 1. nazvy skratiek firiem s ktorymi chces pracovat, 2. argument, kolko mas kupenych akcii akej firmy, 3. argument kolko mas nezainvestovanych penazi?
# pripravenych na investiciu, 4. argument ake casove obdobie v mesiacoch beries v uvahu pre kazdu z firiem? Priklad spustenia rebalance( c("AMZN","PFE"),(10,35),1000,6)
#5) s tym ze po kazdom spusteni rebalancu poprehadzuj na stock trader tak ako ti vypise konzola a potom, pri dalsom spusteni prepis parametre pri volani funkcie
# teda ak ti konzola povedala ze predaj jednu akciu "AMZN" dalsie volanie rebalance bude vyzerat takto:  rebalance( c("AMZN","PFE"),(9,35),nova suma, ktoru ti ukazuje stack trader,6)


rebalance <- function(names,aoStocks,budget,monthsToCalculate){
  #check for length
  if(length(names)!=length(aoStocks)){
    return("Length of first and second parameters must be the  same!")
  }
 
  for(index in 1:length(names)){
    adjClose <- getSymbols(names[index], from = seq(as.Date(Sys.Date()), length = 2, by = paste(paste("-",monthsToCalculate , sep=""),"months", sep=" "))[2], 
                            to = Sys.Date(), warnings = FALSE, auto.assign = FALSE)[,4]
    
    latestPrice <- adjClose[length(adjClose)]
    degreesVector <- c() # for num of selling/buying purposes
    meanVector <- c() # average 3 days vector
    #fill thosevectors with data
    for(i in 1:(length(adjClose)-2)){
      meanVector <- c(meanVector, mean(adjClose[i:(i+2)])/adjClose[i])
      if(i>1){
        degreesVector <- c(degreesVector, meanVector[i]-meanVector[i-1])
      }
    }
    
    #extract important constant from vector for model
    degreesUp <- atan(median(degreesVector[degreesVector >=0]))  #avg increasment across every 3day vector  in degrees 
    degreesDown <- atan(median(degreesVector[degreesVector <=0])) #avg decreasment across every 3day vector  in degrees 
    criticalUpLine <- mean(meanVector[meanVector>=1])   #line when we are buying
    criticalDownLine <- mean(meanVector[meanVector<1])  #line when we are selling
    
    #draw plot only if we are rebalancing one
    if(length(names)==1){
    plot(meanVector, type="l")
    abline(a=criticalUpLine, b=0)
    abline(a=criticalDownLine, b=0)
    }
    
    #selling case
    if(meanVector[length(meanVector)]>= criticalUpLine){
      # if its under 
      if(meanVector[length(meanVector)-1]< criticalUpLine){
        #if previous 3vector is above go to buying algorithm ,else do nothing because
        #we did the work 3 days ago
        #compare tangent of average over sime time and past 2 vectors
        stocksToSell <- round(1 - (degreesUp/ atan(meanVector[length(meanVector)]-meanVector[length(meanVector)-1])), digits=0)
        if(stocksToSell<0){
          stocksToSell=aoStocks[index] 
        }
        budget= budget + stocksToSell*latestPrice
        print( paste("SELL", names[index],", amount: " , stocksToSell ,sep=" "))
      }
    }
    
    
    
    
      
  }
  for(index in 1:length(names)){
    adjClose <- getSymbols(names[index], from = seq(as.Date(Sys.Date()), length = 2, by = paste(paste("-",monthsToCalculate , sep=""),"months", sep=" "))[2], 
                           to = Sys.Date(), warnings = FALSE, auto.assign = FALSE)[,4]
    
    latestPrice <- adjClose[length(adjClose)]
    degreesVector <- c() # for num of selling/buying purposes
    meanVector <- c() # average 3 days vector
    #fill thosevectors with data
    for(i in 1:(length(adjClose)-2)){
      meanVector <- c(meanVector, mean(adjClose[i:(i+2)])/adjClose[i])
      if(i>1){
        degreesVector <- c(degreesVector, meanVector[i]-meanVector[i-1])
      }
    }
    
    #extract important constant from vector for model
    degreesUp <- atan(median(degreesVector[degreesVector >=0]))  #avg increasment across every 3day vector  in degrees 
    degreesDown <- atan(median(degreesVector[degreesVector <=0])) #avg decreasment across every 3day vector  in degrees 
    criticalUpLine <- mean(meanVector[meanVector>=1])   #line when we are buying
    criticalDownLine <- mean(meanVector[meanVector<1])  #line when we are selling
    
    #draw plot only if we are rebalancing one
    if(length(names)==1){
      plot(meanVector, type="l")
      abline(a=criticalUpLine, b=0)
      abline(a=criticalDownLine, b=0)
    }
  
    #buying case
    if(meanVector[length(meanVector)]<= criticalDownLine){
      # if its under 
      if(meanVector[length(meanVector)-1]> criticalDownLine){
        #if previous 3vector is above go to selling algorithm ,else do nothing because
        #we did the work 3 days ago
        #compare tangent of average over sime time and past 2 vectors
        stocksToBuy <- round(1 - (degreesDown/ atan(meanVector[length(meanVector)]-meanVector[length(meanVector)-1])), digits=0)
        if(stocksToBuy>0){
          if(budget-stocksToBuy*latestPrice >=0){
            budget= budget - stocksToBuy*latestPrice
            print(paste("BUY",names[index], ", amount:", stocksToBuy ,sep=" "))
            
          }
          else {
            print(paste("Not enough funds to buy", stocksToBuy , "for", names[index], sep=" " ))
          }
          
        }
        else if (stocksToBuy<0) {
          possibleStocksToBuy <- round(budget/latestPrice, digits=0)
          if(possibleStocksToBuy >= 1){
            print(paste("BUY",names[index], ", amount:", round(budget/latestPrice, digits=0) ,sep=" "))
            budget= budget - possibleStocksToBuy*latestPrice
            
          }
          else {
            print(paste("Not enough  funds to buy", stocksToBuy , "for", names[index], sep=" " ))
          }
          
        }
      }
    }
  }
    
   
  print("END of rebalancing");   
    }
  
  
  
  

  


