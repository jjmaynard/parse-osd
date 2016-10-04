##
## 2015-06-23
## fill-in missing / incorrectly parsed OSD colors using brute-force supervised classification
##



library(randomForest)
library(hexbin)

d <- read.csv('parsed-data.csv.gz', stringsAsFactors=TRUE)

# tabulate missing data
# ~ 52327 dry records
# ~ 16961 moist records
summary(d)

# model for predicting moist from dry colors
summary(l.v <- lm(moist_value ~ dry_value, data=d))
summary(l.c <- lm(moist_chroma ~ dry_chroma, data=d))

coef(l.c)
coef(l.v)

## again, this time with RF
mv.rf <- randomForest(moist_value ~ dry_value + dry_chroma + dry_hue, data=d, na.action=na.omit)
mc.rf <- randomForest(moist_chroma ~ dry_value + dry_chroma + dry_hue, data=d, na.action=na.omit)

dv.rf <- randomForest(dry_value ~ moist_value + moist_chroma + moist_hue, data=d, na.action=na.omit)
dc.rf <- randomForest(dry_chroma ~ moist_value + moist_chroma + moist_hue, data=d, na.action=na.omit)

# check, results seem OK

## RF model
hexbinplot(predict(mv.rf, newdata=d) ~ d$moist_value)
hexbinplot(predict(dv.rf, newdata=d) ~ d$dry_value)

## linear model
hexbinplot(predict(l.v, newdata=d) ~ d$moist_value)

# check correlation
cor(predict(mv.rf, newdata=d), d$moist_value, use = 'complete.obs')
cor(predict(l.v, newdata=d), d$moist_value, use = 'complete.obs')


# fill missing data:

# value
d$moist_value[which(is.na(d$moist_value))] <- round(predict(mv.rf, d[which(is.na(d$moist_value)), ]))
d$dry_value[which(is.na(d$dry_value))] <- round(predict(dv.rf, d[which(is.na(d$dry_value)), ]))

# chroma
d$moist_chroma[which(is.na(d$moist_chroma))] <- round(predict(mc.rf, d[which(is.na(d$moist_chroma)), ]))
d$dry_chroma[which(is.na(d$dry_chroma))] <- round(predict(dc.rf, d[which(is.na(d$dry_chroma)), ]))

# convert factors > character
d$moist_hue <- as.character(d$moist_hue)
d$dry_hue <- as.character(d$dry_hue)

# hue, use moist / dry hue
d$moist_hue[which(is.na(d$moist_hue))] <- d$dry_hue[which(is.na(d$moist_hue))]
d$dry_hue[which(is.na(d$dry_hue))] <- d$moist_hue[which(is.na(d$dry_hue))]

# other factor > character conversion
d$name <- as.character(d$name)
d$seriesname <- as.character(d$seriesname)

# tabulate missing data
# 12221 records
# ~ 25-75% reduction in NA
summary(d)

# save result
write.csv(d, file=gzfile('parsed-data-est-colors.csv.gz'), row.names=FALSE)


