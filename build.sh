#!/bin/bash

set -e

# remove previous packaged folder
rm -rf docs

# package notepadium theme
hugo -t notepadium

# rename folder
mv public docs && cd docs

# add CNAME
echo "articles.pyecharts.org" >> CNAME

# add changes to git.
git init
git add -A

# commit changes.
msg="building site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# push to remote
git push -f https://github.com/pyecharts/articles master

# go back
cd ..
