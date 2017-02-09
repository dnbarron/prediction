#' @rdname prediction
#' @export
prediction.selection <- function(model, data = find_data(model, parent.frame()), type = "response", ...) {
    
    # extract predicted value at input value
    if (missing(data)) {
        pred <- data.frame(fitted = predict(model, ...), 
                           se.fitted = NA_real_)
    } else {
        data <- data
        pred <- data.frame(fitted = predict(model, newdata = data, ...), 
                           se.fitted = NA_real_)
    }
    class(pred[["fitted"]]) <- c("fit", "numeric")
    class(pred[["se.fitted"]]) <- c("se.fit", "numeric")
    
    # obs-x-(ncol(data)+2) data.frame of predictions
    structure(cbind(data, pred), 
              class = c("prediction", "data.frame"), 
              row.names = seq_len(length(pred[["fitted"]])),
              type = type)
}