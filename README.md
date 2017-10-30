# MergeBack Bot

[![Docker Build Status](https://img.shields.io/docker/build/existenz/merge-back.svg?style=flat-square)](https://hub.docker.com/r/existenz/mergeback/builds/) [![Docker Pulls](https://img.shields.io/docker/pulls/existenz/merge-back.svg?style=flat-square)](https://hub.docker.com/r/existenz/mergeback/) [![License](https://img.shields.io/github/license/existenznl/docker-mergeback.svg?style=flat-square)](https://github.com/eXistenZNL/Docker-Mergeback/blob/master/LICENSE)

## About

A container that ships the merge-back command which can merge the production branch, e.g. master, back into all other
branches, in a CI like GitLab-CI. Built upon [Alpine Linux](https://alpinelinux.org/), and comes with a single handy
command that does all the heavy lifting.

## Why

When working with Continuous Deployment and Review Applications, you want to have all your branches up-to-date
with what's live on production. This container ensures that all open branches are updated with your target branch.

## So how does it work?

In this example we want to make sure our branch gets updated with everything that's merged into master.

1) In your `.gitlab-ci.yml`, add the following stage:

```yaml
stages:
    # All your previous stages go here
    - merge back # End with a merge-back

```

2) Add the job that runs in the merge back stage to your `.gitlab-ci.yml`:

```yaml
# ======================
# Merge back master
# ======================

update branches:
    image: existenz/merge-back:latest
    stage: merge back
    allow_failure: true # When you have merge conflicts, branches will not get auto updated, but you will get notified
    only:
        - master # add: "@namespace/project-name" to it to make sure it doesn't run on forks
    script:
        - merge-back
```

3) Make sure the following secret variables are set:

Variable | Default value | Context
--- | --- | ---
MBB_EXIT_CODES | false | Should the script have an exit code > 0 when it was unable to create a merge commit or push?
MBB_GIT_BRANCH | master | The branch you want to be merged back into your other branches
MBB_GIT_EMAIL | bot3000@merge.back | What e-mail address should be used for your git merge commit
MBB_GIT_NAME | MergeBackBot3000 | What username should be used for your git merge commit
MBB_GIT_FORK | git@git.local | The repository URL that you want to merge-back bot to be working for
MBB_PRIVATE_KEY | - | A private key, that has access to the project you want to merge back for, is needed to authorise the merge-backs 

4) Add your public key (for the private key you used in step 3) to the "Deploy keys" in the GitLab project config:

GitLab Project > Config > Repsitory > Deploy keys > add

**Note: Make sure you give the deploy key write access**

That should be all!

## Setting up this container

Inside the container, you can run the `merge-back` command directly. Make sure you have set up all variables like
mentioned above.

## Bugs, questions, and improvements

If you found a bug or have a question, please open an issue on the GitHub Issue tracker.
Improvements can be sent by a Pull Request against the develop branch and are greatly appreciated!
