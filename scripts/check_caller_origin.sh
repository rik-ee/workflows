#!/bin/bash

#  Required env vars:
#   1) GITHUB_REPO = ${{ github.repository }}
#   2) CALLER_NAME = name of the caller workflow

if [[ $GITHUB_REPO != rik-ee/* ]]; then
  echo "ERROR: Reusable workflow '$CALLER_NAME' is only \
    available to repositories within the RIK organization."
  echo "If you wish to use this reusable workflow in your project, \
    you must copy and modify this workflow and any related scripts \
    to be specifically suitable for your project requirements."
  exit 1
fi
