#!/bin/bash
echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
# Build the project.
hugo 
# Go To Public folder
# Update static pages
cd public
git add .
msg="rebuilding on `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"
# Push source and build repos.
git push origin master
# Come Back
cd ..
# Update souce code
git add .
git commit -m "$msg"
git push origin master
echo -e "\033[0;32mSuccessfully updated!!\033[0m"