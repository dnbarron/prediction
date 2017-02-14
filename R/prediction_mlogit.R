prediction.mlogit <- function(model, data = find_data(model, parent.frame()), ...) {
    
    # extract predicted values
    data <- data
    if (missing(data)) {
        stop("'data' is required for objects of class 'mlogit'")
    }
    pred <- data.frame(predict(model, newdata = data, ...))
    names(pred) <- paste0("Pr(", seq_len(ncol(pred)), ")")
    pred[] <- lapply(pred, `class<-`, c("fit", class(pred[["fit"]])))
    pred[["se.fitted"]] <- NA_real_
    class(pred[["se.fitted"]]) <- c("se.fit", "numeric")
    
    # obs-x-(ncol(data)+2+nlevels(outcome)) data.frame of predictions
    structure(cbind(data, pred),
              class = c("prediction", "data.frame"), 
              row.names = seq_len(length(pred[["fitted"]])),
              model.class = class(model),
              type = NULL)
}