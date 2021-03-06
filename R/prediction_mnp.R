#' @rdname prediction
#' @export
prediction.mnp <- 
function(model, 
         data = find_data(model, parent.frame()), 
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
        probs <- as.data.frame(predict(model, type = "prob", ...)[["p"]])
        names(probs) <- paste0("Pr(", names(probs), ")")
        tmp <- predict(model, type = "choice", ...)[["y"]]
        d <- dim(tmp)
        if (length(d) == 3) {
            stop("'prediction.mnp' only works when 'n.draws = 1'")
        }
        probs[["fitted.class"]] <- lapply(seq_len(d[1L]), function(i) tmp[i,])
        pred <- probs
        rm(probs, tmp)
    } else {
        out <- build_datalist(data, at = at)
        for (i in seq_along(out)) {
            tmp_probs <- as.data.frame(predict(model, newdata = data, type = "prob", ...)[["p"]])
            names(tmp_probs) <- paste0("Pr(", names(tmp_probs), ")")
            tmp <- predict(model, newdata = out[[i]], type = "choice", ...)[["y"]]
            d <- dim(tmp)
            if (length(d) == 3) {
                stop("'prediction.mnp' only works when 'n.draws = 1'")
            }
            tmp_probs[["fitted.class"]] <- lapply(seq_len(d[1L]), function(i) tmp[i,])
            out[[i]] <- cbind(out[[i]], tmp_probs)
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
    
    # obs-x-(ncol(data)+2+nlevels(outcome)) data frame
    structure(pred,
              class = c("prediction", "data.frame"), 
              row.names = seq_len(nrow(pred)),
              at = if (is.null(at)) at else names(at), 
              model.class = class(model),
              type = NA_character_,
              category = category)
}
