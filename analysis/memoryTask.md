Analysis of memory task
================

Analyse data
============

Analysis of raw data
--------------------

### Temporal order memory

``` r
# Aggregate data
temporalOrder_agg <- ddply(temporalOrder_comb, c('id', 'context'), summarise, 
                           n = length(rt),
                           acc = mean(accuracy), 
                           rt = mean(rt))

afcPlot <- ggplot(temporalOrder_agg, aes(x = context, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1) +
  geom_hline(yintercept = 1/3) +
  annotate('text', x = 2, y = 0.31, label = 'Chance') +
  labs(y = '3AFC accuracy', x = "Room type", title = 'Temporal Order')


rtPlot <- ggplot(temporalOrder_agg, aes(x = context, y = rt)) + 
  geom_boxplot(alpha = 0.5, outlier.shape = NA) + 
  geom_jitter(width = 0.5) +
  labs(y = 'RT (msec)', x = "Room type", title = '')

plot_grid(afcPlot, rtPlot)
```

![](memoryTask_files/figure-markdown_github/unnamed-chunk-1-1.png)

As can be seen above, some participants seems to significantly peforme below chance. To show this, I simulated a null distribution (see below). In an ANOVA, there were no difference between the conditions:

``` r
ezANOVA(temporalOrder_agg, dv = acc, wid = id, within = context)
```

    ## $ANOVA
    ##    Effect DFn DFd         F         p p<.05        ges
    ## 2 context   2  22 0.2556536 0.7766791       0.01447536
    ## 
    ## $`Mauchly's Test for Sphericity`
    ##    Effect         W        p p<.05
    ## 2 context 0.7082561 0.178218      
    ## 
    ## $`Sphericity Corrections`
    ##    Effect       GGe     p[GG] p[GG]<.05       HFe     p[HF] p[HF]<.05
    ## 2 context 0.7741473 0.7212708           0.8770658 0.7486132

### Room and table question

``` r
#Aggregate data
roomType_comb_agg <- ddply(roomType_comb, c('id'), summarise, acc = mean(accuracy), rt = mean(rt))
tableNum_comb_agg <- ddply(tableNum_comb, c('id'), summarise, acc = mean(accuracy), rt = mean(rt))

roomTable_agg <- data.frame(id = rep(1:n, 2),
                            Type = rep(c('Room', 'Table'), each = n),
                            acc = c(roomType_comb_agg$acc, tableNum_comb_agg$acc))

ggplot(roomTable_agg, aes(x = Type, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1) +
  geom_hline(yintercept = 0.5) +
  annotate('text', x = 1.5, y = 0.48, label = 'Chance') +
  labs(y = 'Accuracy', x = "Memory type", title = 'Memory for room type and table')
```

![](memoryTask_files/figure-markdown_github/unnamed-chunk-3-1.png)

While performance for the room task was not above chance

``` r
t.test(roomType_comb_agg$acc -0.5)
```

    ## 
    ##  One Sample t-test
    ## 
    ## data:  roomType_comb_agg$acc - 0.5
    ## t = 1.3498, df = 11, p-value = 0.2042
    ## alternative hypothesis: true mean is not equal to 0
    ## 95 percent confidence interval:
    ##  -0.01212586  0.05058740
    ## sample estimates:
    ##  mean of x 
    ## 0.01923077

the peformance for the table question was:

``` r
t.test(tableNum_comb_agg$acc - 0.5)
```

    ## 
    ##  One Sample t-test
    ## 
    ## data:  tableNum_comb_agg$acc - 0.5
    ## t = 2.794, df = 11, p-value = 0.01746
    ## alternative hypothesis: true mean is not equal to 0
    ## 95 percent confidence interval:
    ##  0.01882183 0.15852860
    ## sample estimates:
    ##  mean of x 
    ## 0.08867521

Simulating a null distribution for temporal memory
==================================================

With random guesses participants should get an average accuracy of 1/3 in the 3AFC task. However, some participants' accuracy is extremely low. To exclude those participants that actually peforme below chance, I simulated a null distribution (N = 10000) for each condition since each condition has different number of trials.

``` r
# Simulation parameters
nSims     <- 10000
nTrials   <- c(39, 20, 19) # trials per condiiton
accDist1  <- c()
accDist2  <- c()
accDist3  <- c()

# Simulation
for(i in 1:nSims){
  accDist1[i] <- mean(rbinom(nTrials[1], 1, 1/3))
  accDist2[i] <- mean(rbinom(nTrials[2], 1, 1/3))
  accDist3[i] <- mean(rbinom(nTrials[3], 1, 1/3))
}

# Bind to df
accDists <- data.frame(Context = rep(c('across', 'within-no-walls', 'within-walls'), each = nSims),
                       Accuracy = c(accDist1, accDist2, accDist3))
cutOffs  <-  data.frame(Context = c('across', 'within-no-walls', 'within-walls'),
                        Accuracy = c(quantile(accDist1, 0.05),
                                     quantile(accDist2, 0.05),
                                     quantile(accDist3, 0.05)))

# Plot distributions
ggplot(accDists, aes(x = Accuracy)) + 
  facet_grid(.~ Context) + 
  geom_histogram() + 
  geom_vline(data = cutOffs, aes(xintercept = Accuracy), linetype = 'dashed')
```

![](memoryTask_files/figure-markdown_github/unnamed-chunk-6-1.png)

Above, you see the null distrubtion that we would expect if participants answer randomly. We will re-ran the analysis using the following cut-offs

``` r
kable(cutOffs)
```

| Context         |   Accuracy|
|:----------------|----------:|
| across          |  0.2051282|
| within-no-walls |  0.1500000|
| within-walls    |  0.1578947|

and exclude anyone scoring below any of these cut-offs.

Exlcuding participants that are below 5th percentile of null distribution
=========================================================================

``` r
# Create exlusion var and set to 0 as default
exclude <- rep(0, n)
context <- c('across', 'within-no-walls', 'within-walls')

for(i in 1:dim(temporalOrder_agg)[1]){
  # Exclude if accuracy is below cut-off for given condition
  if(temporalOrder_agg$acc[i] < cutOffs$Accuracy[cutOffs$Context == temporalOrder_agg$context[i]]){
    exclude[temporalOrder_agg$id[i]] <- 1
  }
}

# Create subset
temporalOrder_agg$exclude <- rep(exclude, each = 3)
temporalOrder_agg_sub     <- subset(temporalOrder_agg, temporalOrder_agg$exclude == 0)
```

Based on the cut-offs, I excluded 4 participants from the analysis.

Temporal order memory on subset
===============================

``` r
# Aggregate data
afcPlot <- ggplot(temporalOrder_agg_sub, aes(x = context, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1) +
  geom_hline(yintercept = 1/3) +
  annotate('text', x = 2, y = 0.31, label = 'Chance') +
  labs(y = '3AFC accuracy', x = "Room type", title = 'Temporal Order')


rtPlot <- ggplot(temporalOrder_agg_sub, aes(x = context, y = rt)) + 
  geom_boxplot(alpha = 0.5, outlier.shape = NA) + 
  geom_jitter(width = 0.5) +
  labs(y = 'RT (msec)', x = "Room type", title = '')

plot_grid(afcPlot, rtPlot)
```

![](memoryTask_files/figure-markdown_github/unnamed-chunk-9-1.png)

However, there are still no significant difference between the conditions:

``` r
ezANOVA(temporalOrder_agg_sub, dv = acc, wid = id, within = context)
```

    ## $ANOVA
    ##    Effect DFn DFd        F         p p<.05       ges
    ## 2 context   2  14 1.849404 0.1937707       0.1006296
    ## 
    ## $`Mauchly's Test for Sphericity`
    ##    Effect         W        p p<.05
    ## 2 context 0.5406862 0.158065      
    ## 
    ## $`Sphericity Corrections`
    ##    Effect       GGe     p[GG] p[GG]<.05       HFe     p[HF] p[HF]<.05
    ## 2 context 0.6852536 0.2091039           0.7961692 0.2039348

Unexpectedly, the effect size increased with increased memory for the across and the within-walls condition.
