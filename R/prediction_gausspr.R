#' @rdname prediction
#' @export
prediction.gausspr <- 
function(model, 
         data, 
         at = NULL, 
         type = NULL, 
         category, 
         ...) {
    
    if (!is.null(type)) {
        warning(sprintf("'type' is ignored for models of class '%s'", class(model)))
    }
    
    # extract predicted values
    data <- data
    if (missing(data) || is.null(data)) {
        pred <- data.frame(fitted.class = predict(model, type = "response", ...))
        probs <- as.data.frame(predict(model, type = "probabilities", ...))
        names(probs) <- paste0("Pr(", names(probs), ")")
        pred <- cbind(pred, probs)
    } else {
        out <- build_datalist(data, at = at)
        for (i in seq_along(out)) {
            tmp <- predict(model, newdata = out[[i]], type = "response", ...)
            tmp_probs <- as.data.frame(predict(model, newdata = data, type = "probabilities", ...))
            names(tmp_probs) <- paste0("Pr(", names(tmp_probs), ")")
            out[[i]] <- cbind.data.frame(out[[i]], fitted.class = tmp, tmp_probs)
            rm(tmp, tmp_probs)
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
    
    # obs-x-(ncol(data)+2+nlevels(outcome)) data.frame of predictions
    structure(pred,
              class = c("prediction", "data.frame"), 
              row.names = seq_len(nrow(pred)),
              at = if (is.null(at)) at else names(at), 
              model.class = class(model),
              type = NA_character_,
              category = category)
}
