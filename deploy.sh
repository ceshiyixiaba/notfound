#!/bin/bash

hugo -d docs
git checkout pages
git add docs/
git commit -m "deploy $(date)"
