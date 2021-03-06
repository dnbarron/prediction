# @rdname prediction
# @export
prediction.qda <- 
function(model, 
         data = find_data(model, parent.frame()), 
         at = NULL, 
         category, 
         ...) {
    
    # extract predicted values
    data <- data
    if (missing(data) || is.null(data)) {
        pred <- predict(model, ...)
        colnames(pred[["posterior"]]) <- paste0("Pr(", colnames(pred[["posterior"]]), ")")
        pred <- data.frame(fitted.class = pred[["class"]], 
                           pred[["posterior"]], 
                           check.names = FALSE)
    } else {
        out <- build_datalist(data, at = at)
        for (i in seq_along(out)) {
            tmp <- predict(model, newdata = out[[i]], ...)
            colnames(tmp[["posterior"]]) <- paste0("Pr(", colnames(tmp[["posterior"]]), ")")
            out[[i]] <- cbind.data.frame(out[[i]], fitted.class = tmp[["class"]], tmp[["posterior"]])
            rm(tmp)
        }
        pred <- do.call("rbind", out)
    }

    # handle category argument
    if (missing(category)) {
        w <- grep("^Pr\\(", names(pred))[1L]
        category <- names(pred)[w]
        pred[["fitted"]] <- pred[[w]]
    } else {
        w <- which(names(pred) == paste0("Pr(", category, ")"))
        if (!length(w)) {
            stop(sprintf("category %s not found", category))
        }
        pred[["fitted"]] <- pred[[ w[1L] ]]
    }
    pred[["se.fitted"]] <- NA_real_
    
    # obs-x-(ncol(data)+k_classes+3) data frame
    structure(pred, 
              class = c("prediction", "data.frame"), 
              row.names = seq_len(nrow(pred)),
              at = if (is.null(at)) at else names(at), 
              model.class = class(model),
              type = NA_character_,
              category = category)
}
