library(data.table)
system.time({
tmp = fread("train.csv")
})
rows_with_positive_attributed = which(tmp$is_attributed == 1)
other_rows = which(tmp$is_attributed == 0)

n = 100000
m = 200000

set.seed(888)
rows_selected = sample(rows_with_positive_attributed, size = n, replace = FALSE)
extra         = tmp[rows_selected, ]

set.seed(888)
rows_selected1 = sample(other_rows, size = m, replace = FALSE)
extra1         = tmp[rows_selected, ]

rm(tmp)
gc()
train_sample = fread("train_sample.csv")
train_extra = rbind(extra1, extra, train_sample)
write.csv(train_extra, "train_extra1.csv", row.names = FALSE)



