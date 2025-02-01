#!/bin/bash
set -e

# Configure git credentials helper for AWS CodeCommit
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

# Configure git user info
git config --global user.name "Alexander Yizchak Sanin"
git config --global user.email "alexaaander.sanin@gmail.com"

echo "Git configured for AWS CodeCommit"
echo "Please update user.name and user.email in this script before running"
