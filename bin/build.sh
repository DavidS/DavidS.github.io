#!/bin/bash

set -e

cd /srv/davidlog/git/

bundle check || bundle install
git annex lock .
git commit -m "lock server" || true # if no changes
JEKYLL_ENV=production bundle exec jekyll build --strict --verbose --destination /srv/davidlog/site

echo "Build Successful at" $(date --iso=s)
