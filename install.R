#These are the libraries you need to build a package:
require("devtools")
require(roxygen2)

#Build the help files:
setwd("mypkg1")
document()

#Compile
setwd("..")
install("mypkg1")
