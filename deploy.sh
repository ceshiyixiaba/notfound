#!/bin/bash

hugo
git checkout pages
rm -rf docs
mv public docs
git add docs/
git commit -m "deploy $(date)"

git checout main
