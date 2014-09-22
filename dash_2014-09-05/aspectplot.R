aspectplot <- function(xlim,ylim,asp) {
  plot.new()
  #plot.window(xlim=xlim,ylim=ylim,xaxs="i",yaxs="i")
  r <- asp*abs(diff(ylim)/diff(xlim))
  if(r>1) {
    p <- par(fig=c(0.5-1/(2*r),0.5+1/(2*r),0,1))
  } else {
    p <- par(fig=c(0,1,0.5-1/(2*r),0.5+1/(2*r)))
  }
  plot.window(xlim=xlim,ylim=ylim,xaxs="i",yaxs="i")
  return(p)
}
