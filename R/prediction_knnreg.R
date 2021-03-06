#' @rdname prediction
#' @export
prediction.knnreg <- function(model, data, at = NULL, ...) {
    
    # extract predicted values
    pred <- data.frame(fitted = predict(model, newdata = data, ...))
    pred[["se.fitted"]] <- NA_real_
    
    # obs-x-(ncol(data)+2) data frame
    structure(pred, 
              class = c("prediction", "data.frame"), 
              row.names = seq_len(nrow(pred)),
              at = if (is.null(at)) at else names(at), 
              model.class = class(model),
              type = NA_character_)
}
