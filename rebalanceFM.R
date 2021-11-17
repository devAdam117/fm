
#Example_1 
# library(quantmod)
# rebalance(c("BOLT","RDS-B","F","LI","DAL","WMT","CVX","KO","VWAGY","NSRGY"),c(1000,225,511,326,229,67,87,175,302,70),55.37,3,20,0.0025)
#Example_1

#Example_2
# library(quantmod)
# rebalance(c("AMZN","PFE","DELL","NSRGY","NVDA","MDC","MSFT","VWAGY","EBAY","RDS-B","KO","BA","WMT","DAL","PEP","IBM","F","MMM","SBUX","TM","ADBE","AMD","TSM","TSLA","MA","V","COIN","BOLT","PYPL","LI"),c(1,69,60,25,11,65,10,101,45,74,58,15,22,75,20,27,166,18,29,18,5,22,27,3,9,15,9,287,14,91),43.70,3,10,0.0025)
#Example_2




#vyuzitie pseudoRebalance funkcie sluzi iba na nasadenie najviac optimalnych hranic pri ktorych predavat
pseudoRebalance <- function(knownData,borders,meanVector,degreesVector,aoStocks){
  criticalUpLine <- max(borders) #zober hornu hranicu
  criticalDownLine <- min(borders)#zober spodnu hranicu
  degreesUp <- atan(median(degreesVector[degreesVector >=0]))  #priemerny narast iba medzi dvojicami bodov, kde bol zisteny narast
  degreesDown <- atan(median(degreesVector[degreesVector <=0])) #priemerny pokles iba medzi dvojicami bodov, kde bol zisteny pokles
  if(meanVector[length(meanVector)]<= criticalDownLine){
    # pokial je to pod hornou hranicou skontroluj ci predchadzajuci bod je nad touto hranicou 
    if(meanVector[length(meanVector)-1]> criticalDownLine){
      # ak ano tak nastal pripad v ktorom kupujeme nejake mnozstvo
      #porovnavame tangens medzi tymito dvoma bodmi s priemernym poklesom a podla toho urcuje pocet kupi
      stocksToBuy <- 1 - (degreesDown/ atan(meanVector[length(meanVector)]-meanVector[length(meanVector)-1]))
      if(stocksToBuy>0){
          
          return(stocksToBuy)
      }
      else if (stocksToBuy<0) {
        stockToBuy <- aoStocks #ak je pod nulou nech kupi raz tolko kolko aktualne vlastni (povodny rebalance bude davat pozor ci mame na to budget)
        return(stockToBuy)
        
        
      }
    }
    else {
      return(0)
    }
  }
  
  else if (meanVector[length(meanVector)]>= criticalUpLine){
    #analogicky ak sme nad vrchnou hranicou s dnesnym bodom tak sledujume bod zo vcerajska
    if(meanVector[length(meanVector)-1]< criticalUpLine){
      #ak je dalsi bod pod vrchnou hranicou budeme predavat podla podobnej logiky ako pred tym
      #porovnavame uhol stupania medzi poslednymi dvoma bodmi s priemerom narastu a podla toho urcujeme pocet predaja
      stocksToSell <- round(1 - (degreesUp/ atan(meanVector[length(meanVector)]-meanVector[length(meanVector)-1])), digits=0)
      if(stocksToSell<0){
        #predaj vsetko co mozes
        stocksToSell=aoStocks
        return(-stocksToSell)
        
      }
      else if (stocksToSell == 0){
        return(stocksToSell)
      }
      else if(stocksToSell > 0){
        #predaj tolko co ti odporuci
        return(-stocksToSell)
      }
      
    }
    else {
      return(0)
    }
  }
  else {
    return(0)
  }
  
}

#funkcia setBoundries sluzi na to aby pre kazdu firmu/akciu, nasla co najoptimalnejsie hranice, teda hranice pri ktorych by sme mohli mat co najvacsi profit.
#Zoberie si data akcie za poslednych n- mesiacov dozadu (2. parameter fcie) pri com sa bude tvarit ze m - poslednych dni z dat  je neznamych(4. parameter fcie),
#Teda mame data rozdelene na zname a nezname, kde na zname data aplikujeme fciu pseudoRebalanc, ktora nam povie kolko kupit/predat akcie a "posunieme sa instantne"
#o jeden den do predu tak ze hodnotu z prveho dna z neznamych dat priradime znamim datam, znovu aplikujeme pseudoRebalance, ktora nam povie kolko kupit/predat
# 2. den, nasledne znova priradime dalsiu hodnotu akcie z neznamych dat do znamych. Tento postup sa aplikuje n-krat (4. parameter urcuje kolkokrat). 
#Potom sa na konci pozrieme aky by bol nas profit na konci keby sme predavali/kupovali pri tychto hraniciach, hranice priblizime k sebe a cely algoritmus opakujeme
# az pokial hranice nebudu velmi blizucko seba. Potom na zaklade najvacsieho profitu, vybereme prislusne hranice, ktore sa budu pouzivat v hlavnej fcie ako optimalne hranice
setBoundries <- function(boundries, historicalData,aoStocks, deepthOfLearningInDays,fees){
  fixedUpLine <- max(boundries) #horna hranica ktoru budeme upravovat
  adjClose <- historicalData[,4] # uzavieracia cena
  adjBuy <- historicalData[,2] #kupujuca cena
  adjSell <- historicalData[,3] # predavajuca cena
  fixedBottomLine <- min(boundries) # dolna hranica ktoru budeme upravovat
  unknownAdjClose <- adjClose[(length(adjClose)-deepthOfLearningInDays+1):length(adjClose)] # data na ktorych sa budu hranice ucit byt co najviac optimalne
  unknownAdjClose<- unknownAdjClose[-1] ##potrebna konvertacia...
  unknownAdjClose<-as.numeric(unknownAdjClose) #potrebna konvertacia...
  knownAdjClose <- adjClose[1:(length(adjClose)-deepthOfLearningInDays)] #nezname data ktore sa budu kazdym jedny cyklom po jednom ukazovat
  knownAdjClose<- knownAdjClose[-1] #potrebna konvertacia...
  knownAdjClose<-as.numeric(knownAdjClose) #potrebna konvertacia...
  
  #na ucely kupi v nejaky den
  unknownAdjBuy <- adjBuy[(length(adjBuy)-deepthOfLearningInDays+1):length(adjBuy)] #nezname kupujuce ceny
  knownAdjBuy <- adjBuy[1:(length(adjBuy)-deepthOfLearningInDays)] # zname kupujuce ceny
  unknownAdjBuy<- unknownAdjBuy[-1] #potrebna konvertacia...
  unknownAdjBuy<-as.numeric(unknownAdjBuy) #potrebna konvertacia...
  knownAdjBuy<- knownAdjBuy[-1] #potrebna konvertacia...
  knownAdjBuy<-as.numeric(knownAdjBuy)  #potrebna konvertacia...
  
  
  #na ucely predaja v nejaky den
  unknownAdjSell <- adjSell[(length(adjSell)-deepthOfLearningInDays+1):length(adjSell)] #nezname predavajuce ceny
  knownAdjSell <- adjSell[1:(length(adjSell)-deepthOfLearningInDays)] #zname predavajuce ceny
  unknownAdjSell <- unknownAdjSell[-1] #potrebna konvertacia...
  unknownAdjSell<-as.numeric(unknownAdjSell)  #potrebna konvertacia...
  knownAdjSell <- knownAdjSell[-1] #potrebna konvertacia...
  knownAdjSell<-as.numeric(knownAdjSell)  #potrebna konvertacia...
  
  # same stuff like in rebalance logic #
  degreesVector <- c() # vektor stupnovych rozdielov medzi parmi bodov
  meanVector <- c() # vektor pohybu akci, na zaklade hodnoty jeho bodov sa urcuje kedy kupujeme a kedy predavame
  #naplnime vektor datami
  for(i in 1:(length(adjClose)-2)){
    meanVector <- c(meanVector, mean(adjClose[i:(i+2)])/adjClose[i])
    if(i>1){
      degreesVector <- c(degreesVector, meanVector[i]-meanVector[i-1])
    }
  }
  knownDegrees <- degreesVector[1:(length(degreesVector)-deepthOfLearningInDays)] #zname stupne
  unknownDegrees <- degreesVector[(length(degreesVector)-deepthOfLearningInDays+1):length(degreesVector)] #nezname stupne z neznamych dni
  knownData <- meanVector[1:(length(meanVector)-deepthOfLearningInDays)] #vytvorenie znamych vektorovych posunov
  unknownData <- meanVector[(length(meanVector)-deepthOfLearningInDays+2):length(meanVector)] #zatial nezname vektorove posuny
  
  
  
  
  beginingVal <- aoStocks*knownAdjClose[length(knownAdjClose)] #hodnota portfolia na konci znamych dni, budeme ju porovnavat s hodnototou portfolia na konci neznamych dni
  profits <- c() #vektor profitov, bude zaznamenavat profity, vzdy pre inac nadstavene hranice
  upLine <- fixedUpLine #kopie hranic, ktore budeme upravovat 
  bottomLine <- fixedBottomLine #kopie hranic, ktore budeme upravovat
  money <- 0 #budeme mat vzdy dostatok fin. prostriedkov na kupu, pre ucely nadstavenia hranic. Musime vsak zaznamenavat kolko sme utratili/predali spolu 
  # a na konci to pripocitame k celkovej hodnote portfolia
  
  
  
  while(upLine-bottomLine > 0.001){
    money<- 0 #vzdy pre kazdu novu hranicu zaciname na zaciatku s 0
    
    knownData <- meanVector[1:(length(meanVector)-deepthOfLearningInDays)] #vzdy pre kazdu novu hranicu nadstav body pohybu spat aby, dalej vo for-loope mu budeme pripisovat
    #data takze ho treba vzdy pred forkom resetnut
    knownDegrees <- degreesVector[1:(length(degreesVector)-deepthOfLearningInDays)] # to iste..
    
    for(i in 1:length(unknownData)){
      result <- pseudoRebalance(knownData,c(upLine,bottomLine),knownData,knownDegrees,aoStock) #pseudoRebalance nam v najaktualnejsie dato v knownData povie kolko kupit/predat
      #print(result)
      if(result>0){
        #kupuj
        result <- result*(1-fees) # fees z kupi odidu prec
        aoStock <- aoStocks +  result
        money <- money - result*unknownAdjBuy[i] # kupuj za cenu v ten den
        
      }
      else {
        
        result <- result*(1-fees) #fees z predaja, iba cast mozes predavat
        aoStock <- aoStocks +  result
        money <- money - result*unknownAdjSell[i] #predaj za cenu v ten den
        
      }
      
      
      knownData <- c(knownData, unknownData[i]) #na konci forka pridaj novy den do znamych dni z neznamych a ked skonci forko tak sa hore v while resetuje
      
      knownDegrees <- c(knownDegrees, unknownDegrees[i]) #same
      
      
    }
    
    
    
    profits <-c( profits, ((money+aoStock*unknownAdjClose[length(unknownAdjClose)])-beginingVal)) #vektor profitov pre jednu akciu, pri rozne nadstavenych hraniciach
    upLine=upLine*0.999 #postupne znizovanie hornej hranice
    bottomLine = bottomLine*1.001 #postupne zvysovanie spodnej hranice
    
  }
  
  index <- which.max(profits) #aky bol najvacsi profit ?
  optimalUpperBound <- fixedUpLine*0.999^index
  optimalLowerBound <- fixedBottomLine*1.001^index
  
  #returnuju sa hranice pri ktorych bol profit najvacsi (profit moze byt aj zaporny)
  return(c(optimalUpperBound,optimalLowerBound))
  
}


rebalance <- function(names,aoStocks,budget,monthsToCalculate,deepthOfLearningInDays,fees){
 
    #skontroluj dlzku vektorov
    if(length(names)!=length(aoStocks)){
      return("Length of first and second parameters must be the  same!")
    }
    
    for(index in 1:length(names)){
      data <- getSymbols(names[index], from = seq(as.Date(Sys.Date()), length = 2, by = paste(paste("-",monthsToCalculate , sep=""),"months", sep=" "))[2], 
                         to = Sys.Date(), warnings = FALSE, auto.assign = FALSE)
      
      adjClose <- data[,4]
      sellPrice <- data[,3]
      buyPrice <- data[,2]
      
      
      latestPrice <- adjClose[length(adjClose)]
      latestBuyPrice <- buyPrice[length(buyPrice)]
      latestSellPrice <- sellPrice[length(sellPrice)]
      
      degreesVector <- c() # bude neskor urcovat kolko predavat/kupovat pri prekroceni hranic
      meanVector <- c() # jednotlive body pohybu
      #naplnime ich datami
      for(i in 1:(length(adjClose)-2)){
        meanVector <- c(meanVector, mean(adjClose[i:(i+2)])/adjClose[i])
        if(i>1){
          degreesVector <- c(degreesVector, meanVector[i]-meanVector[i-1])
        }
      }
      
      #extract dolezite konstanty z vektoru pre model
      degreesUp <- atan(median(degreesVector[degreesVector >=0]))  #avg increasment across every 3day vector  in degrees 
      degreesDown <- atan(median(degreesVector[degreesVector <=0])) #avg decreasment across every 3day vector  in degrees 
      criticalUpLine <- mean(meanVector[meanVector>=1])   #prvo zovlena horna hranica
      criticalDownLine <- mean(meanVector[meanVector<1])  #prvo zvolena spodna hranica
      
      #funkcii setBoundries poskytneme hranice ktore sme zvolili, historicke data pre danu akciu, pocet pseudo akcii na ktorych ma vyplut co najviac optimalny vysledok
      #, pocet dni na ktorych sa ma ucit a tvarit sa ze su nezname, poplatok
     result <-  setBoundries(c(criticalUpLine,criticalDownLine),data,1000,deepthOfLearningInDays,fees)
     criticalUpLine <- result[1] #optimalna horna hranica
     criticalDownLine <- result[2] #optimalna spodna hranica
      
      
      
      #plot sa vykresli iba ak zadame prave jednu akciu a nie vektor akcii
      if(length(names)==1){
        plot(meanVector, type="l")
        abline(a=criticalUpLine, b=0)
        abline(a=criticalDownLine, b=0)
      }
      
      #pripad predaja, velmi podobne ako v pseudoRebalance()
      # najprv predavame to co je odporucene a az potom kupujeme aby sme mali vacsiu istotu, ze budeme mat peniaze na vsetky akcie, ktore su nam odporucene kupit
     
      if(meanVector[length(meanVector)]>= criticalUpLine){
         
        if(meanVector[length(meanVector)-1]< criticalUpLine){
          
          stocksToSell <- round(1 - (degreesUp/ atan(meanVector[length(meanVector)]-meanVector[length(meanVector)-1])), digits=0)
          if(stocksToSell<0){
            stocksToSell=aoStocks[index]
            budget= budget + stocksToSell*latestSellPrice*(1-fees) #predavame za low cenu plus poplatky
            print( paste("SELL", names[index],", amount: " , stocksToSell ,sep=" "))
          }
          else if (stocksToSell == 0){
            
          }
          else if(stocksToSell > 0){
            
            budget= budget + stocksToSell*latestSellPrice*(1-fees) #predavame za low cenu plus poplatky
            print( paste("SELL", names[index],", amount: " , stocksToSell ,sep=" "))
          }
          
        }
      }
      
      
      
      
      
    }
  #Cely princip sa opakuje pre kupu, s tym rozdielom ze v kupe sledujeme ci mame dostatok penazi ak nie, tak vypise do konzoly, ze nemame dostatok fundov na kupu
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
            if(budget-stocksToBuy*latestBuyPrice*(1+fees) >=0){
              budget= budget - stocksToBuy*latestBuyPrice*(1+fees)
              print(paste("BUY",names[index], ", amount:", stocksToBuy ,sep=" "))
              
            }
            else {
              print(paste("Not enough funds to buy", stocksToBuy , "for", names[index], sep=" " ))
            }
            
          }
          else if (stocksToBuy<0) {
            possibleStocksToBuy <- floor(budget/(latestBuyPrice*(1+fees)))
            if(possibleStocksToBuy >= 1){
              print(paste("BUY",names[index], ", amount:", round(budget/latestBuyPrice*(1+fees), digits=0) ,sep=" "))
              budget= budget - possibleStocksToBuy*latestBuyPrice*(1+fees)
              
            }
            else {
              print(paste("Not enough  funds to buy", round(budget/(latestBuyPrice*(1+fees)),digit=0) , "for", names[index], sep=" " ))
            }
            
          }
        }
      }
    }
    
    print("END of rebalancing");   
    print(paste("Your budget after rebalancation should be : ", budget) )
    
  
    }
  
  
  
  

  


