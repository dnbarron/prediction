# @rdname prediction
# @export
prediction.vgam <- 
function(model, 
         data = find_data(model, parent.frame()), 
         at = NULL, 
         type = c("response", "link"), 
         category,
         ...) {
    
    type <- match.arg(type)
    
    # extract predicted values
    data <- data
    if (missing(data) || is.null(data)) {
        pred <- as.data.frame(predict(model, type = type, se.fit = FALSE, ...))
    } else {
        # setup data
        out <- build_datalist(data, at = at)
        for (i in seq_along(out)) {
            tmp <- predict(model, 
                           newdata = out[[i]], 
                           type = type, 
                           se.fit = FALSE,
                           ...)
            if (!is.null(dim(tmp))) {
                tmp <- as.matrix(tmp, ncol = 1)
            }
            out[[i]] <- cbind(out[[i]], fitted = data.frame(tmp))
            rm(tmp)
        }
        pred <- do.call("rbind", out)
    }
    pred[["se.fitted"]] <- NA_real_
    
    # handle category argument
    if (missing(category)) {
        category <- names(pred)[!names(pred) %in% names(data)][1L]
        pred[["fitted"]] <- pred[[category]]
    } else {
        w <- grep(category, names(pred))
        if (!length(w)) {
            stop(sprintf("category %s not found", category))
        }
        pred[["fitted"]] <- pred[[ w[1L] ]]
    }
    
    # obs-x-(ncol(data)+2) data frame
    structure(pred, 
              class = c("prediction", "data.frame"), 
              row.names = seq_len(nrow(pred)),
              at = if (is.null(at)) at else names(at), 
              model.class = class(model),
              type = type,
              category = category)
}
