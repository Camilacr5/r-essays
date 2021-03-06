jointP <- function(pdR){
  if(class(pdR) != "RasterStack" & class(pdR) != "RasterBrick"){
    stop("input probability density map (pdR) should be RasterStack or RasterBrick")
  }
  n <- raster::nlayers(pdR)
  result <- pdR[[1]] * pdR[[2]]
  if(n > 2){
    for(i in 3:n){
      result <- result * pdR[[i]]
    }
  }
  result <- result / raster::cellStats(result,sum)
  names(result) <- "Joint_Probability"
  p = options("scipen")
  on.exit(options(scipen = p))
  options(scipen = -2)
  raster::plot(result)
  graphics::title("Joint Probability")
  return(result)
}

unionP <- function(pdR){
  if(class(pdR) != "RasterStack"){
    stop("input probability density map (pdR) should be RasterLayer")
  }
  result <- (1 - pdR[[1]])
  for(i in 2:raster::nlayers(pdR)){
    result <- raster::overlay(result, pdR[[i]], fun = function(x,y){return(x*(1-y))})
  }
  raster::plot(1-result)
  graphics::title("Union Probability")
  return(1-result)
}