---
title: "Chapter-05-part2-assignment"
output: 
  html_document: 
    keep_md: yes
---
# Statistical Rethinking Chapter 4 problems

__Name:__




# For 04/18/2016

## 5M2: Invent your own example of a masked relationship. An outcome variable should be correlated with both predictor variables, but in opposite directions. And the two predictor variables should be correlated with one another.

Outcome:Transcription of a Gene

predictor 1: DNA methylation in a region 
predictor 2: DNase hypersensitivity in a region



## 5H1: Fit two bivariate Gaussian regressions, using map: (1) body weight as a linear function of territory size (area), and (2) body weight as a linear function of groupsize. Plot the results of these regressions, displaying the MAP regression line and the 95% interval of the mean. Is either variable important for predicting fox body weight?


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
data(foxes)
f <- foxes

f$area.s <- (f$area - mean(f$area))/sd(f$area)
f$groupsize.s <- (f$groupsize - mean(f$groupsize))/sd(f$groupsize)

h5.1a <- map(
    alist(
        weight ~ dnorm( mu , sigma ) ,
        mu <- a + ba*area.s ,
        a ~ dnorm( 5 , 10) ,
        ba ~ dnorm( 0 , 1 ) ,
        sigma ~ dunif( 0 , 10)
),  data=f )

plot(precis(h5.1))
```

```
## Error in plot(precis(h5.1)): error in evaluating the argument 'x' in selecting a method for function 'plot': Error in precis(h5.1) : object 'h5.1' not found
```

```r
precis(h5.1)
```

```
## Error in precis(h5.1): object 'h5.1' not found
```

```r
h5.1b <- map(
    alist(
        weight ~ dnorm( mu , sigma ) ,
        mu <- a + bs*groupsize.s ,
        a ~ dnorm( 5 , 10) ,
        bs ~ dnorm( 0 , 1 ) ,
        sigma ~ dunif( 0 , 10)
),  data=f )

plot(precis(h5.1b))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1-1.png)

```r
precis(h5.1b)
```

```
##        Mean StdDev  5.5% 94.5%
## a      4.53   0.11  4.36  4.70
## bs    -0.19   0.11 -0.36 -0.02
## sigma  1.16   0.08  1.04  1.29
```

## 5H2: 
Now fit a multiple linear regression wit hweight as the out come and both area and groupsize as predictor variables. Plot the predictions of the model for each predictor, holding the other predictor constant at its mean. What does this model say about the importance of each variable? Why do you get different results than you got in the exercise just above?

Both values are larger but on opp sides of zero...
and gives adds a little more varance

```r
h5.2 <- map(
    alist(
        weight ~ dnorm( mu , sigma ) ,
        mu <- a + ba*area.s + bs*groupsize.s ,
        a ~ dnorm( 5 , 10) ,
        ba ~ dnorm( 0 , 1 ) ,
        bs ~ dnorm( 0 , 1 ) ,
        sigma ~ dunif( 0 , 10 )
),  data=f )

precis(h5.2)
```

```
##        Mean StdDev  5.5% 94.5%
## a      4.53   0.10  4.36  4.70
## ba     0.54   0.18  0.25  0.83
## bs    -0.63   0.18 -0.92 -0.34
## sigma  1.12   0.07  1.00  1.24
```

```r
plot(precis(h5.2))
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2-1.png)

## 5H3

Finally, consider the avgfood variable. Fit two more multiple regressions: (1) body weight as an additive function of avgfood and groupsize, and (2) body weight as an additive function of all three variables, avgfood and groupsize and area. Compare the results of these models to the previous models you’ve fit, in the first two exercises. 

(a) Is avgfood or area a better predictor of body weight? If you had to choose one or the other to include in a model, which would it be? Support your assessment with any tables or plots you choose. (b) When both avgfood or area are in the same model, their effects are reduced (closer to zero) and their standard errors are larger than when they are included in separate models. Can you explain this result?



```r
library(corrplot)
x = cor(f)
corrplot(x, method="number")
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)

```r
##bf lots of varance...

h5.3a <- map(
    alist(
        weight ~ dnorm( mu , sigma ) ,
        mu <- a + bs*groupsize.s + bf*avgfood ,
        a ~ dnorm( 5 , 10) ,
        bs ~ dnorm( 0 , 1 ) ,
        bf ~ dnorm( 0 , 1 ) ,
        sigma ~ dunif( 0 , 10 )
),  data=f )

precis(h5.3a)
```

```
##        Mean StdDev  5.5% 94.5%
## a      3.43   0.59  2.48  4.38
## bs    -0.45   0.17 -0.72 -0.17
## bf     1.46   0.78  0.22  2.71
## sigma  1.13   0.08  1.01  1.26
```

```r
plot(precis(h5.3a))
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-2.png)

```r
## makes bs more important then ba and has less varance
h5.3b <- map(
    alist(
        weight ~ dnorm( mu , sigma ) ,
        mu <- a + ba*area.s + bs*groupsize.s + bf*avgfood ,
        a ~ dnorm( 5 , 10) ,
        ba ~ dnorm( 0 , 1 ) ,
        bs ~ dnorm( 0 , 1 ) ,
        bf ~ dnorm( 0 , 1 ) ,
        sigma ~ dunif( 0 , 10 )
),  data=f )

precis(h5.3b)
```

```
##        Mean StdDev  5.5% 94.5%
## a      3.95   0.63  2.95  4.95
## ba     0.47   0.19  0.16  0.78
## bs    -0.71   0.20 -1.03 -0.39
## bf     0.77   0.82 -0.54  2.08
## sigma  1.11   0.07  0.99  1.23
```

```r
plot(precis(h5.3b))
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-3.png)
