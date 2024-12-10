# Load the jsonlite package to read JSON files


library(jsonlite)
library(glue)
library(readr)
library(progress)



submit_to_htc <- function(notebook,
                          data = "data.csv",
                          hctc_id = "lares",
                          submit_server = "ap2001",
                          gitlab_repo = "analysis",
                          gitlab_registry = "registry.doit.wisc.edu",
                          gitlab_id = "erwin.lares"
){


#check that the file exist/renv.lock exist
    if(!file.exists(glue("{getwd()}/renv.lock"))){
        print("No `renv.lock` file found in current location")
        return()
    }

# 1/n lock file located 

print("Step 1 of 8 ... locate .lock file ... done")

# 2/n extract the code from the notebook
    knitr::purl(notebook, documentation = 1)
    print("Step 2 of 8 create .R file ... done")

# 3/10 write the Dockerfile
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
    readr::write_lines(read_lines("install_and_restore_packages.txt"), 
                       file = "Dockerfile",
                       append = TRUE)
    
    print("Step 2 of 8 ... create Dockerfile ... done")

# Build the image 
# commenting this line out so I don't have tons of images while debugging
    #    system(glue("podman build -t {gitlab_registry}/{gitlab_id}/{gitlab_repo} ."))

    print("Step 3 of 8 ... create container image ... done")

# Authenticate with the gitlab registry
    
    #system(glue("podman login {gitlab_registry}"))
    print("Step 4 of 8 ... login to GitLab registry ... done")

# Push container image to gitlab registry

    #system(glue("podman push {gitlab_registry}/{gitlab_id}/{gitlab_repo}"))
    print("Step 5 of 8 ... push container image to GitLab registry ... done")

# 6/10Create submit file 
    print("Step 6 of 8 ... create submit file ... done")

# 7/10Create executable file 
    print("Step 7 of 8 ... create executable file ... done")

    
# Copy over .R, data, .sub, and .sh files to CHTC 
# does too! work 
    
# 8/10 COpy files over to chtc
    
    system(glue("scp analysis.R data.csv analysis.sub analysis.sh lares@ap2001.chtc.wisc.edu:/home/lares"))
    
    print("Step 8 of 8 ... copy .R, data, .sub, and .sh to CHTC ... done")


}
# 
