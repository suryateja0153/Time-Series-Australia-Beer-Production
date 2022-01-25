#Author: Suryateja Chalapati

#Importing required libraries
rm(list=ls())
library(rio)
library(moments)
library(car)
library(dplyr)

#Setting the working directory,importing and creating new variables
setwd("C:/Users/surya/Downloads")

df = import("Time Series Data.xlsx", sheet = "Sheet1")
colnames(df)=tolower(make.names(colnames(df)))
df = df %>% rename(index = x, date = month, production = monthly.beer.production)
df$year=as.numeric(format(df$date,'%Y'))
df$month=as.numeric(format(df$date,'%m'))
attach(df)

#Analysis_1
plot(index,production,type="o",pch=19,ylab = "Production",xlab = "Index",
     main="Australia Beer Production -- Raw Data")

#Analysis_2
#Simple regression on Time Series data
regout=lm(production~index,data=df)
summary(regout)
points(regout$fitted.values,type="o",pch=19,col="red")
cor(df$production,regout$fitted.values)
plot(df$index,rstandard(regout),ylab = "Standardised Residuals",xlab = "Index",pch=19,type="o")
abline(0,0,col="red",lwd=3)

#Analysis_3
plot(index,production,type="o",pch=19,ylab = "Production",xlab = "Index",
     main="Australia Beer Production -- Raw Data")
points(regout$fitted.values,type="o",pch=19,col="red")

#Analysis_4
#Durbin Watson Test
dwt.out=durbinWatsonTest(regout)
dwt.out

#Analysis_5
#Making Seasonal Indices
indices=data.frame(month=1:12,average=0,index=0)
for(i in 1:12) {
  count=0
  for(j in 1:nrow(df)) {
    if(i==df$month[j]) {
      indices$average[i]=indices$average[i]+df$production[j]
      count=count+1
    }
  }
  indices$average[i]=indices$average[i]/count
  indices$index[i]=indices$average[i]/mean(df$production)}

#Deseasonalizing the original data
for(i in 1:12){
  for(j in 1:nrow(df)){
    if(i==df$month[j]){
      df$deseason.production[j]=df$production[j]/indices$index[i]
    }
  }
}

#Analysis_6
#Conducting the deseasonalized regression polynomial order 1
dsreg.out.ord1=lm(deseason.production~index,data=df)
summary(dsreg.out.ord1)
plot(df$index,df$deseason.production,type="o",pch=19,ylab = "Deseasonalized Production",xlab = "Index",
     main="Deseasonalized Data and Regression Model - Polynomial Order 1")
points(df$index,dsreg.out.ord1$fitted.values,type="o",
       pch=19,col="red")
plot(df$index,rstandard(dsreg.out.ord1),pch=19,type="o",ylab = "Standardised Residuals",xlab = "Index",
     main="Deseasonalized Forecasts -- Standardized Errors")
abline(0,0,col="red",lwd=3)

#Conducting the deseasonalized regression polynomial order 2
dsreg.out.ord2=lm(deseason.production~poly(index,2),data=df)
summary(dsreg.out.ord2)
plot(df$index,df$deseason.production,type="o",pch=19,ylab = "Deseasonalized Production",xlab = "Index",
     main="Deseasonalized Data and Regression Model  - Polynomial Order 2")
points(df$index,dsreg.out.ord2$fitted.values,type="o",
       pch=19,col="red")
plot(df$index,rstandard(dsreg.out.ord2),pch=19,type="o",ylab = "Standardised Residuals",xlab = "Index",
     main="Deseasonalized Forecasts -- Standardized Errors")
abline(0,0,col="red",lwd=3)

#Analysis_7
#Reseasonalizing Forecasts for polynomial order 1
df$deseason.forecast=dsreg.out.ord1$fitted.values
for(i in 1:12){
  for(j in 1:nrow(df)){
    if(i==df$month[j]){
      df$reseason.forecast[j]=df$deseason.forecast[j]*
        indices$index[i]
    }
  }
}

plot(df$index,df$production,type="o",pch=19,ylab = "Production",xlab = "Index",
     main="Original Data and Reseasonalized Forecasts - Polynomial Order 1")
points(df$index,df$reseason.forecast,
       type="o",pch=19,col="red")

#Reseasonalizing Forecasts for polynomial order 2
df$deseason.forecast=dsreg.out.ord2$fitted.values
for(i in 1:12){
  for(j in 1:nrow(df)){
    if(i==df$month[j]){
      df$reseason.forecast[j]=df$deseason.forecast[j]*
        indices$index[i]
    }
  }
}

plot(df$index,df$production,type="o",pch=19,ylab = "Production",xlab = "Index",
     main="Original Data and Reseasonalized Forecasts - Polynomial Order 2")
points(df$index,df$reseason.forecast,
       type="o",pch=19,col="red")
