# Statistical Rethinking Chapter 4 problems

__Name:__Gina Turco


# For 04/11/2016

### 5E1 Which of the linear models below are multiple linear regressions?

(1) μi =α+βxi
(2) **μi = βxxi + βzzi**
(3) μi = α + β(xi − zi) 
(4) **μi =α+βxxi +βzzi**

### 5E2 Write down a multiple regression to evaluate the claim: Animal diversity is linearly related to latitude, but only after controlling for plant diversity. You just need to write down the model definition.


Av animal diversity =α+βLli +βPpi
### write everything out

### 5M1 Invent your own example of a spurious correlation. An outcome variable should be correlated with both predictor variables. But when both predictors are entered in the same model, the correlation between the outcome and one of the predictors should mostly vanish (or at least be greatly reduced).


No one wants to eat Texas BBQ after 1pm
When really correlated with the time to prep the meat and when the meat is due.


```r
library(rethinking)
```

```
## Loading required package: rstan
```

```
## Loading required package: ggplot2
```

```
## Warning: package 'ggplot2' was built under R version 3.2.4
```

```
## rstan (Version 2.9.0-3, packaged: 2016-02-11 15:54:41 UTC, GitRev: 05c3d0058b6a)
```

```
## For execution on a local, multicore CPU with excess RAM we recommend calling
## rstan_options(auto_write = TRUE)
## options(mc.cores = parallel::detectCores())
```

```
## Loading required package: parallel
```

```
## rethinking (Version 1.58)
```

```r
N <- 100
x_real <- rnorm( N )
x_spur <- rnorm( N , x_real )
y <- rnorm( N , x_real )
d <- data.frame(y,x_real,x_spur)
pairs(d)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1-1.png)


### 5M3 It is sometimes observed that the best predictor of fire risk is the presence of firefighters— States and localities with many firefighters also have more fires. Presumably firefighters do not cause fires. Nevertheless, this is not a spurious correlation. Instead fires cause firefighters. Consider the same reversal of causal inference in the context of the divorce and marriage data. How might a high divorce rate cause a higher marriage rate? Can you think of a way to evaluate this relationship, using multiple regression? 

### How might a high divorce rate cause a higher marriage rate?

The higher the divorce rate the more single people available to be married

### Can you think of a way to evaluate this relationship, using multiple regression? 

m= marriage rate
s = number of single people
d = divorce rate

m =α+βDdi +βSsi


### 5M4  In the divorce data, States with high numbers of Mormons (members of The Church of Jesus Christ of Latter-day Saints, LDS) have much lower divorce rates than the regression models expected. Find a list of LDS population by State and use those numbers as a predictor variable, predicting divorce rate using marriage rate, median age at marriage, and percent LDS population (possibly standardized). You may want to consider transformations of the raw percent LDS variable.


```r
## data
data(WaffleDivorce)
d <- WaffleDivorce
lds = read.table("/Users/gturco/Documents/code/Rclub-rethinking_Gina.Turco/Assignment_Chapter_05/LDS.txt",header = FALSE, sep="\t")
colnames(lds) = c("state","mem","pop","LDS","stakes","dist","wards","branches","congreg","missions","temps","family")

p = merge(d,lds, by.x = "Location", by.y = "state" )
p = as.data.frame(p)
### trim out precent sign and convert to a number...

p$MedianAgeMarriage.s <- (p$MedianAgeMarriage-mean(p$MedianAgeMarriage))/sd(p$MedianAgeMarriage)
p$Marriage.s <- (p$Marriage - mean(p$Marriage))/sd(p$Marriage)
p$LDS.s = (p$LDS - mean(p$LDS))/sd(p$LDS)

# fit model
m6.1 <- map(
  alist(
    Divorce ~ dnorm( mu , sigma ) ,
    mu <- a + bA*MedianAgeMarriage.s  + bL*LDS.s + bR*Marriage.s ,
    a ~ dnorm( 10 , 10 ) ,
    bA ~ dnorm( 0 , 1 ) ,
    bL ~ dnorm( 0 , 1 ) ,
    bR ~ dnorm( 0 , 1 ) ,
    sigma ~ dunif( 0 , 10 )
  ) , data = p )


plot(precis(m6.1))
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2-1.png)

