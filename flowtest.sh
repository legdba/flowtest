#!/bin/bash
###############################################################################
# Simulates a GitHub-like flow:
# * Master is always potentially shippable and shall always be clean
# * Work is always done within branches, pulled/synced/merged from/to master
# 
# Extra rules:
# * Branches are merged to master without fast-forward to make the commit
#   obvious and keep the branch visualy obvious
# * Branches shall be merged with master often to be in-sync with it.
#   Tracked branches shall be merged with fast-forward.
#   Untracked branches should be rebased instead.
# * Merging to master should really be approved by somebody not involved in
#   the coding of the branch. Pull-requests are the perfect tool there.
#
###############################################################################
# Git Flow Usage
#
# Merging a non-master branch to mater:
#     git checkout master
#     git merge --no-ff -m "merge BRANCH to master" BRANCH
#     git push
#
# Delete a branch both locally and remotely
#     git branch -d BRANCH
#     git tag -a BRANCH -m "tagging to BRANCH"
#     git push origin BRANCH
#
# Merge a tracked branch from master with fast-foward
#     git fetch -p origin
#     git merge -m "merge master to BRANCH" master
#
# Merge an untracked branch from master with rebase
#     git fetch -p origin
#     git rebase master
#
###############################################################################
# Lessons learned:
# * Always have SourceTree (or any equivalent) running on your repos to check
#   the visual history before you push anything! Keeping a clean and easy to
#   read history is critical, and only a visual check can guarantee this.
# * Configure git: git config --global push.default simple
# * Remote (tracked) branches shall be synced with master using
#   "git pull origin master -p" ; Rebase shall not be used with tracked
#   branches since that would change history and cause conflicts for you and
#   others; fast-forward is used their to avoid generating un-necessary commits
# * Local (untracked) branches should be synced with
#   "git pull --rebase origin master -p" instead since a local branch base can
#   be changed without impact for anybody and rebasing will actually have a
#   cleaner history when you later track it.
# * When a branch has been merged and you know it will not be reused, delete
#   that branch, create a tag with the same name, and push; this helps
#   having less branches cluttering the CLI/GUI.
#   Tagging shall be done AFTER the branch has been deleted (since tagging with
#   a name that is a branch already would fail).
#   Do not use "git push origin --delete [branch]" to push and delete; when
#   doing so the branch is deleted but still hanging locally somewhere, causing
#   "git push origin [tagname]" to fail is tag name is the same as the branch.
# * Tag with '-a' option by default.
# * Do not use "git push --tags" on a day-today basis; this would push old
#   un-deleted local tags to the repos when you don't want this to happen.
# * When you are about to push commits to a tracked branch a "git rebase -i"
#   should be considered to compact lot of small local commits into fewer
#   bigger one so that to keep history simple and easy to read
# * This script is merging branches directly. In real flow using pull-request
#   is preferable.
#
###############################################################################
# Commands references
#
# This command
#   git pull --no-edit origin master -p
# is equivalent to
#   git fetch -p origin
#   git merge -m "merge master to $BRANCH" master
#
# This command
#   git pull --no-edit --rebase origin master -p
# is equivalent to
#   git fetch -p origin
#   git rebase master
#
# From git 2 use
#   git config --global credential.helper cache
# to allow credentials to be cached.
#
###############################################################################
# TODOs
# TODO: check if there is a way to run
#         git push origin --delete $BRANCH
#         git tag -a $BRANCH
#         git push origin $BRANCH
#      waithout having a git error about the tag name being used already.
#
###############################################################################
# References:
# https://guides.github.com/introduction/flow/index.html
# http://www.git-attitude.fr/2014/05/04/bien-utiliser-git-merge-et-rebase/
#
###############################################################################

export REPO='https://github.com/legdba/flowtest.git'

###############################################################################
echo
echo ">>>> Create repo, attach to origin, set README and add this script"
mkdir flowtest || exit
cat $0 > flowtest/flowtest.sh || exit
cd flowtest || exit
git init || exit
git remote add origin $REPO || exit
echo "Script simulating a git workflow to 1/ validate commands and options to use and 2/ be a reference of commands and options to use." > README.md || exit
echo "This repo hosts both the script (flowtest.sh) and the history it generates." >> README.md || exit
echo "The simulated flow is similar to GitHub one: master is always potentially shippable, all work is done in branches, etc. See GitHub flow for more details." >> README.md || exit
echo "See flowtest.sh for more details." >> README.md || exit
git add README.md flowtest.sh || exit
git commit -am "add README and flowtest.sh" || exit
git push -u origin master || exit
export TAG=generated_with_git_$(git --version | awk '{ print $3}')
git tag -a $TAG -m "tagging with git version used" || exit
git push origin $TAG || exit

###############################################################################
echo
echo ">>>> Add a hello script within a tracked branch, don't merge yet, commit intermediate work, we'll hack more code later"
export BRANCH='add_echo_script' || exit
git checkout -b $BRANCH master || exit
git push -u origin $BRANCH || exit
echo '#!/bin/bash' > hello.sh || exit
echo 'echo hello world' >> hello.sh || exit
chmod a+x hello.sh || exit
git add hello.sh || exit
git commit -am "add hello world script" || exit
git push origin HEAD || exit

###############################################################################
echo
echo ">>>> Add a COLLABORATORS list within an untracked branch, locally commit intermediate work, we'll hack more code later"
export BRANCH='add_collaborators' || exit
git checkout -b $BRANCH master || exit
echo 'legdba' > COLLABORATORS || exit
git add COLLABORATORS || exit
git commit -am "add collaborator: legdba" || exit

###############################################################################
echo
echo ">>>> Add a license within a branch, commit and merge"
export BRANCH='add_license' || exit
git checkout -b $BRANCH master || exit
git push -u origin $BRANCH || exit
echo 'do whatever you want with this repo, it is for testing ;)' >> LICENSE || exit
git add LICENSE || exit
git commit -am "add license" || exit
git push origin HEAD || exit
git checkout master || exit
git merge --no-ff -m "merge $BRANCH to master" $BRANCH || exit
git push origin HEAD || exit
git branch -d $BRANCH || exit
git tag -a $BRANCH -m "tagging to $BRANCH" || exit
git push origin $BRANCH || exit

###############################################################################
echo
echo ">>>> Get back to add_echo_script branch, hack, merge from master, keep hacking and commit intermediate work"
export BRANCH='add_echo_script' || exit
git checkout $BRANCH || exit
echo '#!/bin/bash' > hello.sh || exit
echo 'echo hello $@' >> hello.sh || exit
git commit -am "improved hello by echoing input params" || exit
git push origin HEAD || exit
git pull --no-edit origin master -p || exit # --no-edit is for scripting only, don't use it when not scripting

###############################################################################
echo
echo ">>>> Add a COPYRIGHT within a branch, commit and merge"
export BRANCH='add_copyright' || exit
git checkout -b $BRANCH master || exit
git push -u origin $BRANCH || exit
echo 'Copyright legdba 2014' >> COPYRIGHT || exit
git add COPYRIGHT || exit
git commit -am "add copyright" || exit
git push origin HEAD || exit
git checkout master || exit
git merge --no-ff -m "merge $BRANCH to master" $BRANCH || exit
git push origin HEAD || exit
git branch -d $BRANCH || exit
git tag -a $BRANCH -m "tagging to $BRANCH" || exit
git push origin $BRANCH || exit

###############################################################################
echo
echo ">>>> Add another COLLABORATORS within an untracked branch, rebase to clean history, rebase from master, track, merge"
export BRANCH='add_collaborators' || exit
git checkout $BRANCH || exit
echo 'vbo' >> COLLABORATORS || exit
git commit -am "add collaborator: vbo" || exit
git pull --no-edit --rebase origin master -p || exit # --no-edit is for scripting only, don't use it when not scripting
git push -u origin HEAD || exit
git checkout master || exit
git merge --no-ff -m "merge $BRANCH to master" $BRANCH || exit
git push origin HEAD || exit
git branch -d $BRANCH || exit
git tag -a $BRANCH -m "tagging to $BRANCH" || exit
git push origin $BRANCH || exit

###############################################################################
echo
echo ">>>> Get back to add_echo_script branch, hack more code, merge from master, merge to master"
export BRANCH='add_echo_script' || exit
git checkout $BRANCH || exit
echo '#!/bin/bash' > hello.sh || exit
echo '# echo hello and the input params' >> hello.sh || exit
echo 'echo hello $@' >> hello.sh || exit
git commit -am "added comment to clarify this complex script ;)" || exit
git push origin HEAD || exit
git pull --no-edit origin master -p || exit # --no-edit is for scripting only, don't use it when not scripting
git push origin HEAD || exit
git checkout master || exit
git merge --no-ff -m "merge $BRANCH to master" $BRANCH || exit
git push origin HEAD || exit
git branch -d $BRANCH || exit
git tag -a $BRANCH -m "tagging to $BRANCH" || exit
git push origin $BRANCH || exit

###############################################################################
echo
echo ">>>> Locally remove merged and remotely deleted branches"
# The command below comes from SO: http://stackoverflow.com/questions/13064613/git-how-to-prune-local-tracking-branches-that-do-not-exist-on-remote-anymore
# It kind of a monster command but comes handly since git do not have any utility to do the same
git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -d || exit

###############################################################################
echo
echo ">>>> Display the resulting history; hopefully it should be clean"
git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all