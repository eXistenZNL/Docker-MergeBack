#!/usr/bin/env sh

export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa-mergeback"

EXIT_CODES=${MBB_EXIT_CODES:-"true"}
GIT_BRANCH=${MBB_GIT_BRANCH:-"master"}
GIT_EMAIL=${MBB_GIT_EMAIL:-"bot3000@merge.back"}
GIT_NAME=${MBB_GIT_NAME:-"MergeBackBot3000"}
GIT_FORK=${MBB_GIT_FORK:-"git@git.local"}

mbb_setup () {
    mkdir -pvm 0700 ~/.ssh > /dev/null
    echo "$MBB_PRIVATE_KEY" > ~/.ssh/id_rsa-mergeback
    chmod 0600 ~/.ssh/id_rsa-mergeback
    git config user.name $GIT_NAME
    git config user.email $GIT_EMAIL
    git checkout --quiet $GIT_BRANCH
    git reset --quiet --hard HEAD
    git pull --quiet origin $GIT_BRANCH
    git fetch --quiet origin
    git remote | grep mergeback > /dev/null || git remote add mergeback $GIT_FORK
}

mbb_info () {
    branches=$1
    echo "Branches found:"
    for branch in $branches; do
        diff=$(git rev-list --left-right --count remotes/origin/$GIT_BRANCH...remotes/origin/$branch)
        behind=$(echo $diff | cut -d ' ' -f 1)
        ahead=$(echo $diff | cut -d ' ' -f 2)
        echo "$branch ($behind behind, $ahead ahead)"
    done
}

mbb_exit () {
    exitCode=$1
    if [ "$EXIT_CODES" = "false" ]; then
        echo 0;
    fi
    echo $exitCode;
}

mbb_merge () {
    echo "Hardcore merging action:"
    failed=0
    branches=$1
    for branch in $branches; do
        echo -n "Merging master into $branch... "
        git checkout --quiet $branch
        git pull --quiet origin $branch > /dev/null 2>&1
        git merge --no-ff --quiet --no-edit $GIT_BRANCH > /dev/null 2>&1
        if [ "$?" = "0" ]; then
            echo "done."
        else
            echo "FAILED!"
            git reset --hard HEAD > /dev/null 2>&1
            failed=1
        fi
    done

    if [ "$failed" = "1" ]; then
        echo ""
        echo "!! Some merges failed. Please manually resolve conflicts and push..."
    fi

    return $failed
}

mbb_push () {
    echo "Pushing branches:"
    for branch in $branches; do
        echo -n "Pushing $branch... "
        git push mergeback $branch --quiet > /dev/null 2>&1
        if [ "$?" = "0" ]; then
            echo "done."
        else
            echo "FAILED!"
        fi
    done
}

echo ""
echo "  ________                           _______               __ ___ _______        __"
echo " |        \\ ____ ____________  ____ |       \\_____  _____ |  |  /|       \\____ _/  |_"
echo " |  |  |  |/ __ \\|  ___/ __  \\/ __ \\|   |  _/\\__  \\/  ___\\|    / |   |  _/ __ \\_    _\\"
echo " |  |  |  |  ___/|  | / /_/  /  ___/|   |   \\ / __ \\  \\___|    \\ |   |   \\ \\_\\ \\|  |"
echo " |__/__/__/\\____\\|__| \\___  / \\____\\|_______/ \\_____\\_____\\__|__\\|_______/\\____/|__|"
echo "                     /_____/                                           by eXistenZNL"
echo ""

test -d .git
if [ "$?" -ne 0 ]; then
    echo "This is not a git repository. Exiting..."
    exit $( mbb_exit 1 )
fi

mbb_setup
branches=$(git branch -a | grep remotes/origin | grep -v $GIT_BRANCH | sed 's/remotes\/origin\///')
mbb_info "$branches"
echo ""
mbb_merge "$branches"
merge_status=$?
echo ""
mbb_push
push_status=$?

if [ "$merge_status" -eq 1 -o  "$push_status" -eq 1 ]; then
    exit $( mbb_exit 1 )
fi
exit $(mbb_exit 0)
