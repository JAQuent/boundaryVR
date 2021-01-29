#ddply(df_order_exp3, c('context'), summarise, accuracy = mean(accuracy), rt = mean(rt))
#table(agg2$subjCond)
# t.test(agg2[agg2$context == 'within', "accuracy"], agg2[agg2$context == 'across', "accuracy"], alternative = 'greater')


 outlier_data <- ddply(df_order_exp3, c('worker_id'), summarise, accuracy = mean(accuracy), rt = mean(rt))
 outlier_data$trans_acc         <- arcsine_transform(outlier_data$accuracy)
 outlier_data$trans_acc_outlier <- mad_outlier(outlier_data$trans_acc, 2)
 outlier_data$rt_outlier        <- mad_outlier(outlier_data$rt, 3)
 
 
 outlier_data[outlier_data$trans_acc_outlier == 1, 'worker_id']
 
 
agg1$trans_acc <- arcsine_transform(agg1$accuracy)

ddply(agg1, c('half', 'context'), summarise, accuracy = mean(trans_acc), rt = mean(rt))

ggplot(agg1, aes(x = context, y = trans_acc)) + facet_grid(~ half) +
  geom_boxplot() + geom_hline(yintercept = arcsine_transform(1/3))+
geom_line(aes(group = worker_id)) +
  geom_point()


ttestBF(agg2[agg2$context == 'within', "rt"],
        agg2[agg2$context == 'across', "rt"], paired = TRUE, nullInterval = c(-Inf, 0))