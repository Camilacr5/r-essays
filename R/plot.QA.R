plot.QA = function(x, ..., outDir = NULL){

  a = list(x, ...)

  if(class(a[[1]]) != "QA"){
    stop("x must be one or more QA objects")
  }
  if(!is.null(outDir)){
    if(class(outDir) != "character"){
      stop("outDir should be a character string")
    }
    if(!dir.exists(outDir)){
      warning("outDir does not exist, creating")
      dir.create(outDir)
    }
  }
  
  n = 0
  for(i in 1:length(a)){
    if(class(a[[i]]) == "QA") n = n + 1
  }

  xx <- seq(0.00, 1, 0.01)
  
  if(n == 1){
    vali = ncol(x$val_stations)
    niter = nrow(x$val_stations)
    
    means.p = data.frame(xx, apply(x$prption_byProb, 2, mean)/vali)
    means.a = data.frame(xx, apply(x$prption_byArea, 2, mean)/vali)
    
    precision = matrix(rep(0, niter*101), ncol=niter, nrow=101)
    for (i in 1:niter){
      precision[,i] <- apply(x$precision[[i]], 1, stats::median)
    }
    
    mean.pre = NULL
    for(i in 1:101){
      mean.pre = append(mean.pre, mean(precision[i,]))
    }
    
    pre = data.frame(xx, 1 - mean.pre)

    pd <- data.frame(as.numeric(x$pd_val) / x$random_prob_density)
    
    graphics::plot(c(0,1), c(1,0), type="l", col="dark grey", lwd=2, lty=3,
         xlab="Probability quantile", 
         ylab="Proportion of area excluded", xlim=c(0,1), ylim=c(0,1))
    graphics::lines(pre[,1], pre[,2], lwd=2)

    graphics::plot(c(0,1), c(0,1), type="l", col="dark grey", lwd=2, lty=3,
         xlab="Probability quantile", 
         ylab="Proportion of validation stations included", xlim=c(0,1), ylim=c(0,1))
    graphics::lines(means.p[,1], means.p[,2], lwd=2)

    graphics::plot(c(0,1), c(0,1), type="l", col="dark grey", lwd=2, lty=3,
         xlab="Area quantile", 
         ylab="Proportion of validation stations included", xlim=c(0,1), ylim=c(0,1))
    graphics::lines(means.a[,1], means.a[,2], lwd=2)
    
    graphics::boxplot(pd, ylab = "Odds ratio (known origin:random)", outline = FALSE)
    graphics::abline(1,0, col="dark grey", lwd=2, lty=3)
    
    if(!is.null(outDir)){
      
      grDevices::png(paste0(outDir, "/QA1.png"), units = "in", width = 8, height = 3, res = 600)
      p = graphics::par(no.readonly = TRUE)
      on.exit(graphics::par(p))
      graphics::par(mfrow = c(1, 3))
      
      graphics::plot(c(0,1), c(1,0), type="l", col="dark grey", lwd=2, lty=3,
           xlab="Probability quantile", 
           ylab="Proportion of area excluded", xlim=c(0,1), ylim=c(0,1))
      graphics::lines(pre[,1], pre[,2], lwd=2)
      
      graphics::plot(c(0,1), c(0,1), type="l", col="dark grey", lwd=2, lty=3,
           xlab="Probability quantile", 
           ylab="Proportion of validation stations included", xlim=c(0,1), ylim=c(0,1))
      graphics::lines(means.p[,1], means.p[,2], lwd=2)
      
      graphics::plot(c(0,1), c(0,1), type="l", col="dark grey", lwd=2, lty=3,
           xlab="Area quantile", 
           ylab="Proportion of validation stations included", xlim=c(0,1), ylim=c(0,1))
      graphics::lines(means.a[,1], means.a[,2], lwd=2)
      
      grDevices::dev.off()
      
      grDevices::png(paste0(outDir, "/QA2.png"), units = "in", width = 6, height = 4, res = 600)
      
      graphics::boxplot(pd, ylab = "Odds ratio (known origin:random)", outline = FALSE)
      graphics::abline(1,0, col="dark grey", lwd=2, lty=3)
      
      grDevices::dev.off()
    }
    
  } else{

    nm = rep("", n)
    vali = niter = rep(0, n)
    
    for(i in 1:n){
      if(is.null(a[[i]]$name)){
        nm[i] = as.character(i)
      } else if(a[[i]]$name == "") {
        nm[i] = as.character(i)
      } else {
        nm[i] = a[[i]]$name
      } 
      vali[i] = ncol(a[[i]]$val_stations)
      niter[i] = nrow(a[[i]]$val_stations)
    }
    
    means.p = data.frame(xx, apply(a[[1]]$prption_byProb, 2, mean)/vali[1])
    means.a = data.frame(xx, apply(a[[1]]$prption_byArea, 2, mean)/vali[1])
    
    precision = matrix(rep(0, niter[1] * 101), ncol=niter[1], nrow=101)
    for (i in 1:niter[1]){
      precision[,i] = apply(a[[1]]$precision[[i]],1, stats::median)
    }
    
    mean.pre = NULL
    for(i in 1:101){
      mean.pre = append(mean.pre, mean(precision[i,]))
    }
    
    pre = data.frame(xx, 1 - mean.pre)
    
    pd = matrix(rep(NA, n * max(niter) * max(vali)), ncol=n)
    pd[1:(niter[1]*vali[1]),1] = as.numeric(a[[1]]$pd_val) / a[[1]]$random_prob_density
    
    for(i in 2:n){

      means.p = cbind(means.p, apply(a[[i]]$prption_byProb, 2, mean)/vali[i])
      means.a = cbind(means.a, apply(a[[i]]$prption_byArea, 2, mean)/vali[i])
      
      precision = matrix(rep(0, niter[i] * 101), ncol=niter[i], nrow=101)
      for (j in 1:niter[i]){
        precision[,j] = apply(a[[i]]$precision[[j]],1, stats::median)
      }
      
      mean.pre = NULL
      for(j in 1:101){
        mean.pre = append(mean.pre, mean(precision[j,]))
      }
      
      pre = cbind(pre, 1 - mean.pre)
      
      pd[1:(niter[1]*vali[1]),i] = as.numeric(a[[i]]$pd_val) / a[[i]]$random_prob_density
      
    }
    
    graphics::plot(c(0,1), c(1,0), type="l", col="dark grey", lwd=2, lty=3,
         xlab="Probability quantile", 
         ylab="Proportion of area excluded", xlim=c(0,1), ylim=c(0,1))
    for(i in 1:n){
      graphics::lines(pre[,1], pre[,i+1], lwd=2, col=i+1)
    }
    graphics::legend(0.01, 0.55, nm, lw=2, col=seq(2,n+1), bty="n")

    graphics::plot(c(0,1), c(0,1), type="l", col="dark grey", lwd=2, lty=3,
         xlab="Probability quantile", 
         ylab="Proportion of validation stations included", xlim=c(0,1), ylim=c(0,1))
    for(i in 1:n){
      graphics::lines(means.p[,1], means.p[,i+1], lwd=2, col=i+1)
    }
    graphics::legend(0.01, 1, nm, lw=2, col=seq(2,n+1), bty="n")
      
    graphics::plot(c(0,1), c(0,1), type="l", col="dark grey", lwd=2, lty=3, 
         xlab="Area quantile", 
         ylab="Proportion of validation stations included", xlim=c(0,1), ylim=c(0,1))
    for(i in 1:n){
      graphics::lines(means.a[,1], means.a[,i+1], lwd=2, col=i+1)
    }
    graphics::legend(0.6, 0.55, nm, lw=2, col=seq(2,n+1), bty="n")  
    
    graphics::boxplot(pd, col=seq(2,n+1), names = nm,
            ylab = "Odds ratio (known origin:random)", outline = FALSE)
    graphics::abline(1, 0, col="dark grey", lwd=2, lty=3)
    
    if(!is.null(outDir)){
      grDevices::png(paste0(outDir, "/QA1.png"), units = "in", width = 8, height = 3, res = 600)
      p = graphics::par(no.readonly = TRUE)
      on.exit(graphics::par(p))
      graphics::par(mfrow = c(1, 3))      
      
      graphics::plot(c(0,1), c(1,0), type="l", col="dark grey", lwd=2, lty=3,
           xlab="Probability quantile", 
           ylab="Proportion of area excluded", xlim=c(0,1), ylim=c(0,1))
      for(i in 1:n){
        graphics::lines(pre[,1], pre[,i+1], lwd=2, col=i+1)
      }
      t = graphics::par("usr")[4] * 0.6
      b = graphics::par("usr")[3]
      yp1 = mean(c(t,b))
      yp = yp1 + (n-1) / 6 * yp1 
      graphics::legend(0, yp, nm, lw=2, col=seq(2,n+1), bty="n")
      graphics::text(0.95, 0.95, "(a)")
      
      graphics::plot(c(0,1), c(0,1), type="l", col="dark grey", lwd=2, lty=3, 
           xlab="Probability quantile", 
           ylab="Proportion of validation stations included", xlim=c(0,1), ylim=c(0,1))
      for(i in 1:n){
        graphics::lines(means.p[,1], means.p[,i+1], lwd=2, col=i+1)
      }
      graphics::text(0.05, 0.95, "(b)")

      graphics::plot(c(0,1), c(0,1), type="l", col="dark grey", lwd=2, lty=3,
           xlab="Area quantile", 
           ylab="Proportion of validation stations included", xlim=c(0,1), ylim=c(0,1))
      for(i in 1:n){
        graphics::lines(means.a[,1], means.a[,i+1], lwd=2, col=i+1)
      }
      graphics::text(0.05, 0.95, "(c)")
      
      grDevices::dev.off()

      grDevices::png(paste0(outDir, "/QA2.png"), units = "in", width = 6, height = 4, res = 600)

      graphics::boxplot(pd, col=seq(2,n+1), names = nm,
              ylab = "Odds ratio (known origin:random)", outline = FALSE)
      graphics::abline(1, 0, col="dark grey", lwd=2, lty=3)
      
      grDevices::dev.off()
    }
    
    return()
  }
}
  

