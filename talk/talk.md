
<style type="text/css">
html {
        overflow: auto;
}
</style>


# About me

* Simon Hickinbotham: Archaeology / Comp Sci staff memeber
* Ecologist turned programmer
* Computer vision/ Evo alg
* bioarch - R developer - why I learned how to do this
* Comments on this methodology are welcome!

* I run R from the command line in Linux 



#  What we'll do today

* install devtools
* create github account & repo
* lay out an R package within a local git repo
* build the package
* versioning
* add help
* add C code library
* add datasets
* ...updating github as we go....


*I suggest you work in pairs so that you can share packages with each other*

---
# Devtools

* A really handy package for developing packages
* Automates a lot of the process for you
* Available from CRAN:

```
> install.packages("devtools")
```

# Github

* Free hosting of (public) projects
* email needed
* Other private (UoY) repositories may be available
* make a github account now if you want to follow along...

# A github r-package repository

* This means we always have a backup
* we can share our package with others
* Easiest way is this:
    * Make an empty repository
    * Clone it to a *local* repo
    * Save files / folders there
    * push to github. 

# Make an empty repository

*See github; Initialise with the following:*

* `README.md`
* `LICENSE.md`
* `.gitignore`

# Make  a local clone

* A copy of the git repo on your hard drive
* Do you have git? (probably)
* Pick a suitable directory - it can be anywhere - then:

*From the command line! (not from R)*

```
$ git clone https://github.com/github_username/repo_name
```

* e.g.:

```
$ git clone https://github.com/franticspider/rpkgtalk
```


* Now we can work on the package locally, and upload in stages. 

--------
















#Structure of a github R package

*My preferences are these:*

* Create the package in a *sub-*directory of the repo
* Gives a distinction between *developers* and *users*
    * **developers** clone the repo via git
    * **users** install the packge via devtools (see later)
* Allows readme, tests, install scripts etc. to be separate
* devtools allows for this when installing a package. 


#Make a basic R package

* https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/
* From R:

```
> require(devtools)
> setwd("~/git/rpkgtalk")
> create("mypkg1")
```

* have a look at the folder structure on your filesystem...


#Add a function

* similar to creating a standard R function file
* store in the `R` sub-directory
* let's do that now...


# Create an R function

* Let's make a toy function (copying Hilary Parker)

```
cat_function <- function(love=TRUE){
    if(love==TRUE){
        print("I love cats!")
    }
    else {
        print("I am not a cool person.")
    }
}
```



#Add help

* **THIS IS NOT DIFFICULT**
* Most of the help will be constructed for you "for free"
* Just put comments above the function in question
* Special keywords tell devtools/roxygen how to make the helpfile:
* `#' @param`     *a parameter of the function* 
* `#' @keywords` *will find the help for the function when you do* `> ??keyword` call
* `#' @export`  *tells devtools to make this function available*
* `#' @examples` *gives example function calls* 

```
#' A Cat Function
#'
#' This function allows you to express your love of cats.
#' @param love Do you love cats? Defaults to TRUE.
#' @keywords cats
#' @export
#' @examples
#' cat_function()
```

#Help note:

* **OCCASIONALLY** the help can get corrupted - giving error like 

```
Error in fetch(key) : 
  lazy-load database '/home/sjh/R/x86_64-pc-linux-gnu-library/3.2/mypkg1/help/mypkg1.rdb' is corrupt
In addition: Warning message:
In fetch(key) : internal error -3 in R_decompress1
```

* restart R to fix

#Make a compile script

* an advantage of building your package in a sub-directory is that you can 
store the compile script in the repository too: 
* Create a file called `install.R` and put it in the top-level git directory
* Add these contents: 

```
#These are the libraries you need to build a package:
require("devtools")
require(roxygen2)

#Build the help files:
setwd("mypkg1")
document()

#Compile
setwd("..")
install("mypkg1")

#reload
require("mypkg1")
```

* you can just run this from R (make sure you setwd() correctly)

---




#"Push" to github


* it is important to 'stash' your work regularly
* Do this *From outside R*
* Do this from the root directory of your local repo
* There are three git commands you need to remember

```
$ git add .
$ git commit
$ git push
```

* Huge simplification here!



#Creating a release tag

* Important to mark milestones in development with *Releases* (or tags)
* This is easiest done within github...
* you can then use devtools to install a specific release
* do a "pull" after creating the tag:

```
$ git pull
```



# Accessing releases

* This is how you share your package with other users
* Useful for testing, or while a newer version is being developed
* If necessary, *remove your current version*

```
> remove.packages("mypkg1")
```

* Now use devtools' `install_github` command:

```
> require(devtools)
> install_github("franticspider/rpkgtalk", subdir = "mypkg1", ref = "0.2.0")
```

* If you just want the latest version:

```
> require(devtools)
> install_github("franticspider/rpkgtalk", subdir = "mypkg1")
```



---










#Add C code (or C++, Java, Fortran etc)

http://r-pkgs.had.co.nz/src.html

* A whole can of worms!
* Useful for legacy code, and can be faster
* basic principles are simple: 
    * write C code in the `src\` sub-directory
    * Only pass in pointers to R structures
    * Write a wrapper function in R
    * Add compile instructions to the install script

#C functions


* the function arguments must all be pointers
* all allocated memory must be freed
* printfs/writing to file is not good - can't be controlled in R
* (Looking at ways to build a test rig outside the package directory)

#C function example

```
#include <stdlib.h>
#include <stdio.h>


void halve_cats(int *ncats, int *catarray, double * halfcats, int *errflag){

	int i;

#ifdef DEBUG_R	
	printf("In C, we are going to halve %d cats\n",ncats[0]);
#endif	
	for(i=0;i<ncats[0];i++){
		halfcats[i] = (float) catarray[i]/2.2;
#ifdef DEBUG_R	
		printf("ca = %d, hc = %0.3f\n",catarray[i],halfcats[i]);
#endif
	}
	errflag[0]=120;
}
```

#Calling the C from R

* write a *wrapper function*
* handles the "raw" arguments
* calls the function
* devtools `@useDynLib` flag indicates the C library
* returns an R list with the  arguments to the c function

#Calling the C code from R - example

```
#' Wrapper for the  'halve_cats' C function
#' @param ncats number of cats to halve
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
```

# Building

* No different! - just run `install.R`
* a NAMESPACE file will be created that states the DynLib name



# Second commit to github


```
$ git add .
$ git commit
$ git push
```

#Source data

http://r-pkgs.had.co.nz/data.html

* It is useful to provide data with your package
* Three types: *Exported*, *Internal* and **Raw**
* Raw data goes in `inst/extdata`
* accessed like this:

```
> filename <- system.file("extdata", "2010.csv", package = "testdat")
>data <- read.table(filename,sep=`,`)
```


# Third commit to github


```
$ git add .
$ git commit
$ git push
```

# Summary

* it is EASY to make a package
* I suggest you make this your standard practise
* Observations
    * CRAN is gold standard - but this can be overkill
    * RStudio has a lot of these tricks built in
    * Special steps may need to be taken to compile for windows
    * Many, many other approaches to this 
* Feedback welcome - please clone!



