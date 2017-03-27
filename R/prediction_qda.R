# @rdname prediction
# @export
prediction.qda <- function(model, data = find_data(model, parent.frame()), ...) {
    
    # extract predicted values
    if (missing(data)) {
        pred <- predict(model, ...)
    } else {
        pred <- predict(model, newdata = data, ...)
    }
    colnames(pred[["posterior"]]) <- paste0("Pr(", colnames(pred[["posterior"]]), ")")
    
    # obs-x-(ncol(data)+...) data.frame of predictions
    data <- data
    structure(if (!length(data)) {
                data.frame(pred)
              } else {
                cbind(data, 
                      class = pred[["class"]], 
                      pred[["posterior"]], 
                      fitted = rep(NA_real_, length(pred[["class"]])),
                      se.fitted = rep(NA_real_, length(pred[["class"]])))
              }, 
              class = c("prediction", "data.frame"), 
              row.names = seq_len(length(pred[["fitted"]])),
              model.class = class(model),
              type = NA_character_)
}