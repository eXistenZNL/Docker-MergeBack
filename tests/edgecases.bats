#/usr/bin/env bats

load helpers/environment

setup() {
    __environment_setup
}

@test "Running without a git repo" {
    cd $BATS_TMPDIR
    rm -rf .git
    run $PROJECT_DIR/merge-back.sh
    [ "${lines[6]}" = "This is not a git repository. Exiting..." ]
    [ "$status" -eq 1 ]
}

@test "Running without a git repo when exit codes should be suppressed" {
    export MBB_EXIT_CODES=false
    cd $BATS_TMPDIR
    rm -rf .git
    run $PROJECT_DIR/merge-back.sh
    [ "${lines[6]}" = "This is not a git repository. Exiting..." ]
    [ "$status" -eq 0 ]
}
