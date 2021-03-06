setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source('../../findNSourceUtils.R')

test.DRF.groupsplit <- function(conn) {
  # Training set has only 45 categories cat1 through cat45
  Log.info("Importing 50_cattest_train.csv data...\n")
  train.hex <- h2o.uploadFile(conn, locate("smalldata/histogram_test/50_cattest_train.csv"), key = "train.hex")
  train.hex$y <- as.factor(train.hex$y)
  Log.info("Summary of 50_cattest_train.csv from H2O:\n")
  print(summary(train.hex))
  
  # Train H2O DRF Model:
  Log.info(paste("H2O DRF with parameters:\nclassification = TRUE, ntree = 50, depth = 20, nbins = 500\n", sep = ""))
  drfmodel.h2o <- h2o.randomForest(x = c("x1", "x2"), y = "y", data = train.hex, classification = TRUE, ntree = 50, depth = 20, nbins = 500, type = "BigData")
  print(drfmodel.h2o) 
 
  # Test dataset has all 50 categories cat1 through cat50
  Log.info("Importing 50_cattest_test.csv data...\n")
  test.hex <- h2o.uploadFile(conn, locate("smalldata/histogram_test/50_cattest_test.csv"), key="test.hex")
  Log.info("Summary of 50_cattest_test.csv from H2O:\n")
  print(summary(test.hex))
  
  # Predict on test dataset with DRF model:
  Log.info("Performing predictions on test dataset...\n")
  drfmodel.pred <- h2o.predict(drfmodel.h2o, test.hex)
  # h2o.preds <- head(drfmodel.pred, nrow(drfmodel.pred))[,1]
  print(head(drfmodel.pred))
  
  # Get the confusion matrix and AUC
  Log.info("Confusion matrix of predictions (max accuracy):\n")
  # test.cm <- h2o.confusionMatrix(test.hex$y, drfmodel.pred[,1])
  # print(test.cm)
  test.perf <- h2o.performance(test.hex$y, drfmodel.pred[,1])
  print(test.perf)
  testEnd()
}

doTest("DRF Test: Classification with 50 categorical level predictor", test.DRF.groupsplit)
