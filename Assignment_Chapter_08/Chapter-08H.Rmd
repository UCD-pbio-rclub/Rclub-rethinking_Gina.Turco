Run the model below and then inspect the posterior distribution and explain what it is 
accomplishing.


```{r}
library(rethinking)
mp <- map2stan(
  alist(
    ### solving for alpha and beta sep
    a ~ dnorm(0,1),
    ## alpha has a normal dist with a mean of zero and st dev 1
    b ~ dcauchy(0,1)
    ## cauchy is a thick-tailed dist with a mean of zero and st dev 1
  ),
  ### our data set is just one value 1
  data=list(y=1),
  start=list(a=0,b=0),
  iter=1e4, warmup=100 , WAIC=FALSE )

precis(mp)
## the thick-tailed dist has a mean closer to 1 or mid one where the st dis is closer to zero but the cauchy dist has a much higher stdDevation and need much less effective parmaters to make a model. Both have a very good rhat.
```

Lets plot the post dist for each of these

```{r}
library(ggplot2)
library(reshape)

vars=extract.samples(mp)
summary(vars)
vars.m <- melt(vars)

ggplot(vars.m, aes(value, fill=L1)) + geom_density(alpha=.2) + facet_grid(L1 ~ .)+ scale_x_continuous(limits = c(-10, 10)) 


```


Compare the samples for the parameters a and b. Can you explain the different trace plots, using what you know about the Cauchy distribution?

```{r}
plot(mp)

```

The cauchy distbution is much more defined this is because it is skewed much more towards one tail

## 8H2. Recall the divorce rate example from Chapter 5. Repeat that analysis, using map2stan this time, fitting models m5.1, m5.2, and m5.3. Use compare to compare the models on the basis of WAIC. Explain the results.

```{r}
# load data
data(WaffleDivorce)
d <- WaffleDivorce
# standardize predictor
d$MedianAgeMarriage.s <- (d$MedianAgeMarriage-mean(d$MedianAgeMarriage))/
    sd(d$MedianAgeMarriage)
# fit model
m5.1 <- map(
    alist(
        Divorce ~ dnorm( mu , sigma ) ,
        mu <- a + bA * MedianAgeMarriage.s ,
        a ~ dnorm( 10 , 10 ) ,
        bA ~ dnorm( 0 , 1 ) ,
        sigma ~ dunif( 0 , 10 )
) , data = d )

d$Marriage.s <- (d$Marriage - mean(d$Marriage))/sd(d$Marriage)
m5.2 <- map(
    alist(
        Divorce ~ dnorm( mu , sigma ) ,
        mu <- a + bR * Marriage.s ,
        a ~ dnorm( 10 , 10 ) ,
        bR ~ dnorm( 0 , 1 ) ,
    sigma ~ dunif( 0 , 10 )
) , data = d )

m5.3 <- map(
    alist(
        Divorce ~ dnorm( mu , sigma ) ,
        mu <- a + bR*Marriage.s + bA*MedianAgeMarriage.s ,
        a ~ dnorm( 10 , 10 ) ,
        bR ~ dnorm( 0 , 1 ) ,
        bA ~ dnorm( 0 , 1 ) ,
        sigma ~ dunif( 0 , 10 )
),
    data = d )

compare(m5.1,m5.2,m5.3)
```


```{r}
m5.1s <- map2stan(
    alist(
        Divorce ~ dnorm( mu , sigma ) ,
        mu <- a + bA * MedianAgeMarriage.s ,
        a ~ dnorm( 10 , 10 ) ,
        bA ~ dnorm( 0 , 1 ) ,
        sigma ~ dunif( 0 , 10 )
) , data = d,iter=1e4, warmup=100 , WAIC=FALSE ) 

plot(m5.1s)

m5.2s <- map2stan(
    alist(
        Divorce ~ dnorm( mu , sigma ) ,
        mu <- a + bR * Marriage.s ,
        a ~ dnorm( 10 , 10 ) ,
        bR ~ dnorm( 0 , 1 ) ,
    sigma ~ dunif( 0 , 10 )
) , data = d,iter=1e4, warmup=100 , WAIC=FALSE )


plot(m5.2s)

m5.3s <- map2stan(
   alist(
        Divorce ~ dnorm( mu , sigma ) ,
        mu <- a + bR*Marriage.s + bA*MedianAgeMarriage.s ,
        a ~ dnorm( 10 , 10 ) ,
        bR ~ dnorm( 0 , 1 ) ,
        bA ~ dnorm( 0 , 1 ) ,
        sigma ~ dunif( 0 , 10 )
),
    data = d,iter=1e4, warmup=100 , WAIC=FALSE )

plot(m5.3s)

compare(m5.1s,m5.2s,m5.3s)
compare(m5.1,m5.2,m5.3)

```


The weights and the ranking stayed the same when using stan verse using not using stan. Yet the devation between models varied more when not using stan for each of the models most likely because stan is using the data to predict the model rather than us telling assuming what the model should be. Because we are using the same data for all three models we expect there to be less varance when we are using the data to build a model.


##8H3. Sometimes changing a prior for one parameter has unanticipated effects on other parameters. This is because when a parameter is highly correlated with another parameter in the posterior, the prior influences both parameters. Here’s an example to work and think through. Go back to the leg length example in Chapter 5. Here is the code again, which simulates height and leg lengths for 100 imagined individuals:


```{r}
N <- 100
height <- rnorm(N,10,2)
leg_prop <- runif(N,0.4,0.5)
leg_left <- leg_prop*height +
  rnorm( N , 0 , 0.02 )
leg_right <- leg_prop*height +
  rnorm( N , 0 , 0.02 )
d <- data.frame(height,leg_left,leg_right)

```

And below is the model you fit before, resulting in a highly correlated posterior for the two beta parameters. This time, fit the model using map2stan:

  
```{r}

m5.8s <- map2stan(
  alist(
    height ~ dnorm( mu , sigma ) ,
    mu <- a + bl*leg_left + br*leg_right ,
    a ~ dnorm( 10 , 100 ) ,
    bl ~ dnorm( 2 , 10 ) ,
    br ~ dnorm( 2 , 10 ) ,
    sigma ~ dcauchy( 0 , 1 )
  ),
  data=d, chains=4, start=list(a=10,bl=0,br=0,sigma=1) )


```
Compare the posterior distribution produced by the code above to the posterior distribution produced when you change the prior for br so that it is strictly positive:
  
```{r}
m5.8s2 <- map2stan(
  alist(
    height ~ dnorm( mu , sigma ) ,
    mu <- a + bl*leg_left + br*leg_right ,
    a ~ dnorm( 10 , 100 ) ,
    bl ~ dnorm( 2 , 10 ) ,
    br ~ dnorm( 2 , 10 ) & T[0,] ,
    ## changed right leg prior to only positive prob
    sigma ~ dcauchy( 0 , 1 )
  ),
  data=d, chains=4, start=list(a=10,bl=0,br=0,sigma=1) )

post <- extract.samples(m5.8s)
plot( bl ~ br , post , col=col.alpha(rangi2,0.1) , pch=16 )

post <- extract.samples(m5.8s2)
plot( bl ~ br , post , col=col.alpha(rangi2,0.1) , pch=16 )

plot(precis(m5.8s))
plot(precis(m5.8s2))



```

Note that T[0,] on the right-hand side of the prior for br. What the T[0,] does is truncate the normal distribution so that it has positive probability only above zero. In other words, that prior ensures that the posterior distribution for br will have no probability mass below zero.
Compare the two posterior distributions for m5.8s and m5.8s2. What has changed in the pos-terior distribution of both beta parameters? Can you explain the change induced by the change in prior?


```{r}

bls <- data.frame(
  m58s=extract.samples(m5.8s)$bl,
  m58s2=extract.samples(m5.8s2)$bl)


brs <- data.frame(
  m58s=extract.samples(m5.8s)$br,
  m58s2=extract.samples(m5.8s2)$br)


brs.m <- melt(brs,variable_name="model")
bls.m <- melt(bls,variable_name="model")

ggplot(brs.m, aes(value,color=model,fill=model)) + geom_density(alpha=.2) + xlab("br value") + labs(title="br post")
ggplot(bls.m, aes(value,color=model,fill=model)) + geom_density(alpha=.2) + xlab("bl value") + labs(title="bl post")

```


when we change the proir this also changes bl values br values because these are higly correlated with one another. Just like in chapter 5 when one is high the other must be small because both need to be incuded in the model and both often lead to the same outcome when they are added together in the model they must give the same outcome (making one large when the other is small so that there outcome is the same). Changing the pior so that one is only postitive only exaggerates this. 

#8H4. For the two models fit in the previous problem, use DIC or WAIC to compare the effective numbers of parameters for each model. Which model has more effective parameters? Why?

```{r}
compare(m5.8s,m5.8s2)
WAIC(m5.8s)

```

this suggests that the two models are very similar in their WAIC scores, the pWAIC is the effective number of paramters the second model containing only postive paramters for br and thus only neg brs requires less paramters and is more flexible. This might be because it makes it easier for stan to make preidictions if br is postive it can also make pridictions for bl.

#8H5. Modify the Metropolis algorithm code from the chapter to handle the case that the island populations have a different distribution than the island labels. This means the island’s number will not be the same as its population.

```{r}

num_weeks <- 1e5
positions <- rep(0,num_weeks) ### all postions are zero
### these are the new populations that do not match the island lable
population <- c(10,1,2,3,5,7,6,8,9,4)
current <- 10

island_vists <- matrix(ncol=1, nrow=num_weeks)

for ( i in 1:num_weeks ) {
    # for i in onther through 1000 weeks
    positions[i] <- current
    ## the position at that week is equal to current first week is 10
    proposal <- current + sample( c(-1,1) , size=1 )
    ### choose either 1 or -1 50:50 and add or subtract currecnt
    
    # This makes sure islands on extreme ends are taken into account
    if ( proposal < 1 ) proposal <- 10
    if ( proposal > 10 ) proposal <- 1
    
    # prob to move is based on ratio to island size... 9 and 10 for example are 1.1 prob or .9.
    ## if prob is 1.1 will it move for sure.. over 100%?
    prob_move <- population[proposal]/population[current]
    ### this now moves to the next island depending on true population size....
    ### Finally, a random number between zero and one is generated (runif(1)), and the king moves, if this random number is less than the ratio of the proposal island’s population to the current island’s population
    current <- ifelse( runif(1) < prob_move , proposal , current )
    island_vists[i,] <- current
    #### so this is somewhat random...
}

colnames(island_vists) <- c("islands")

ggplot(data.frame(island_vists), aes(islands)) +
  geom_density()

### population <- c(10,1,2,3,5,7,6,8,9,4)

```


#8H6. Modify the Metropolis algorithm code from the chapter to write your own simple MCMC estimator for globe tossing data and model from Chapter 2.


```{r}




water_total <- list()
true_prop_water= 0.5
num_tosses <- 1000
result <- rep(0,num_weeks) ### all are zero
current <- 1
water_results <- matrix(ncol=1, nrow=num_tosses)

for ( i in 1:num_tosses ) {
    # for i in onther through 1000 tosses
    result[i] <- current
    ## the result is equal to current first toss of water or 1
    proposal <- current + sample( c(-1,1) , size=1 )
    ### choose either 1 or -1 50:50 for either water or not water
    if ( proposal < 1 ) proposal <- 2
    if ( proposal > 2 ) proposal <- 1
    ### this keeps it moving in a loop 1 for land and 2 for water
    ### we want to avoid the 100% cases where we stay on land or water should move to the next
    prob_move <- proposal/current
    current <- ifelse( runif(1) < prob_move , proposal , current )
    water_results[i,] <- current
    # if a random prob is less than the prob to move do the proposal otherwise keep the current
    ###current_prob_water <- sum(water_total)/length(water_total)
    
}

colnames(water_results) <- c("water")

ggplot(data.frame(water_results), aes(water)) +
  geom_density()

```

```{r, include=FALSE}
   # add this chunk to end of mycode.rmd
   file.rename(from="/Users/gturco/Documents/code/Rclub-rethinking_Gina.Turco/Assignment_Chapter_08/Chapter-08H.Rmd", 
               to="/Users/gturco/Documents/code/Rclub-rethinking_Gina.Turco/Assignment_Chapter_08/Chapter-08H.md")
```

