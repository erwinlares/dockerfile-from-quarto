# Load the jsonlite package to read JSON files

library(glue)
library(readr)
library(tidyverse)

submit_to_htc <- function(notebook,
                          data = "data.csv",
                          hctc_id = "lares",
                          submit_server = "ap2001",
                          gitlab_repo = "analysis",
                          gitlab_registry = "registry.doit.wisc.edu",
                          gitlab_id = "erwin.lares"){

# 1/10
print("Step 1 of 10 ... locating .lock file ...") 
    
#check that the file exist/renv.lock exist
    if(!file.exists(glue("{getwd()}/renv.lock"))){
        print("Error: No `renv.lock` file found in current location")
        return()
    }

# 1/n lock file located 

    print("Step 1 of 10 ... locating .lock file ... done")

# 2/10 extract the code from the notebook
    
print("Step 2 of 10 ... creating .R script file ... ")
    if(!file.exists(notebook)){
        print("Error: No notebook found in the specified location")
        return()
    }
    
    if(!str_extract(notebook, "(\\w+)$") %in% c("qmd", "rmd","r", "R")){
        print("Error: Not a valid file format. Only .qmd or .rmd accepted")
        return()
    }
    
    if(str_extract(notebook, "(\\w+)$") %in% c("r", "R")){
        print("Already an .R script")
    }
    
    
    if(str_extract(notebook, "(\\w+)$") %in% c("qmd","rmd")){
        knitr::purl(notebook, documentation = 1)
        print("Step 2 of 10 ... creating .R script file ... done")
    }
        

# 3/10 write the Dockerfile
    
    print("Step 3 of 10 ... creating Docker file ... ")
    r_version <- R.Version()
    FROM_line <- glue::glue(
        "FROM rocker/r-ver:{glue::glue('{r_version$major}.{r_version$minor}')}")
    WORKDIR_line <- "WORKDIR /home"

    COPY_renv_lock <- glue::glue(
        "COPY renv.lock /home/renv.lock")

    COPY_renv_library <- glue::glue(
        "COPY renv/library /home/app/renv/library")

    readr::write_lines(FROM_line, file = "Dockerfile")
    readr::write_lines(WORKDIR_line, file = "Dockerfile",
                       append = TRUE)
    readr::write_lines(COPY_renv_lock, file = "Dockerfile",
                       append = TRUE)
    readr::write_lines(COPY_renv_library, file = "Dockerfile",
                       append = TRUE)
#this line is potentially problematic. How do I store a .txt inside a package?
    readr::write_lines(read_lines("install_and_restore_packages.sh"), 
                       file = "Dockerfile",
                       append = TRUE)
    
    print("Step 3 of 10 ... creating Dockerfile ... done")

# 4/10 Build the image 
    print("Step 4 of 10 ... creating container image ... ")
# commenting this line out so I don't have tons of images while debugging
    #    system(glue("podman build -t {gitlab_registry}/{gitlab_id}/{gitlab_repo} ."))

    print("Step 4 of 10 ... creating container image ... done")

# 5/10 Authenticate with the gitlab registry
    print("Step 5 of 10 ... logging in to GitLab registry ... ")
    #system(glue("podman login {gitlab_registry}"))
    print("Step 5 of 10 ... logging in  to GitLab registry ... done")

# 6/10 Push container image to gitlab registry

    print("Step 6 of 10 ... pushing container image to GitLab registry ... ")
    #system(glue("podman push {gitlab_registry}/{gitlab_id}/{gitlab_repo}"))
    print("Step 6 of 10 ... pushing container image to GitLab registry ... done")

# 7/10 Create submit file 
    print("Step 7 of 10 ... creating submit file ... ")
    #creating the submit file line-by-line
    print("Step 7 of 10 ... creating submit file ... done")
# 8/10 Create executable file 
    print("Step 8 of 10 ... creating executable file ... ")
    #creating .sh file line-by-line 
    print("Step 8 of 10 ... creating executable file ... done")
    
# 9/10 Copy over .R, data, .sub, and .sh files to CHTC 
# does too! work 
    
    
    print("Step 9 of 10 ... uploading .R, data, .sub, and .sh to CHTC ... ")
    system(glue("scp analysis.R data.csv analysis.sub analysis.sh lares@ap2001.chtc.wisc.edu:/home/lares"))
    
    print("Step 9 of 10 ... uploading .R, data, .sub, and .sh to CHTC ... done")

#10/10  give concise directions to what to do next 
    
    print("Step 10/10 ... ")

}

submit_to_htc("analysis.qmd")
submit_to_hpc("")

















if(str_extract(notebook, "(\\w+)$") %in% c("qmd","rmd")){
    knitr::purl(notebook, documentation = 1)
    print("Step 2 of 10 ... creating .R script file ")
}




