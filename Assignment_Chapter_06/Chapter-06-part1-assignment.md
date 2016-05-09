__Name:__Gina Turco


# For 05/09/2016

## 6E1. State the three motivating criteria that define information entropy. Try to express each in your own words.

1. Our measure of uncertanity needs to be on a continous scale not a discrete scale.

2. Uncertanity needs increase with the number of events that exsit because there are now more events that we are uncertain about the outcome for.

3. Uncertainty measures should be additive so that all events add up to 100% and thus can be combines to gain probabilities for each one.

## 6E2. Suppose a coin is weighted such that, when it is tossed and lands on a table, it comes up heads 70% of the time. What is the entropy of this coin?

The entropy of the coin is 0.61


```r
p <- c(0.7,0.3)
-sum(p*log(p))
```

```
## [1] 0.6108643
```

## 6E3. Suppose a four-sided die is loaded such that, when tossed onto a table, it shows “1” 20%, “2” 25%, ”3” 25%, and ”4” 30% of the time. What is the entropy of this die?

the entropy of a 4 sided die with the following probs is 1.376


```r
p <- c(0.2,0.25,0.25,0.3)
-sum(p*log(p))
```

```
## [1] 1.376227
```

## 6E4. Suppose another four-sided die is loaded such that it never shows “4”. The other three sides show equally often. What is the entropy of this die?

The entropy is a little lower 1.0985


```r
p <- c(0.333,0.333,0.333)
-sum(p*log(p))
```

```
## [1] 1.098513
```




