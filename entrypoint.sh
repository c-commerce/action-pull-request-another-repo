#!/bin/bash
# shellcheck disable=SC2086

set -e
set -x

if [ -z "$INPUT_SOURCE_FOLDER" ]
then
  echo "Source folder must be defined"
  return -1
fi

# if [ $INPUT_DESTINATION_HEAD_BRANCH == "main" ] || [ $INPUT_DESTINATION_HEAD_BRANCH == "master"]
# then
#   echo "Destination head branch cannot be 'main' nor 'master'"
#   return -1
# fi

if [ -z "$INPUT_PULL_REQUEST_REVIEWERS" ]
then
  PULL_REQUEST_REVIEWERS=$INPUT_PULL_REQUEST_REVIEWERS
else
  PULL_REQUEST_REVIEWERS='-r '$INPUT_PULL_REQUEST_REVIEWERS
fi

CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Cloning destination git repository"
git clone "https://$PERSONAL_ACCESS_TOKEN@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

echo "Copying contents to git repo"
mkdir -p "$CLONE_DIR"/"$INPUT_DESTINATION_FOLDER"/


excludes=( $(echo "$INPUT_EXCLUDE_PATTERN" | tr ";" "\n") )

rsync -av --progress --exclude-from=<([ "${#excludes[@]}" -gt 0 ] && printf -- '- %s\n' "${excludes[@]}")  "$INPUT_SOURCE_FOLDER" "$CLONE_DIR/$INPUT_DESTINATION_FOLDER/"  

cd "$CLONE_DIR"

if $INPUT_ENABLE_SAFE_DIRECTORY
then
echo "Marking directory as a safe directory in git" 
git config --global --add safe.directory "$CLONE_DIR"
fi


git checkout -b "$INPUT_DESTINATION_HEAD_BRANCH"

echo "Adding git commit"
git add .
if git status | grep -q "Changes to be committed"
then
  export GITHUB_TOKEN="$PERSONAL_ACCESS_TOKEN"
  FALLBACK_MESSAGE="Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
  MESSAGE="${INPUT_MESSAGE:-$FALLBACK_MESSAGE}"
  git commit --message "${MESSAGE}"
  echo "Pushing git commit"

  git push -u origin HEAD:$INPUT_DESTINATION_HEAD_BRANCH "$INPUT_PUSH_ARGS"
  echo "Creating a pull request"
  gh pr create -t $INPUT_DESTINATION_HEAD_BRANCH \
               -b $INPUT_DESTINATION_HEAD_BRANCH \
               -B $INPUT_DESTINATION_BASE_BRANCH \
               -H $INPUT_DESTINATION_HEAD_BRANCH \
                  $PULL_REQUEST_REVIEWERS

  if $INPUT_AUTO_PUBLISH
  then
    gh pr merge --merge
    echo "Auto merging pull request"
  fi

else
  echo "No changes detected"
fi
