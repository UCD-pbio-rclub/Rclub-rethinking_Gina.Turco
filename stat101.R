###04/03/15

data(cars)
nrow(cars)
summary(cars)


## some histogrmas to see if things are normal
hist(cars$speed)
#this looks pretty normally dist
hist(cars$dist)
## this looks a little skwed showed test for normality
###calculate the correlation and speed rcode when using html format-{R}, `r will run whats ever after it
cor(cars)
cor(cars$speed,cars$dist)
## high correlation###
## speed is explatory var so should be x, response var
### pch= circos, tringle, how to plot
plot(cars$speed, cars$dist, col="purple", pch=17)

## there is a [pstive linear relationship

cor.test(cars$speed, cars$dist, alternative= "greater", conf.level=0.95)
## rho is greater than zero output means there is a postive linear relationship
### only can get a conf interval when things are normally dist
## whats next, what is the line that predicts the average for each speed... linear models

the.line = lm(cars$dist~cars$speed)
plot(cars$speed, cars$dist, col="purple", pch=6)
abline(the.line$coefficients)
### homework goes over power anaysis


#### 05/01/15
#1st thing to do a scatter plot of each.. do the giaint scatter plots

