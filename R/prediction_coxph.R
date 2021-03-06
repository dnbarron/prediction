#' @rdname prediction
#' @export
prediction.coxph <- 
function(model, 
         data = find_data(model, parent.frame()), 
         at = NULL, 
         type = c("risk", "expected", "lp"), 
         ...) {
    
    type <- match.arg(type)
    
    # extract predicted values
    data <- data
    if (missing(data) || is.null(data)) {
        pred <- predict(model, type = type, se.fit = TRUE, ...)
        pred <- data.frame(fitted = pred[["fit"]], se.fitted = pred[["se.fit"]])
    } else {
        # setup data
        out <- build_datalist(data.frame(data), at = at)
        for (i in seq_along(out)) {
            tmp <- predict(model, 
                           newdata = out[[i]], 
                           type = type, 
                           se.fit = TRUE,
                           ...)
            out[[i]] <- cbind(out[[i]], fitted = tmp[["fit"]], se.fitted = tmp[["se.fit"]])
            rm(tmp)
        }
        pred <- do.call("rbind.data.frame", out)
    }
    
    # obs-x-(ncol(data)+2) data frame
    structure(pred, 
              class = c("prediction", "data.frame"), 
              row.names = seq_len(nrow(pred)),
              at = if (is.null(at)) at else names(at), 
              model.class = class(model),
              type = type)
}
