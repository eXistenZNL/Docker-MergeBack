#!/usr/bin/env sh

export TEST_ROOT_DIR="$BATS_TMPDIR/mbb_test"
export GIT_ORIGIN_DIR="$TEST_ROOT_DIR/origin"
export GIT_LOCAL_DIR="$TEST_ROOT_DIR/local"

__repository_setup () {
    rm -rf $TEST_ROOT_DIR
    mkdir -p $GIT_ORIGIN_DIR
    mkdir -p $GIT_LOCAL_DIR

    # Build a fake remote origin and fill it with stuff
    cd $GIT_ORIGIN_DIR
    git init
    echo "Test line 1" >> README.md
    echo "Test line 2" >> README.md
    echo "Test line 3" >> README.md
    git add -A
    git commit --no-gpg-sign -m "0 Initial commit"

    # Create a local fork and fetch from origin...
    cd $GIT_LOCAL_DIR
    git init
    git remote add origin $GIT_ORIGIN_DIR
    git fetch origin
}

__repository_create_feature () {
    cd $GIT_ORIGIN_DIR
    feature=$1
    git checkout -b feature/$feature
    echo "Feature commit" >> feature-$feature.txt
    git add -A
    git commit --no-gpg-sign -m "Feature commit: $feature"
}

__repository_create_merge_conflict_with_feature () {
    cd $GIT_ORIGIN_DIR
    git checkout master
    feature=$1
    echo "This is now a merge conflict" >> feature-$feature.txt
    git add -A
    git commit --no-gpg-sign -m "Conflicting feature commit: $feature"
}

__repository_teardown () {
    rm -rf $TEST_ROOT_DIR
}
