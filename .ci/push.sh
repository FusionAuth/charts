#!/bin/sh

setup_git() {
  git config --global user.email "ci@fusionauth.io"
  git config --global user.name "Travis CI"
}

commit_website_files() {
  git checkout -b master
  git add repo/index.yaml
  git commit --message "Update index [skip ci]"
}

upload_files() {
  git remote add remote https://${GITHUB_TOKEN}@github.com/FusionAuth/charts.git >/dev/null 2>&1
  git push --quiet --set-upstream remote master
}

setup_git
commit_website_files
upload_files
