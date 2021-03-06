## Logistic Ridge Big function (calls C)

#' @export
#' @importFrom utils read.table
logisticRidgeGenotypes <- function(genotypesfilename,
                                   phenotypesfilename,
                                   lambda = -1,
                                   thinfilename = NULL,
                                   betafilename = NULL,
                                   approxfilename = NULL,
                                   permfilename = NULL,
                                   intercept = TRUE,
                                   verbose = FALSE)
  {
    if(!TRUE)
      stop("GSL >=1.14 is not installed, you cannot use this function")
    ## Tilde expansion of phenotypesfilename
    ## (Because the C code cannot cope with the tilde)
    phenotypesfilename <- path.expand(phenotypesfilename)
    ## Check phenotypes file for reading
    ## mode = 4 tests for read permission
    if(file.access(names = phenotypesfilename, mode = 4))
      stop(gettextf("Cannot open file %s for reading", phenotypesfilename))
    ## Tilde expansion of genotypesfilename
    ## (Because the C code cannot cope with the tilde)
    genotypesfilename <- path.expand(genotypesfilename)
    ## Check genotypes file for reading
    ## mode = 4 tests for read permission
    if(file.access(names = genotypesfilename, mode = 4))
      stop(gettextf("Cannot open file %s for reading", genotypesfilename))
    ## Check beta file name is set
    ## If it is not set it to beta.dat (print a warning)
    if(is.null(betafilename))
      {
        betaFileExists <- FALSE
        betafilename <- tempfile(pattern = "beta", fileext = ".dat")
      } else {
        betaFileExists <- TRUE
        ## Else do the tilde expansion on betafilename
        ## (Because the C code cannot cope with the tilde)
        betafilename <- path.expand(betafilename)
      }
    ## Tilde expansion of approxfilename (if supplied)
    ## (Because the C code cannot cope with the tilde)
    if(!is.null(approxfilename))
      {
        approxfilename <- path.expand(approxfilename)
      } else {
        ## Cannot pass NULL pointer to .C
        ## Therefore make it into a string
        approxfilename <- "NULL"
      }
    ## Tilde expansion of permfilename (if supplied)
    ## (Because the C code cannot cope with the tilde)
    if(!is.null(permfilename))
      {
        permfilename <- path.expand(permfilename)
      } else {
        ## Cannot pass NULL pointer to .C
        ## Therefore make it into a string
        permfilename <- "NULL"
      }
    ## Tilde expansion of thinfilename (if supplied)
    ## (Because the C code cannot cope with the tilde)
    if(!is.null(thinfilename))
      {
        ## Check if lambda has been supplied
        ## thinfilename is not needed if lambda has been supplied
        if(lambda == -1)
          {
            thinfilename <- path.expand(thinfilename)
          } else {
            stop(gettext("Cannot supply lambda and thinfilename. Please supply one or the other."))
          }
        ## Check thinfile for read permission
        ## mode = 4 tests for read permission
        if(file.access(names = thinfilename, mode = 4))
          stop(gettextf("Cannot open file %s for reading", permfilename))
      } else {
        ## Cannot pass NULL pointer to .C
        ## Therefore make it into a string
        thinfilename <- "NULL"
      }
    res <- .C(regression_wrapper_function,
              genofilename = as.character(genotypesfilename),
              phenofilename = as.character(phenotypesfilename),
              betafilename = as.character(betafilename),
              approxfilename = as.character(approxfilename),
              permfilename = as.character(permfilename),
              thinfilename = as.character(thinfilename),
              intercept = as.integer(intercept),
              lambda = as.double(lambda),
              model = as.character("logistic"),
              predict = as.integer(0),
              verbose = as.integer(verbose))
    beta <- read.table(betafilename, row.names = 1, colClasses = c("character", "numeric"), col.names = c("", "B"))
    if(!betaFileExists)
      unlink(betafilename)
    return(beta)
  }
