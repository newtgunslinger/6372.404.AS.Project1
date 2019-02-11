#installing necessary packages
list.of.packages = c("caret", "ggplot2","car","MASS","glmnet","tidyverse","car","ISLR","leaps")
packagesToInstall = paste(list.of.packages[!(list.of.packages %in% installed.packages()[,'Package'])],sep='', collapse=',')

if (!is.na(packagesToInstall) & packagesToInstall !="") {
  TERRPACK = gsub("'","",packagesToInstall)
  TERRPACK = strsplit(TERRPACK,",")
  
  install.packages(unlist(TERRPACK), repos="http://cran.us.r-project.org", quiet=TRUE, verbose=FALSE)
}

suppressWarnings(suppressMessages(library(caret)))
suppressWarnings(suppressMessages(library(ggplot2)))
suppressWarnings(suppressMessages(library(car)))
suppressWarnings(suppressMessages(library(MASS)))
suppressWarnings(suppressMessages(library(glmnet)))
suppressWarnings(suppressMessages(library(tidyverse)))
suppressWarnings(suppressMessages(library(car)))
suppressWarnings(suppressMessages(library(ISLR)))
suppressWarnings(suppressMessages(library(leaps)))

pat.stats.df <- read.csv("./Project1/PatriotsYearlyStats.csv")

str(pat.stats.df)
reg.data.df <- pat.stats.df %>% dplyr::select(-Year,-MadeSuperBowl)
reg.data.df <- reg.data.df[,!(grepl("Opp", names(reg.data.df)))]

reg.data.df$TotalWins <- reg.data.df$RegSeasonWins + reg.data.df$PlayoffWins

reg.var.df <- reg.data.df %>% dplyr::select(-RegSeasonWins, -PlayoffWins)

View(cor(reg.var.df))

ncol(reg.var.df)
par(mfrow = c(3, 3))
for (c in 1:(ncol(reg.var.df) - 1)) {
  single.var.fit <- lm(TotalWins ~ reg.var.df[,c], data = reg.var.df)
  plot(TotalWins ~ reg.var.df[,c], data = reg.var.df, xlab = names(reg.var.df)[c], sub = paste0("R Squared: ", round(summary(single.var.fit)$r.squared, 2)))
  
  abline(single.var.fit)
  print(names(reg.var.df)[c])
}

write.csv(reg.var.df, "PatriotsRegressionData.csv")
# variables with higher covariance
# PassInterceptions
# PassTouchdowns
# PointsDifferential
# BradyPasserRating

test.fit <- lm(TotalWins ~ BradyPasserRating + PointsDifferential, data = reg.var.df)

# lasso variable selection
set.seed(1234)

names(matrix.slim)
lasso.y <- reg.data.df$TotalWins
str(reg.data.df)
lasso.x <- reg.data.df %>% dplyr::select(-RegSeasonWins, -PlayoffWins, -TotalWins)

str(lasso.x)
fit.lasso <- cv.glmnet(x = as.matrix(lasso.x), y = lasso.y, family = "gaussian", alpha = 1)

coef(fit.lasso, s = "lambda.min")
class(lasso.x)
class(lasso.y)

plot(fit.lasso, xvar = "lambda")
summary(fit.lasso)
fit.lasso$df
length(reg.var.df)
regfit.fwd <- regsubsets(TotalWins ~ ., data = reg.var.df, nvmax = 39, method = "forward")
summary(regfit.fwd)
regfit.fwd$vorder
