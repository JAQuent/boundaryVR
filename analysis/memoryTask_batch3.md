Analysis of memory task
================

Analyse data
============

Temporal order memory
---------------------

``` r
# Aggregate data 1
temporalOrder_agg <- ddply(temporalOrder_comb, c('id', 'context'), summarise, 
                           n = length(rt),
                           acc = mean(accuracy), 
                           rt = mean(rt))

# # Aggregate data 1
temporalOrder_comb$context2 <- as.character(temporalOrder_comb$context)
temporalOrder_comb[temporalOrder_comb$context == 'within-no-walls', 'context2'] <- 'within'
temporalOrder_comb[temporalOrder_comb$context == 'within-walls', 'context2'] <- 'within'

temporalOrder_agg2 <- ddply(temporalOrder_comb, c('id', 'context2'), summarise, 
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

![](memoryTask_batch3_files/figure-markdown_github/unnamed-chunk-1-1.png)

As can be seen above, some participants seems to significantly perform below chance. To show this, I simulated a null distribution (see below). In an ANOVA, there were no difference between the conditions:

``` r
ezANOVA(temporalOrder_agg, dv = acc, wid = id, within = context)
```

    ## $ANOVA
    ##    Effect DFn DFd        F          p p<.05       ges
    ## 2 context   2  24 5.226728 0.01305394     * 0.1984575
    ## 
    ## $`Mauchly's Test for Sphericity`
    ##    Effect         W          p p<.05
    ## 2 context 0.4466891 0.01188583     *
    ## 
    ## $`Sphericity Corrections`
    ##    Effect       GGe      p[GG] p[GG]<.05       HFe      p[HF] p[HF]<.05
    ## 2 context 0.6437861 0.02955724         * 0.6879131 0.02669316         *

### Temporal memory: across vs. within

``` r
ggplot(temporalOrder_agg2, aes(x = context2, y = acc)) + 
  geom_boxplot(alpha = 0.5,outlier.shape = NA) + 
  geom_jitter(width = 0.1) +
  geom_hline(yintercept = 1/3) +
  annotate('text', x = 2, y = 0.31, label = 'Chance') +
  labs(y = '3AFC accuracy', x = "Room type", title = 'Temporal Order')
```

![](memoryTask_batch3_files/figure-markdown_github/unnamed-chunk-3-1.png)

``` r
t.test(temporalOrder_agg2[temporalOrder_agg2$context2 == 'across', 4], 
       temporalOrder_agg2[temporalOrder_agg2$context2 == 'within', 4])
```

    ## 
    ##  Welch Two Sample t-test
    ## 
    ## data:  temporalOrder_agg2[temporalOrder_agg2$context2 == "across", 4] and temporalOrder_agg2[temporalOrder_agg2$context2 == "within", 4]
    ## t = -2.3291, df = 23.621, p-value = 0.02874
    ## alternative hypothesis: true difference in means is not equal to 0
    ## 95 percent confidence interval:
    ##  -0.156308860 -0.009371614
    ## sample estimates:
    ## mean of x mean of y 
    ## 0.3688363 0.4516765

Room and table question
-----------------------

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

![](memoryTask_batch3_files/figure-markdown_github/unnamed-chunk-4-1.png)

While performance for the room task was not above chance

``` r
t.test(roomType_comb_agg$acc -0.5)
```

    ## 
    ##  One Sample t-test
    ## 
    ## data:  roomType_comb_agg$acc - 0.5
    ## t = -0.6396, df = 12, p-value = 0.5345
    ## alternative hypothesis: true mean is not equal to 0
    ## 95 percent confidence interval:
    ##  -0.03911106  0.02135958
    ## sample estimates:
    ##   mean of x 
    ## -0.00887574

the performance for the table question was:

``` r
t.test(tableNum_comb_agg$acc - 0.5)
```

    ## 
    ##  One Sample t-test
    ## 
    ## data:  tableNum_comb_agg$acc - 0.5
    ## t = 3.4153, df = 12, p-value = 0.005122
    ## alternative hypothesis: true mean is not equal to 0
    ## 95 percent confidence interval:
    ##  0.04391764 0.19868591
    ## sample estimates:
    ## mean of x 
    ## 0.1213018

Predicting trial-to-trial accruacy and influence of foil distance
=================================================================

For this section, I fished around to see what the relationship between context and foil distance might be and whether the effect of context differs as a function of the foil distance.

``` r
# Create data.frame to analyse trial-to-trial accuracy 
temporalOrder_comb_foilDist <- ddply(temporalOrder_comb,
                                     c('id', 'trial_index', 'context'),
                                     summarise,
                                     minDist = min(abs(dist1), abs(dist2)),
                                     maxDist = max(abs(dist1), abs(dist2)),
                                     meanDist = mean(abs(dist1), abs(dist2)),
                                     dist1 = dist1,
                                     dist2 = dist2,
                                     accuracy = accuracy)

# Predictin accuracy based on context
m_context <- glmer(accuracy ~ context + (1| id ), 
                   family = binomial, 
                   data = temporalOrder_comb_foilDist)
summary(m_context)
```

    ## Generalized linear mixed model fit by maximum likelihood (Laplace
    ##   Approximation) [glmerMod]
    ##  Family: binomial  ( logit )
    ## Formula: accuracy ~ context + (1 | id)
    ##    Data: temporalOrder_comb_foilDist
    ## 
    ##      AIC      BIC   logLik deviance df.resid 
    ##   1365.9   1385.6   -679.0   1357.9     1010 
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -1.1301 -0.8215 -0.7252  1.1314  1.4836 
    ## 
    ## Random effects:
    ##  Groups Name        Variance Std.Dev.
    ##  id     (Intercept) 0.04538  0.213   
    ## Number of obs: 1014, groups:  id, 13
    ## 
    ## Fixed effects:
    ##                        Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)             -0.5432     0.1099  -4.944 7.66e-07 ***
    ## contextwithin-no-walls   0.1464     0.1586   0.923 0.356003    
    ## contextwithin-walls      0.5432     0.1565   3.470 0.000521 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##             (Intr) cntx--
    ## cntxtwthn-- -0.491       
    ## cntxtwthn-w -0.499  0.345

This actually shows tha the contrast between across and within-walls is close to be significant.

``` r
m_foil1 <- glmer(accuracy ~ minDist + maxDist + meanDist + (1 | id ), 
                 family = binomial, 
                 data = temporalOrder_comb_foilDist)
summary(m_foil1)
```

    ## Generalized linear mixed model fit by maximum likelihood (Laplace
    ##   Approximation) [glmerMod]
    ##  Family: binomial  ( logit )
    ## Formula: accuracy ~ minDist + maxDist + meanDist + (1 | id)
    ##    Data: temporalOrder_comb_foilDist
    ## 
    ##      AIC      BIC   logLik deviance df.resid 
    ##   1376.4   1401.0   -683.2   1366.4     1009 
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -1.1236 -0.8364 -0.7486  1.1550  1.5124 
    ## 
    ## Random effects:
    ##  Groups Name        Variance Std.Dev.
    ##  id     (Intercept) 0.04522  0.2127  
    ## Number of obs: 1014, groups:  id, 13
    ## 
    ## Fixed effects:
    ##               Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept) -0.6654937  0.1917568  -3.471 0.000519 ***
    ## minDist      0.0130893  0.0085396   1.533 0.125329    
    ## maxDist      0.0045125  0.0046159   0.978 0.328270    
    ## meanDist    -0.0009655  0.0044039  -0.219 0.826468    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##          (Intr) minDst maxDst
    ## minDist  -0.465              
    ## maxDist  -0.647  0.096       
    ## meanDist  0.038 -0.303 -0.489
    ## convergence code: 0
    ## Model failed to converge with max|grad| = 0.00141793 (tol = 0.001, component 1)

No absolute aggregate meassures across both foils predict accuracy.

``` r
m_foil2 <- glmer(accuracy ~ dist1 + dist2 + (1 | id ), 
                 family = binomial, 
                 data = temporalOrder_comb_foilDist)
summary(m_foil2)
```

    ## Generalized linear mixed model fit by maximum likelihood (Laplace
    ##   Approximation) [glmerMod]
    ##  Family: binomial  ( logit )
    ## Formula: accuracy ~ dist1 + dist2 + (1 | id)
    ##    Data: temporalOrder_comb_foilDist
    ## 
    ##      AIC      BIC   logLik deviance df.resid 
    ##   1375.3   1395.0   -683.6   1367.3     1010 
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -1.0357 -0.8374 -0.7495  1.1537  1.4961 
    ## 
    ## Random effects:
    ##  Groups Name        Variance Std.Dev.
    ##  id     (Intercept) 0.04527  0.2128  
    ## Number of obs: 1014, groups:  id, 13
    ## 
    ## Fixed effects:
    ##              Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept) -0.646713   0.190620  -3.393 0.000692 ***
    ## dist1       -0.005417   0.004077  -1.329 0.183965    
    ## dist2        0.006240   0.004209   1.482 0.138220    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##       (Intr) dist1 
    ## dist1  0.748       
    ## dist2 -0.761 -0.441

If both raw distances are entered, then the distance of foil2 is close to be significant. This foil is like the target after the probe. The other foil doesn't seem to have an influence.

``` r
m_context2 <- glmer(accuracy ~ context*dist2 + (1| id ), 
                    family = binomial, 
                    data = temporalOrder_comb_foilDist)
summary(m_context2)
```

    ## Generalized linear mixed model fit by maximum likelihood (Laplace
    ##   Approximation) [glmerMod]
    ##  Family: binomial  ( logit )
    ## Formula: accuracy ~ context * dist2 + (1 | id)
    ##    Data: temporalOrder_comb_foilDist
    ## 
    ##      AIC      BIC   logLik deviance df.resid 
    ##   1368.8   1403.3   -677.4   1354.8     1007 
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -1.1861 -0.8174 -0.7026  1.1221  1.6305 
    ## 
    ## Random effects:
    ##  Groups Name        Variance Std.Dev.
    ##  id     (Intercept) 0.04666  0.216   
    ## Number of obs: 1014, groups:  id, 13
    ## 
    ## Fixed effects:
    ##                               Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)                  -0.747713   0.169998  -4.398 1.09e-05 ***
    ## contextwithin-no-walls        0.474308   0.280783   1.689   0.0912 .  
    ## contextwithin-walls           0.681461   0.272164   2.504   0.0123 *  
    ## dist2                         0.008693   0.005425   1.602   0.1091    
    ## contextwithin-no-walls:dist2 -0.013497   0.009276  -1.455   0.1456    
    ## contextwithin-walls:dist2    -0.005921   0.009329  -0.635   0.5257    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##             (Intr) cntx-- cntxt- dist2  cn--:2
    ## cntxtwthn-- -0.529                            
    ## cntxtwthn-w -0.545  0.329                     
    ## dist2       -0.760  0.458  0.473              
    ## cntxtwt--:2  0.443 -0.824 -0.276 -0.583       
    ## cntxtwth-:2  0.440 -0.266 -0.818 -0.579  0.338

If we controll for the difference of foil 2, then the effect of within-walls get bigger and both the contrast between across and within-walls and the effect of the distance of foil 2 are close to be significant.

Binary distance
---------------

``` r
binDist2 <- rep('close', dim(temporalOrder_comb_foilDist)[1])
binDist2[temporalOrder_comb_foilDist$dist2 >= median(temporalOrder_comb_foilDist$dist2)] <- 'far'
temporalOrder_comb_foilDist$binDist2 <- binDist2

m_context3 <- glmer(accuracy ~ context*binDist2 + (1| id ), 
                    family = binomial, 
                    data = temporalOrder_comb_foilDist)
summary(m_context3)
```

    ## Generalized linear mixed model fit by maximum likelihood (Laplace
    ##   Approximation) [glmerMod]
    ##  Family: binomial  ( logit )
    ## Formula: accuracy ~ context * binDist2 + (1 | id)
    ##    Data: temporalOrder_comb_foilDist
    ## 
    ##      AIC      BIC   logLik deviance df.resid 
    ##   1369.0   1403.5   -677.5   1355.0     1007 
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -1.1410 -0.8155 -0.6969  1.1194  1.6079 
    ## 
    ## Random effects:
    ##  Groups Name        Variance Std.Dev.
    ##  id     (Intercept) 0.04667  0.216   
    ## Number of obs: 1014, groups:  id, 13
    ## 
    ## Fixed effects:
    ##                                    Estimate Std. Error z value Pr(>|z|)
    ## (Intercept)                         -0.6976     0.1446  -4.825  1.4e-06
    ## contextwithin-no-walls               0.2994     0.2363   1.267  0.20509
    ## contextwithin-walls                  0.6784     0.2252   3.012  0.00259
    ## binDist2far                          0.3143     0.1858   1.692  0.09069
    ## contextwithin-no-walls:binDist2far  -0.3120     0.3197  -0.976  0.32916
    ## contextwithin-walls:binDist2far     -0.2776     0.3136  -0.885  0.37605
    ##                                       
    ## (Intercept)                        ***
    ## contextwithin-no-walls                
    ## contextwithin-walls                ** 
    ## binDist2far                        .  
    ## contextwithin-no-walls:binDist2far    
    ## contextwithin-walls:binDist2far       
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##             (Intr) cntx-- cntxt- bnDst2 c--:D2
    ## cntxtwthn-- -0.505                            
    ## cntxtwthn-w -0.531  0.324                     
    ## binDist2far -0.645  0.393  0.413              
    ## cntxtw--:D2  0.373 -0.739 -0.239 -0.579       
    ## cntxtwt-:D2  0.381 -0.233 -0.718 -0.592  0.343

Effect of condition
-------------------

``` r
temporalOrder_comb$condition <- as.factor(temporalOrder_comb$condition)
m_context3 <- glmer(accuracy ~ context*condition + (1| id ), 
                   family = binomial, 
                   data = temporalOrder_comb)
summary(m_context3)
```

    ## Generalized linear mixed model fit by maximum likelihood (Laplace
    ##   Approximation) [glmerMod]
    ##  Family: binomial  ( logit )
    ## Formula: accuracy ~ context * condition + (1 | id)
    ##    Data: temporalOrder_comb
    ## 
    ##      AIC      BIC   logLik deviance df.resid 
    ##   1377.8   1441.8   -675.9   1351.8     1001 
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -1.3932 -0.8223 -0.6923  1.1980  1.4772 
    ## 
    ## Random effects:
    ##  Groups Name        Variance Std.Dev.
    ##  id     (Intercept) 0.04093  0.2023  
    ## Number of obs: 1014, groups:  id, 13
    ## 
    ## Fixed effects:
    ##                                   Estimate Std. Error z value Pr(>|z|)   
    ## (Intercept)                       -0.50005    0.19402  -2.577  0.00996 **
    ## contextwithin-no-walls             0.12521    0.28669   0.437  0.66229   
    ## contextwithin-walls                0.34888    0.27926   1.249  0.21155   
    ## condition5                        -0.04908    0.29744  -0.165  0.86894   
    ## condition6                        -0.08716    0.29819  -0.292  0.77007   
    ## condition7                        -0.04900    0.29744  -0.165  0.86914   
    ## contextwithin-no-walls:condition5 -0.05706    0.43657  -0.131  0.89601   
    ## contextwithin-walls:condition5     0.74514    0.43762   1.703  0.08863 . 
    ## contextwithin-no-walls:condition6  0.28388    0.43754   0.649  0.51646   
    ## contextwithin-walls:condition6     0.17086    0.42805   0.399  0.68978   
    ## contextwithin-no-walls:condition7 -0.12896    0.43803  -0.294  0.76844   
    ## contextwithin-walls:condition7    -0.04959    0.43267  -0.115  0.90875   
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##             (Intr) cntx-- cntxt- cndtn5 cndtn6 cndtn7 cn--:5 cnt-:5 cn--:6
    ## cntxtwthn-- -0.493                                                        
    ## cntxtwthn-w -0.506  0.342                                                 
    ## condition5  -0.652  0.321  0.330                                          
    ## condition6  -0.650  0.321  0.329  0.425                                   
    ## condition7  -0.652  0.321  0.330  0.426  0.425                            
    ## cntxtwt--:5  0.324 -0.657 -0.225 -0.497 -0.211 -0.211                     
    ## cntxtwth-:5  0.323 -0.218 -0.638 -0.497 -0.210 -0.211  0.338              
    ## cntxtwt--:6  0.323 -0.655 -0.224 -0.211 -0.498 -0.211  0.430  0.143       
    ## cntxtwth-:6  0.330 -0.223 -0.652 -0.215 -0.510 -0.215  0.147  0.417  0.347
    ## cntxtwt--:7  0.322 -0.654 -0.224 -0.210 -0.210 -0.496  0.430  0.143  0.429
    ## cntxtwth-:7  0.326 -0.221 -0.645 -0.213 -0.212 -0.502  0.145  0.412  0.145
    ##             cnt-:6 cn--:7
    ## cntxtwthn--              
    ## cntxtwthn-w              
    ## condition5               
    ## condition6               
    ## condition7               
    ## cntxtwt--:5              
    ## cntxtwth-:5              
    ## cntxtwt--:6              
    ## cntxtwth-:6              
    ## cntxtwt--:7  0.146       
    ## cntxtwth-:7  0.421  0.341

Conclusion
==========

Obviously, this all has to be taken with the caution that a) post-hoc fishing and b) low N. So I think we should run another batch.
