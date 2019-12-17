Analysis of memory task
================

Analyse data
============

Temporal order memory
---------------------

![](memoryTask_batch3_files/figure-markdown_github/unnamed-chunk-1-1.png)

As you can see above, most participants now perform above chance. Below, you see the ANOVA comparing the different conditions.

Interestingly, there was a main effect of context, p = .03. In **uncorrected** pairwise t-tests, performance in the within-wall condition was better than across rooms, p = .007, and better than in the within-no-walls condition, p = .041. However, performance in the within-no-wall condition was not better than in the across condition, p = .45. The average values can be found here:

| context         |   accuracy|         SD|
|:----------------|----------:|----------:|
| across          |  0.3688363|  0.0962469|
| within-no-walls |  0.4038462|  0.1189249|
| within-walls    |  0.5008097|  0.1322718|

The mean accuracy difference between across and within-no-walls is 0.035 (SD = 0.0795), while it is 0.132 (SD = 0.1693) for the within-wall condition. Here is the Table 1 from his paper for *'Which object came next?'*

| Experiment | Context |  accuracy|    SD|
|:-----------|:--------|---------:|-----:|
| Exp 1      | within  |      0.52|  0.15|
| Exp 1      | across  |      0.42|  0.10|
| Exp 2      | within  |      0.45|  0.17|
| Exp 2      | across  |      0.38|  0.18|
| Exp 3      | within  |      0.52|  0.18|
| Exp 3      | across  |      0.44|  0.14|

his boundary effects are 0.1, 0.07, 0.08 and for the question *'Which object came before?'*

| Experiment | Context |  accuracy|    SD|
|:-----------|:--------|---------:|-----:|
| Exp 1      | within  |      0.42|  0.15|
| Exp 1      | across  |      0.38|  0.13|
| Exp 2      | within  |      0.46|  0.21|
| Exp 2      | across  |      0.41|  0.16|
| Exp 3      | within  |      0.49|  0.18|
| Exp 3      | across  |      0.44|  0.17|

here the boundary effects are 0.04, 0.05, 0.05. This is not much different from our effect if this is not just noise. The problem is that those low effects are observed for the question that we're not testing. It could very well that we just don't have enough power for to find this effect. The question then would be why is the effect stronger in the within-wall condition.

### Temporal memory: across vs. within

![](memoryTask_batch3_files/figure-markdown_github/unnamed-chunk-6-1.png)

When I colllasp across both within-room conditions, the difference between across and within rooms is significantly different, p = .008. The mean differnce is 0.0828 (SD = 0.0931 ).

Room and table question
-----------------------

![](memoryTask_batch3_files/figure-markdown_github/unnamed-chunk-7-1.png)

As in Batch 2, participants did not perform above chance for the room type question, p = .534 but they did for the table question, p = .005.

Predicting trial-to-trial accruacy and influence of foil distance
=================================================================

For this section, I fished around to see what the relationship between context and foil distance might be and whether the effect of context differs as a function of the foil distance.

|                        |  Estimate|    SE|      Z|       P| Sig    |
|------------------------|---------:|-----:|------:|-------:|:-------|
| (Intercept)            |     -0.54|  0.11|  -4.94|  0.0000| \*\*\* |
| contextwithin-no-walls |      0.15|  0.16|   0.92|  0.3560|        |
| contextwithin-walls    |      0.54|  0.16|   3.47|  0.0005| \*\*\* |

In a logistic regrression model (see above) with context as fixed effect and a random intercept for each participant, the contrast between across and within-no-wall was not significant, p = .356, while the contrast between across and within-walls was, p &lt; .001.

|             |  Estimate|    SE|      Z|       P| Sig    |
|-------------|---------:|-----:|------:|-------:|:-------|
| (Intercept) |     -0.67|  0.19|  -3.47|  0.0005| \*\*\* |
| minDist     |      0.01|  0.01|   1.53|  0.1253|        |
| maxDist     |      0.00|  0.00|   0.98|  0.3283|        |
| meanDist    |      0.00|  0.00|  -0.22|  0.8265|        |

In another step, I tried to predict accuracy by including fixed effects for the absolute minimum, maximum and mean distance values of foil 1 (before cue/probe) and foil 2 (after cue/probe). In other words, for each trial I for instance used the minimum of both absolute distances. However as can you can see above, none significantly predicts accuracy.

|             |  Estimate|    SE|      Z|       P| Sig    |
|-------------|---------:|-----:|------:|-------:|:-------|
| (Intercept) |     -0.65|  0.19|  -3.39|  0.0007| \*\*\* |
| dist1       |     -0.01|  0.00|  -1.33|  0.1840|        |
| dist2       |      0.01|  0.00|   1.48|  0.1382|        |

When I use the raw distance values of foil 1 and foil 2, there again were no significant effects even though the distance of foil 2 to the cue/probe was relatively small, p = .138.

|                              |  Estimate|    SE|      Z|       P| Sig    |
|------------------------------|---------:|-----:|------:|-------:|:-------|
| (Intercept)                  |     -0.75|  0.17|  -4.40|  0.0000| \*\*\* |
| contextwithin-no-walls       |      0.47|  0.28|   1.69|  0.0912| .      |
| contextwithin-walls          |      0.68|  0.27|   2.50|  0.0123| \*     |
| dist2                        |      0.01|  0.01|   1.60|  0.1091|        |
| contextwithin-no-walls:dist2 |     -0.01|  0.01|  -1.46|  0.1456|        |
| contextwithin-walls:dist2    |     -0.01|  0.01|  -0.63|  0.5257|        |

In a next step, I included context and dist2 as predictors in the logistic regression model and allowed an interaction between both fixed effects. As you can see none of the interactions are significant but, a) there is again a significant contrast between across and within-walls, p = .012. Most interestingly, there is also trend for the contrast between across and within-no-walls, p = .091.

Binary distance
---------------

|                                    |  Estimate|    SE|      Z|       P| Sig    |
|------------------------------------|---------:|-----:|------:|-------:|:-------|
| (Intercept)                        |     -0.70|  0.14|  -4.83|  0.0000| \*\*\* |
| contextwithin-no-walls             |      0.30|  0.24|   1.27|  0.2051|        |
| contextwithin-walls                |      0.68|  0.23|   3.01|  0.0026| \*\*   |
| binDist2far                        |      0.31|  0.19|   1.69|  0.0907| .      |
| contextwithin-no-walls:binDist2far |     -0.31|  0.32|  -0.98|  0.3292|        |
| contextwithin-walls:binDist2far    |     -0.28|  0.31|  -0.89|  0.3761|        |

If I use a binary measure of foil distance instead of a continuous one, then the effects don't chance a lot actually.

The mean accuracy between trial where foil 2 is far way compared to close is 0.0432 (SD = 0.0432), p = .167.

| context         | binDist2 |    N|   accuracy|
|:----------------|:---------|----:|----------:|
| across          | close    |  263|  0.3346008|
| across          | far      |  244|  0.4057377|
| within-no-walls | close    |  109|  0.4036697|
| within-no-walls | far      |  144|  0.4027778|
| within-walls    | close    |  121|  0.4958678|
| within-walls    | far      |  133|  0.5037594|

I've furthermore tested the interaction between our contrasts (across vs. within-walls and across vs. wihtin-no-walls) and the distance between trials with close and far foil 2. The first contrasts shows no interaction, 0.1564 (SD = 0.171) vs 0.1059 (SD = 0.2123), p = .333, so that the boundary effect is similar for far and close foil 2s. The same is true for the contrast of across vs. within-no-walls,0.0714 (SD = 0.1379) vs -0.0053 (SD = 0.1566), p = .28.

Effect of condition
-------------------

|                                   |  Estimate|    SE|      Z|       P| Sig  |
|-----------------------------------|---------:|-----:|------:|-------:|:-----|
| (Intercept)                       |     -0.50|  0.19|  -2.58|  0.0100| \*\* |
| contextwithin-no-walls            |      0.13|  0.29|   0.44|  0.6623|      |
| contextwithin-walls               |      0.35|  0.28|   1.25|  0.2115|      |
| condition6                        |     -0.05|  0.30|  -0.16|  0.8689|      |
| condition7                        |     -0.09|  0.30|  -0.29|  0.7701|      |
| condition8                        |     -0.05|  0.30|  -0.16|  0.8691|      |
| contextwithin-no-walls:condition6 |     -0.06|  0.44|  -0.13|  0.8960|      |
| contextwithin-walls:condition6    |      0.75|  0.44|   1.70|  0.0886| .    |
| contextwithin-no-walls:condition7 |      0.28|  0.44|   0.65|  0.5165|      |
| contextwithin-walls:condition7    |      0.17|  0.43|   0.40|  0.6898|      |
| contextwithin-no-walls:condition8 |     -0.13|  0.44|  -0.29|  0.7684|      |
| contextwithin-walls:condition8    |     -0.05|  0.43|  -0.11|  0.9087|      |

In the last step, I included condition as fixed effect. After replacing the problematic participants it's a good sign that there are no significant interactions left between any context contrast and conditions. To see how the results differ across the different conditions, I plot them seperately.

![](memoryTask_batch3_files/figure-markdown_github/unnamed-chunk-16-1.png)

Conclusion
==========

We have robust and strong effect in the within-wall condition and only when we controll for distance between foil 2 to the cue/probe, there is a trend for the contrast between across and within-no-walls.
