install.packages("")

library(readr)
library(tidyverse)
library(zoo)
library(gridExtra)
library(forecast)
# library(urca)         # for unit root testing
library(vars)

# loading data
btc_raw <- read_csv("BTC_ALL_graph_coinmarketcap.csv")
fred_raw <- read.csv("edited_FRED-QD.csv")


# checking 'NA'
sum(is.na(btc_raw)) # 0
sum(is.na(fred_raw)) # 22


# data manipulation of FRED_QD
## UNRATE: Civilian Unemployment Rate (Percent)
## CPIAUCSL: Consumer Price Index for All Urban Consumers: All Items (Index 1982-84=100)
## FEDFUNDS: Effective Federal Funds Rate (Percent)
## S.P.500: S&P's Common Stock Price Index: Composite
## monthly frequency series are aggregated to a quarterly frequency using averages in FRED_QD


fred_data <- fred_raw[, c("UNRATE","CPIAUCSL","FEDFUNDS","S.P.500")]

# calculating mean of high and low values of btccoin
btc_data <- btc_raw %>%
  mutate(center = (high + low) / 2)

# transforming quarterly data
names(btc_data)
btc_data$new.date = as.Date(as.character(btc_data$date), "%d-%m-%y")
btc_data$quarter = as.yearqtr(btc_data$new.date)
ggplot(btc_data, aes(quarter,center)) +
  geom_point()

#fred_data$new.date = as.Date(as.character(fred_data$Date), "%d-%m-%y")
#fred_data$quarter = as.yearqtr(fred_data$new.date)

# calculating quarterly growth

q_btc_data <- btc_data %>%
  group_by(quarter) %>%
  summarise(avg = mean(center))

q_btc_data <- q_btc_data %>%
  mutate(btc_growth = (avg - lag(avg)) / lag(avg) * 100)

fred_data <- fred_data %>%
  mutate(sp_growth = (S.P.500 - lag(S.P.500)) / lag(S.P.500) * 100) %>%
  mutate(inf_rate = (CPIAUCSL - lag(CPIAUCSL)) / lag(CPIAUCSL) * 100)

# comparing quarterly data
names(q_btc_data)
names(fred_data) # ~ 2020 Q4
tem_btc <- q_btc_data[1:50,] # ~ 2020 Q4
total <- cbind(tem_btc[,c(1,3)],fred_data[,c(2,4,6,7)])
head(total)
sum(is.na(total))
total[is.na(total)]=0


a <- ggplot(total, aes(quarter, btc_growth)) + geom_line()
b <- ggplot(total, aes(quarter, UNRATE)) + geom_line()
c <- ggplot(total, aes(quarter, inf_rate)) + geom_line()
d <- ggplot(total, aes(quarter, FEDFUNDS)) + geom_line()
e <- ggplot(total, aes(quarter, sp_growth)) + geom_line()
grid.arrange(a,b,c,d,e, nrow=3, ncol=2)

plot(total$btc_growth, type = "l")
plot(total$UNRATE, type = "l")
lines(total$FEDFUNDS, col = "red")
lines(total$sp_growth, col = "blue")
lines(total$inf_rate, col = "green")

'total <- total %>%
  gather(category, values, -quarter) %>%
  filter(category %in% c('growth_rate','UNRATE',
                                'CPIAUCSL', 'FEDFUNDS','sp500_rate')) %>%
  print

total %>%
  ggplot(aes(x = quarter, y = values)) +
  geom_line(aes(group = category, color = category, linetype = category))
plot(fred_data$sp500_rate)'


# check the stationarity
## The dashed lines to both sides of the zero axis give a rough indication of whether the autocorrelation coefficients may be regarded as coming from a process with true autocorrelation equal to zero (Lütkepohl, H., 2004).
ggtsdisplay(total$btc_growth)
ggtsdisplay(total$UNRATE)
ggtsdisplay(total$FEDFUNDS)
ggtsdisplay(total$sp_growth)
ggtsdisplay(total$inf_rate)

# AR(1)

## forecasting AR(1) of bitcoin


btc_ts <- ts(total$btc_growth, start = c(2010,3), frequency = 4)
plot(btc_ts)

#btc_train <- btc_ts[1:49] # one quarter ahead
#btc_ts_test <- btc_ts[50]
# the quarterly growth rate is already be stationary, as it measures the change in Bitcoin price over time rather than the actual price level.

btc_ar <- arima(btc_ts, order = c(1,0,0))
summary(btc_ar)
btc_ar_fit <- btc_ts - residuals(btc_ar)

## one step forecast
btc_fore <- forecast(btc_ar, h =1)
print(btc_fore)

## ploting the original, fitted data and forecasted data
plot(btc_fore)
points(btc_ar_fit, type = "l", col = "red", lty = 2)
plot(btc_ar_fit)


# VAR(1)
total_ts <- ts(total[-1,-1], start = c(2010,4), frequency = 4)
plot(total_ts)
nrow(total_ts)

total_ts[,1]



total_var <- VAR(total_ts, p=1)
summary(total_var)

btc_var_fit <- fitted(total_var)
btc_var_fit <- btc_var_fit[,1]
btc_var_fit <- ts(btc_var_fit, start = c(2011,1), frequency = 4)

#btc_res <- residuals(total_var)
#total_res <- ts(total_res[,1], start = c(2010,4), frequency = 4)
#btc_var_fit <- btc_ts - total_res

var_for <- predict(total_var, n.ahead = 1)
var_for$fcst[1]

plot(var_for, names = "btc_growth")
# fanchart(var_for, names = "btc_growth")
lines(btc_var_fit, type = "l", col = "red", lty = 2)

plot(btc_var_fit, type = "l")
lines(btc_ar_fit, type = "l", col = "red", lty = 2)



