

#' fitOneModel
#' Train a single subtype model.
#' @export
#' @param Xbin Gene expression matrix.
#' @param Ybin Phenotype vector.
#' @param params Params for xgboost.
#' @return A single xgboost classifier.
#' @examples
#' modC1 <- fitOneModel(ebppGeneExpr, phenotype)
#'
fitOneModel <- function(Xbin, Ybin, params=list(max_depth = 2, eta = 0.5, nrounds = 33, nthread = 5)){

  bst <- xgboost(data = Xbin,
                 label = Ybin,
                 max_depth=params$max_depth,
                 eta=params$eta,
                 nrounds=params$nrounds,
                 nthread=params$nthread,
                 objective="binary:logistic")
  return(list(bst=bst, breakVec=breakVec))
}


#' cvfitOneModel
#' Train a single subtype model using cross validation
#' @export
#' @param Xbin Binned and filtered gene expression matrix.
#' @param Ybin Binned phenotype vector.
#' @return A single xgboost classifier.
#' @examples
#' res0 <- trainDataProc(Xmat, Y, cluster='1')
#' dat  <- res0$dat
#' modC1 <- fitOneModel(dat$Xbin, dat$Ybin)
#'
cvFitOneModel <- function(Xbin, Ybin,
                          params=list(max_depth = 2, eta = 0.5, nrounds = 100, nthread = 5, nfold=5),
                          breakVec=c(0, 0.25, 0.5, 0.75, 1.0),
                          genes){
  dtrain <- xgb.DMatrix(Xbin, label = Ybin)
  cvRes <-xgb.cv(data = dtrain,
                 nrounds=params$nrounds,
                 nthread=params$nthread,
                 nfold=params$nfold,
                 max_depth=params$max_depth,
                 eta=params$eta,
                 early_stopping_rounds=2,
                 metrics = list("error", "rmse","auc"),
                 objective = "binary:logistic")

    bst <- xgboost(data = Xbin,
                 label = Ybin,
                 max_depth=params$max_depth,
                 eta=params$eta,
                 nrounds = cvRes$best_iteration,
                 nthread=params$nthread,
                 objective = "binary:logistic")

  return(list(bst=bst, breakVec=breakVec, genes=genes))
}


#' fitSubtypeModel
#' Train a single subtype model using cross validation
#' @export
#' @param Xs Gene expression matrix.
#' @param Ys Phenotype vector, multiclass
#' @param params Parameters for xgboost
#' @return A list of xgboost classifiers, one for each subtype.
#' @examples
#' mods <- fitSubtypeModel(Xs, Ys, params)
#'
fitSubtypeModel <- function(Xs, Ys, breakVec=c(0, 0.25, 0.5, 0.75, 1.0),
  params=list(max_depth = 2, eta = 0.5, nrounds = 100, nthread = 5, nfold=5),
  tail=0.05) {

  modelList <- list()
  allLabels <- unique(Ys)

  for (yi in allLabels) {
    print(paste0('Subtype: ',yi, '  processing data...'))
    res0 <- trainDataProc(Xs, Ys, cluster=yi, tail)
    dat  <- res0$dat
    csfr <- cvFitOneModel(dat$Xbin, dat$Ybin, params, breakVec, dat$Genes)
    modelList[[yi]] <- csfr
  }
  names(modelList) <- allLabels
  return(modelList)
}


