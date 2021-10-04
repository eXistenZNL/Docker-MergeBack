# MergeBack Bot

[![Docker Build Status](https://img.shields.io/github/workflow/status/eXistenZNL/Docker-Mergeback/Build%20containers?style=flat-square)](https://github.com/eXistenZNL/Docker-MergeBack/actions) [![Docker Pulls](https://img.shields.io/docker/pulls/existenz/merge-back.svg?style=flat-square)](https://hub.docker.com/r/existenz/merge-back/) [![License](https://img.shields.io/github/license/existenznl/docker-mergeback.svg?style=flat-square)](https://github.com/eXistenZNL/Docker-MergeBack/blob/master/LICENSE)

## About

A container that ships the merge-back command which can merge the production branch, e.g. master, back into all other
branches, in a CI like GitLab-CI. Built upon [Alpine Linux](https://alpinelinux.org/), and comes with a single handy
command that does all the heavy lifting.

Running this container can be done in every CI pipeline that supports Docker containers, but was mainly built to run inside a GitLab-CI pipeline.

Special thanks to [RickvdStaaij](https://github.com/RickvdStaaij) for helping me out with the ASCII art and the inspiration
for building this small tool as part of a much larger project / process, in which we explored moving from a classic DTAP environment
to a containerized continuous deployment environment with review applications. May your builds be concurrent and your
[CIMonitor](https://github.com/CIMonitor/CIMonitor) green.

## Why

When working with Continuous Deployment and Review Applications, it's often very handy to have all your (feature) branches up-to-date
with what's live on production. This container ensures that all open branches are updated with your target branch.

## So how does it work?

Once merge-back command runs, it:
- Fetches the repository
- Loops over the branches
- Merges the specified (master?) branch into all the other branches with a merge commit
- And finally pushes the changes to the repository

## Using this container in a GitLab-CI pipeline

This is what the container is mostly used for.

### 1. .gitlab-ci.yml

In your `.gitlab-ci.yml`, add the following stage:

```yaml
stages:
    # All your previous stages go here
    - merge back # End with a merge-back
```
and the following job in that stage:

```yaml
# ======================
# Merge back master
# ======================

update branches:
  image: existenz/merge-back:latest
  stage: merge back
  allow_failure: true
  only:
    - master # add: "@namespace/project-name" to it to make sure it doesn't run on forks
  script:
    - merge-back
```

### 2. Configure a deploy key

First, generate a new keypair that has no password on the private key.

The reason for having a separate keypair (also stored stored as env variable MBB_PRIVATE_KEY below) is so we can push
back to the repository from a GitLab-CI runner. The default key that is used for checking out the project is a read-only
key so by default runners have no way of pushing code. Having this key in place circumvents that.

Add the public key from the keypair to the "Deploy keys" in the GitLab project config, available at
_GitLab Project > Config > Repository > Deploy keys > Add_.

Note: Make sure you give the deploy key write access, this is why we started this endeavour in the first place ;-)
That should be all!

### 3. Environment variables

Make sure the following environment variables are set in your pipeline. For obvious reasons, make the MBB_PRIVATE_KEY variable a secret.

| Variable        | Default value      | Context                                                                                      |
|-----------------|--------------------|----------------------------------------------------------------------------------------------|
| MBB_EXIT_CODES  | false              | Should the script have an exit code > 0 when it was unable to create a merge commit or push? |
| MBB_GIT_BRANCH  | master             | The branch you want to be merged back into your other branches                               |
| MBB_GIT_EMAIL   | bot3000@merge.back | What e-mail address should be used for your git merge commit                                 |
| MBB_GIT_NAME    | MergeBackBot3000   | What username should be used for your git merge commit                                       |
| MBB_GIT_FORK    | git@git.local      | The repository URL that you want to merge-back bot to be working for                         |
| MBB_PRIVATE_KEY | -                  | The private key from the keypair generated in step 2.                                        |

## Setting up this container outside of GitLab-CI

This container can be used everywhere you can run a docker container. Just make sure the container is able to push
towards the repository it pulls the code from, and make sure the container has the aforementioned environment variables
set. Then, simply run `merge-back` within the container.

## Bugs, questions, and improvements

If you found a bug or have a question, please open an issue on the GitHub Issue tracker.
Improvements can be sent by a Pull Request against the develop branch and are greatly appreciated!
