#!/bin/bash

#  Required env vars:
#   1) BASE_SRC_DIR = checkout directory of the app repository
#   2) BASE_PUB_DIR = checkout directory of the helm charts repository
#   3) SRC_SUBDIR = sub-path to the un-packaged helm chart in the base source dir
#   4) PUB_SUBDIR = sub-path to the published helm package in the base publish dir

srcPath="${BASE_SRC_DIR}/${SRC_SUBDIR}"
pubPath="${BASE_PUB_DIR}/${PUB_SUBDIR}"
chartUrl="https://rik-ee.github.io/${PUB_SUBDIR}"

sourceChartVersion="$(helm show chart $srcPath | grep ^version: | awk '{print $2}')"

mkdir -p $pubPath  # creates pubPath if it doesn't exist

if [[ $(ls -A "$pubPath") ]]; then  # if files exist in pubPath
  latestPublishedVersion="$( \
    cd $pubPath && ls *.tgz | sort -V | tail -n 1 | \
    grep -oP '[0-9]+\.[0-9]+\.[0-9]+(?=\.tgz)' \
  )"
  if dpkg --compare-versions $sourceChartVersion le $latestPublishedVersion; then
    echo "ERROR: App chart version '$sourceChartVersion' must be greater \
      than the latest published chart version '$latestPublishedVersion'."
    exit 1
  fi
fi

helm package $srcPath --destination $pubPath
helm repo index $pubPath --url $chartUrl

cd $BASE_PUB_DIR
git config --local user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config --local user.name "github-actions[bot]"
git add $PUB_SUBDIR
git commit -m "Published '$PUB_SUBDIR' version $sourceChartVersion"

start_time=$(date +%s)
timeout=$((start_time + 180))  # 3 minutes from now

set +e  # need to disable exit on error for git push

while true; do
  git pull --rebase || {
    echo "ERROR: Failed to 'git pull --rebase' due to merge conflicts."
    exit 1
  }
  git push && break

  current_time=$(date +%s)
  if [[ $current_time -ge $timeout ]]; then
    echo "ERROR: Failed to 'git push' after multiple attempts, timeout exceeded."
    exit 1
  fi
  sleep 10
done
