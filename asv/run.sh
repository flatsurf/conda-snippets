#!/bin/bash
set -exo pipefail

# ##################################################################
# Run Airspeed Velocity and publish the results as github-pages
# ##################################################################

if [[ "$action" != "benchmark" ]]; then
  exit 0
fi

git config --global user.name 'CI Benchmark'
git config --global user.email 'benchmark@ci.invalid'
git config --global push.default nothing

sudo yum install -y openssh-clients
ssh-keyscan -H github.com >> ~/.ssh/known_hosts

pushd /home/conda/feedstock_root

# Clone performance data of previous runs
rm -rf .asv/results
git clone -b master $ASV_GITHUB_REPOSITORY .asv/results
  
cp $SNIPPETS_DIR/asv/asv-machine.$CI.json ~/.asv-machine.json
envsubst < $SNIPPETS_DIR/asv/asv.conf.json > asv.conf.json
mkdir -p asv
cp $SNIPPETS_DIR/asv/__init__.py asv
# We have to be on a branch. Otherwise, asv cannot find the branch for the
# commits and refuses to generate graphs.
git checkout -b master

asv run -v --machine=$CI

pushd .asv/results
git add .
git commit -m "Added benchmark run"
git fetch origin
git rebase origin/master
git log --oneline -3
unset SSH_AUTH_SOCK
if [[ "$ASV_SECRET_KEY" == "yes" ]]; then
  git push origin HEAD:master
fi
popd

asv gh-pages --no-push
if [[ "$ASV_SECRET_KEY" == "yes" ]]; then
  # We cannot push to origin since the outer repository has been cloned with
  # https://github.com/…
  git push $ASV_GITHUB_REPOSITORY gh-pages:gh-pages -f
fi

popd
