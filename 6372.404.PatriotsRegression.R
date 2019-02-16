#installing necessary packages
list.of.packages = c("caret", "ggplot2","car","MASS","glmnet","tidyverse","car","ISLR","leaps","lars")
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
suppressWarnings(suppressMessages(library(lars)))

pat.stats.df <- read.csv("./Project1/PatriotsYearlyStats.csv")

str(pat.stats.df)
reg.data.df <- pat.stats.df %>% dplyr::select(-Year,-MadeSuperBowl)
reg.data.df <- reg.data.df[,!(grepl("Opp", names(reg.data.df)))]

reg.var.df$CompletionPercentage <- reg.var.df$PassCompletions / reg.var.df$PassAttempts

str(reg.var.df)
attach(reg.var.df)
reg.var.df <- reg.var.df %>% select(RegSeasonWins, BradyPasserRating, PointsFor, PointsAgainst, PointsDifferential, 
                                    MarginOfVictory, StrengthOfSchedule, SimpleRatingSystem, OffSimpleRatingSys, DefSimpleRatingSys,
                                    PassCompletions, PassAttempts, CompletionPercentage, PassYards, PassTouchdowns, PassInterceptions, 
                                    NetYardsPerPass, PassFirstDowns)
detach(reg.var.df)
attach(reg.var.df)

par(mfrow = c(6, 3))
for (c in 2:(ncol(reg.var.df) - 1)) {
  single.var.fit <- lm(RegSeasonWins ~ reg.var.df[,c], data = reg.var.df)
  plot(RegSeasonWins ~ reg.var.df[,c], data = reg.var.df, xlab = names(reg.var.df)[c],
       sub = paste0("R Squared: ", round(summary(single.var.fit)$r.squared, 2)))
  
  abline(single.var.fit)
  print(names(reg.var.df)[c])
}

pairs(reg.var.df)

test.fit <- lm(TotalWins ~ BradyPasserRating + PointsDifferential, data = reg.var.df)

# lasso variable selection
set.seed(1234)

var.y <- reg.var.df$RegSeasonWins
var.x <- reg.var.df %>% dplyr::select(-RegSeasonWins)

# lasso variable selection
par(mfrow = c(1,1))
fit.lasso <- glmnet(x = as.matrix(var.x), y = var.y, family = "gaussian", alpha = 1)
plot(fit.lasso, xvar = "lambda", label = TRUE)
sel.lasso <- cv.glmnet(x = as.matrix(var.x), y = var.y, family = "gaussian", alpha = 1, grouped = FALSE)
plot(sel.lasso)
coef(sel.lasso, s = "lambda.1se")
coef(sel.lasso, s = "lambda.min")

# lars variable select
sel.lars <- lars::cv.lars(x = as.matrix(lasso.x), y = var.y, plot.it = TRUE, mode = "step")
idx <- which.max(sel.lars$cv - sel.lars$cv.error <= min(sel.lars$cv))
coef(lars::lars(x = as.matrix(lasso.x), y = var.y))[idx,]

#ridge variable selection
par(mfrow = c(1,1))
fit.ridge <- glmnet(x = as.matrix(var.x), y = var.y, family = "gaussian", alpha = 0)
plot(fit.ridge, xvar = "lambda", label = TRUE)
sel.ridge <- cv.glmnet(x = as.matrix(var.x), y = var.y, family = "gaussian", alpha = 0, grouped = FALSE)
plot(sel.ridge)
coef(sel.ridge, s = "lambda.1se")
coef(sel.ridge, s = "lambda.min")

pat.fwd <- regsubsets(RegSeasonWins ~ ., data = reg.var.df, nvmax = 15, method = "forward")
summary(pat.fwd)
pat.fwd$vorder

pat.fit = lm(RegSeasonWins ~ PointsAgainst + PointsDifferential, data = reg.var.df)
