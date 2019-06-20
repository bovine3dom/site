#!/bin/bash

hugo

cd public

git add .

git commit -m "Build $(date)"

git push
