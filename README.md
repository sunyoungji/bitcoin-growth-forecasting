# Forecasting Quarterly Bitcoin Growth Using Macroeconomic Indicators

This repository contains R code for forecasting Bitcoin growth using various time series models.

---

## Overview

This project compares the performance of different time series models—AR(1), VAR, and U-MIDAS—for forecasting Bitcoin price growth using macroeconomic indicators and mixed-frequency data from FRED.

The objective is to evaluate whether incorporating high-frequency macroeconomic information improves forecast accuracy, measured by Root Mean Squared Forecast Error (RMSFE).

In this analysis, the AR(1) model achieved the lowest RMSFE, suggesting that adding macroeconomic indicators did not lead to better forecasting performance.

---

## Tools & Packages

- **Language**: `R`
- **Required Libraries**:
  - `vars` – Vector autoregression
  - `midasr` – MIDAS models (Mixed Data Sampling)
  - `lmtest` – Granger causality test

---

## 📂 Data

### Bitcoin Data

The Bitcoin dataset was downloaded from [CoinMarketCap](https://coinmarketcap.com/currencies/bitcoin/).  
It contains **daily high and low prices of Bitcoin** from **13 July 2010 to 29 March 2023**, with a total of **731 observations**.

To prepare the data for time series modeling:

- The **average of high and low prices** was calculated for each day to construct a representative daily price.
- Daily prices were then **aggregated to monthly and quarterly frequency** using the geometric mean of logged values.
- The **Bitcoin growth rate** was computed as the percentage change from one period to the next, forming the main dependent variable.

This transformed series serves as the target variable in AR, VAR, and U-MIDAS models.

---

### Macroeconomic Data

Macroeconomic indicators were retrieved from the **St. Louis Fed Data Center**, maintained by the **Federal Reserve Bank of St. Louis**, using the [FRED-QD and FRED-MD databases](https://research.stlouisfed.org/econ/mccracken/fred-databases/):

- **FRED-QD (Quarterly Data)**:
  - 247 variables, 63,726 observations  
  - Coverage: Q3 1959 – Q4 2020

- **FRED-MD (Monthly Data)**:
  - 128 variables, 98,560 observations  
  - Coverage: January 1959 – January 2023

The following macroeconomic variables were selected for modeling:
- `UNRATE`: Civilian unemployment rate  
- `FEDFUNDS`: Effective federal funds rate  
- `CPIAUCSL`: Consumer price index (urban consumers)  
- `S&P 500`: Stock market index (composite)

Each series was converted into a growth rate or percentage change, and aligned with Bitcoin data in either quarterly or monthly frequency depending on the model.
