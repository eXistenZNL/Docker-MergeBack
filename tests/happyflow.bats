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

@test "Running a mergeback without errors" {
    cd $GIT_
    __repository_create_feature make-orange
    __repository_create_feature make-yellow
    __repository_create_feature make-blue
    __repository_create_feature make-purple

    cd $GIT_LOCAL_DIR
    run $PROJECT_DIR/merge-back.sh

    [ "${lines[11]}" = "Hardcore merging action:" ]
    [ "${lines[12]}" = "Merging master into feature/make-blue... done." ]
    [ "${lines[13]}" = "Merging master into feature/make-orange... done." ]
    [ "${lines[14]}" = "Merging master into feature/make-purple... done." ]
    [ "${lines[15]}" = "Merging master into feature/make-yellow... done." ]
    [ "$status" -eq 0 ]
}
