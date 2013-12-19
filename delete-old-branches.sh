#!/bin/bash

git fetch -p origin

DAYS=$1

if [ "$DAYS" == "" ]; then
  DAYS=7
fi

date --version > /dev/null 2>&1
if [ $? == 0 ]; then
  DATE=`date +%Y-%m-%d -d "-${DAYS}days"`
else
  DATE=`date  -v-${DAYS}d +%Y-%m-%d`
fi

REMOTE_BRANCHES=$(for k in `git branch -r --merged master | perl -pe 's/^..(.*?)( ->.*)?$/\1/'`; do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Creset" --after="$DATE" $k -- | head -n 1`$k; done | sort -r | grep '^origin' | sed 's/ *origin\///')

LOCAL_BRANCHES=$(for k in `git branch --merged master | perl -pe 's/^..(.*?)( ->.*)?$/\1/'`; do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Creset" --after="$DATE" $k -- | head -n 1`$k; done | sort -r | grep '^origin')


if [ "$REMOTE_BRANCHES" != "" ]; then

  echo "The following remote branches are fully merged into master and older than $DAYS days and will be removed: $REMOTE_BRANCHES"

  read -p "Continue (y/n)? "

  if [ "$REPLY" == "y" ]; then
  echo $REMOTE_BRANCHES | xargs git push origin --delete
  echo "Done!, Obsolete branches are removed"
  else
  echo "Moving on...."
  fi
else
  echo "No remote branches"
fi

if [ "$LOCAL_BRANCHES" != "" ]; then

  echo "The following local branches are fully merged into master and older than $DAYS days and will be removed: $LOCAL_BRANCHES"

  read -p "Continue (y/n)? "

  if [ "$REPLY" == "y" ]; then
  echo $LOCAL_BRANCHES | xargs git branch -r -d
  echo "Done!, Obsolete branches are removed"
  else
  echo "Moving on...."
  fi
else
  echo "No local branches"
fi

echo "Ended"
exit 0