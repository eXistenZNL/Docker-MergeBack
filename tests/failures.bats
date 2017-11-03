#/usr/bin/env bats

load helpers/environment
load helpers/repository

setup () {
    __environment_setup
    __repository_setup
}

teardown () {
    __repository_teardown
}

@test "Checking the exit code upon error" {
    __repository_create_feature make-blue
    __repository_create_merge_conflict_with_feature make-blue

    cd $GIT_LOCAL_DIR
    run $PROJECT_DIR/merge-back.sh

    [ ${lines[9]} = "Merging master into feature/make-blue... FAILED!" ]
    [ "$status" -eq 1 ]
}

@test "Checking the exit code upon error when exit codes should be suppressed" {
    __repository_create_feature make-red
    __repository_create_merge_conflict_with_feature make-red

    cd $GIT_LOCAL_DIR
    export MBB_EXIT_CODES=false
    run $PROJECT_DIR/merge-back.sh

    [ ${lines[9]} = "Merging master into feature/make-red... FAILED!" ]
    [ "$status" -eq 0 ]
}
