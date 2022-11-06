#!/bin/bash

TARGET_NAME="LeitnerBox"
LOWERCASE_TARGET_NAME=$(echo $TARGET_NAME | awk '{print tolower($0)}')
BUNDLE_ID="ir.${TARGET_NAME}"
BUNDLE_VERSION="1.0.0"
DOCC_FILE_PATH="${pwd}/LeitnerBox/LeitnerBox.docc"
DOCC_HOST_BASE_PATH="${LOWERCASE_TARGET_NAME}"
DOCC_OUTPUT_FOLDER="./docs"
BRANCH_NAME="gh-pages"
DOCC_DATA="docsData"
DOCC_ARCHIVE="doccArchive"
GITHUB_USER_NAME="hamed8080"
ROOT_DIR=$(pwd)


#Use git worktree to checkout the $BRANCH_NAME branch of this repository in a $BRANCH_NAME sub-directory
git worktree add --checkout $BRANCH_NAME

cd $BRANCH_NAME #move to worktree directory to create all files there

# # Pretty print DocC JSON output so that it can be consistently diffed between commits
export DOCC_JSON_PRETTYPRINT="YES"

rm -rf $DOCC_DATA

xcodebuild \
-project $TARGET_NAME.xcodeproj \
-derivedDataPath $DOCC_DATA \
-scheme $TARGET_NAME \
-destination 'platform=iOS Simulator,name=iPhone 14' \
-parallelizeTargets \
docbuild

mkdir $DOCC_ARCHIVE

cp -R `find ${DOCC_DATA} -type d -name '*.doccarchive'` $DOCC_ARCHIVE

mkdir $DOCC_OUTPUT_FOLDER

for ARCHIVE in $DOCC_ARCHIVE/*.doccarchive; do
    cmd() {
        echo "$ARCHIVE" | awk -F'.' '{print $1}' | awk -F'/' '{print tolower($2)}'
    }
    ARCHIVE_NAME="$(cmd)"
    echo "Processing Archive: $ARCHIVE"
    $(xcrun --find docc) process-archive \
    transform-for-static-hosting "$ARCHIVE" \
    --hosting-base-path $TARGET_NAME/$ARCHIVE_NAME \
    --output-path $DOCC_OUTPUT_FOLDER/$ARCHIVE_NAME
done

### Save the current commit we've just built documentation from in a variable
CURRENT_COMMIT_HASH=$(git rev-parse --short HEAD)

## Commit our changes to the $BRANCH_NAME branch
echo "worktree documentation path: ${PWD}/$DOCC_OUTPUT_FOLDER"
git add $DOCC_OUTPUT_FOLDER

if [ -n "$(git status --porcelain)" ]; then
    echo "Documentation changes found. Committing the changes to the '$BRANCH_NAME' branch."
    echo "Please call push manually"
    git commit -m "Update Github Pages documentation site to $CURRENT_COMMIT_HASH"
    open -n https://$GITHUB_USER_NAME.github.io/${TARGET_NAME}/${DOCC_HOST_BASE_PATH}/documentation/${LOWERCASE_TARGET_NAME}/
else
    # No changes found, nothing to commit.
    echo "No documentation changes found."
fi

git worktree remove -f $BRANCH_NAME

# After deleting the worktree we should back to the root directory for pushing new files.
cd $ROOT_DIR
git push origin $BRANCH_NAME

