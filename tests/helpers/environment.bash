#!/usr/bin/env sh

__environment_setup () {
    export PROJECT_DIR=$PWD

    export MBB_GIT_FORK="../origin"
    export MBB_GIT_NAME="MergeTestBot"
    export MBB_GIT_EMAIL="merge@test.bot"
    export MBB_FORK="../origin"
    export MBB_EXIT_CODES="true"
}
