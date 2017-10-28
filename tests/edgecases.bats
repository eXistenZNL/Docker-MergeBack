#/usr/bin/env bats

setup() {
    export PROJECTDIR=$PWD
}

@test "Running without a git repo" {
    cd $BATS_TMPDIR
    run $PROJECTDIR/merge-back.sh
    [ "$status" -eq 1 ]
    [ "$output" = "This is no git repository. Exiting..." ]
}
