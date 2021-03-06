#' @rdname prediction
#' @export
prediction.gee <- function(model, ...) {
    
    pred <- data.frame(fitted = predict(model, ...))
    pred[["se.fitted"]] <- NA_real_
    
    # obs-x-(ncol(data)+2) data frame
    structure(pred, 
              class = c("prediction", "data.frame"), 
              row.names = seq_len(nrow(pred)),
              at = NULL, 
              model.class = class(model),
              type = NA_character_)
}
