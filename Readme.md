# Git help

## Remove local changes and get the HEAD from a branch

Stash local changes

```bash
git stash --include-untracked
```

## Go back to the remote branch head

```bash
git reset --hard FETCH_HEAD
```

## Undoing changes on a remote branch

Add a new commit, that undoes the changes added by the commit at HEAD. Can then be pushed to the remote repo without messing with other peoples commit histories.

```bash
git revert HEAD
```

## What to do if you’re royally f\*\*\*ed

Use git reflog to look back in time

```bash
git reflog
```

Find a commit hash just before you stuffed something up, and checkout

```bash
git checkout [commit hash]
```

Bring the head to this commit

```bash
git switch -
```

Make sure this location has the correct state and history that you want. … if so

```bash
git reset --hard [commit hash]
```

If you are happy with your location and changes, then do a force push so the remote is up to date

```bash
git push -f
```

## Removing local commits

Removes the most recent commit

```bash
git reset HEAD~
```

## Rebasing

Finish changes in branch
Make pr
See conflicts
Rebase and solve conflicts in pr branch

```bash
git push --force # in pr branch
```

If someone else is on the same branch, ask what to do - git force push will affect them.

## Edit old commit in branch

https://www.bryanbraun.com/2019/02/23/editing-a-commit-in-an-interactive-rebase/

```bash
git rebase -i HEAD~1 # where 1 is the number of commits back you go, it can also be a sha
```

Change a commit to edit

```bash
git reset --soft HEAD~ # to remove commit, but keep changes to edit
```

Commit the fixed changes, then run

```bash
git rebase --continue
```

If the previous changes are on the remote, then do

```bash
git push -f
```

To rewrite the edited commit on the remote. Otherwise,

```bash
git push # is fine
```

## Apply a patch from a pr

Make the patch file
Go to github pr url and add ‘.diff’
Curl the url

Apply the patch with reject

```bash
git apply --reject --whitespace=fix ../xt-485.patch
```

## Apply a commit from another branch

```bash
git cherry-pick <hash>
```

## Apply commit from a commit in another project

```bash
git format-patch sha1^..sha1
cd /path/to/2
git am -3 --reject --whitespace=fix /path/to/1/0001-...-....patch
```

[script here](move-commit.sh)

## Change git branch name

```bash
​​git branch -m old-branch-name new-branch-name
git push origin -u new-branch-name
git push origin --delete old-branch-name
```

## Who deleted some text

```bash
for commit in $(git log --pretty='%H'); do
    git diff -U0 --ignore-space-change "$commit^" "$commit" | grep '^-.*text that was deleted' > /dev/null && echo "$commit"
done
```

## Steal files / folders from another branch

```bash
git checkout <branch_name> -- <paths>
```

## Gitignore isn’t respected?

Remember to commit everything you've changed before you do this!

```bash
git rm -rf --cached .
git add .
```

This removes all files from the repository and adds them back (this time respecting the rules in your .gitignore).

## Delete local branch

```bash
git branch -d <branch>
```

## Delete remote branch

```bash
git push <remote> --delete <branch>
```

## Amend the most recent local commit

```bash
git commit -a --amend
```
