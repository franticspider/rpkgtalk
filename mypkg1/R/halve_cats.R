
#' Cat Sharing
#'
#' Wrapper for the  'halve_cats' C function
#' @param ncats number of cats to share
#' @keywords cats
#' @useDynLib mypkg1
#' @export
#' @examples
#' halve_cats(5)
halve_cats <- function(ncats){
	
	ca <- as.integer(runif(ncats,1,20))
	hc <- vector(length=ncats)
	
    message(sprintf("We are going to halve %d cats",ncats))

	errflag<-0
	result<-.C("halve_cats",as.integer(ncats),as.integer(ca),as.double(hc),as.integer(errflag))
	
	return (result)

}
