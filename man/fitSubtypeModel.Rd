% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fitModels.R
\name{fitSubtypeModel}
\alias{fitSubtypeModel}
\title{fitSubtypeModel
Train a single subtype model using cross validation}
\usage{
fitSubtypeModel(Xs, Ys, breakVec = c(0, 0.25, 0.5, 0.75, 1),
  params = list(max_depth = 2, eta = 0.5, nrounds = 100, nthread = 5,
  nfold = 5), tail = 0.05)
}
\arguments{
\item{Xs}{Gene expression matrix.}

\item{Ys}{Phenotype vector, multiclass}

\item{params}{Parameters for xgboost}
}
\value{
A list of xgboost classifiers, one for each subtype.
}
\description{
fitSubtypeModel
Train a single subtype model using cross validation
}
\examples{
mods <- fitSubtypeModel(Xs, Ys, params)

}
