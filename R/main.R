##
##
## 


## running on soilmap2-1 takes about the same amount of time
## consider parallel implementation via furrr package

# 1. get / parse data
source('parse-all-series-via-sc-db.R')

## ~ 4 minutes run time
##  
# 2. fill-in missing colors using brute force modeling approach
source('predict-missing-colors.R')

# 3. send to SoilWeb

# 4. re-load data: see sql/ dir in this repo



# stats
x <- read.csv('logfile-2018-01-05.csv', stringsAsFactors = FALSE)
table(x$sections)
