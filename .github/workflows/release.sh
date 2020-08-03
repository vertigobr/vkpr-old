#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

: "${CR_TOKEN:?Environment variable CR_TOKEN must be set}"

git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
git config user.name "$GITHUB_ACTOR"

if [ -e yarn.lock ]; then
yarn install --frozen-lockfile
elif [ -e package-lock.json ]; then
npm ci
else
npm i
fi

mkdir -p /tmp/docusaurus/build
npx docusaurus build --out-dir /tmp/docusaurus/build

git reset --hard
git checkout gh-pages
cp -r --force /tmp/docusaurus/build/* .
git add .
git commit --message="Update gh-pages" --signoff

git push "https://x-access-token:$CR_TOKEN@github.com/$GITHUB_REPOSITORY" gh-pages