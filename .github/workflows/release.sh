#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

: "${CR_TOKEN:?Environment variable CR_TOKEN must be set}"

readonly GIT_REPOSITORY_URL="$($GITHUB_SERVER_URL)/$($GITHUB_REPOSITORY)"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"
readonly CHART_RELEASER_VERSION=1.0.0-beta.1

main() {
    install
    pushd "$REPO_ROOT" > /dev/null

    echo "Fetching tags..."
    git fetch --tags

    local latest_tag
    latest_tag=$(git describe --tags --abbrev=0 --always)

    local latest_tag_rev
    latest_tag_rev=$(git rev-parse --verify "$latest_tag")
    echo "$latest_tag_rev $latest_tag (latest tag)"

    local head_rev
    head_rev=$(git rev-parse --verify HEAD)
    echo "$head_rev HEAD"

    # if [[ "$latest_tag_rev" == "$head_rev" ]]; then
    #     echo "No code changes. Nothing to release."
    #     exit
    # fi

    rm -rf .cr-release-packages
    mkdir -p .cr-release-packages

    rm -rf .cr-index
    mkdir -p .cr-index

    echo "Identifying changed charts since tag '$latest_tag'..."

    local changed_charts=()
    readarray -t changed_charts <<< "$(ls -d charts/*)"

    if [[ -n "${changed_charts[*]}" ]]; then
        for chart in "${changed_charts[@]}"; do
            echo "Packaging chart '$chart'..."
            package_chart "$chart"
        done

        release_charts
        update_index
    else
        echo "Nothing to do. No chart changes detected."
    fi

    popd > /dev/null
}

install() {
    echo "Installing Helm..."
    curl -fsSLo get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh

    echo "Installing chart-releaser..."
    curl -LO "https://github.com/helm/chart-releaser/releases/download/v${CHART_RELEASER_VERSION}/chart-releaser_${CHART_RELEASER_VERSION}_linux_amd64.tar.gz"
    sudo mkdir -p "/usr/local/chart-releaser-v$CHART_RELEASER_VERSION"
    sudo tar -xzf "chart-releaser_${CHART_RELEASER_VERSION}_linux_amd64.tar.gz" -C "/usr/local/chart-releaser-v$CHART_RELEASER_VERSION"
    sudo ln -s "/usr/local/chart-releaser-v$CHART_RELEASER_VERSION/cr" /usr/local/bin/cr
    rm -f "chart-releaser_${CHART_RELEASER_VERSION}_linux_amd64.tar.gz"
}

package_chart() {
    local chart="$1"
    helm package "$chart" --destination .cr-release-packages --dependency-update
}

release_charts() {
    cr upload -o vertigobr -r vkpr --token $CR_TOKEN
}

update_index() {
    cr index -o vertigobr -r vkpr -c https://vertigobr.github.io/vkpr

    git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
    git config user.name "$GITHUB_ACTOR"

    git reset --hard
    git checkout gh-pages
    cp --force .cr-index/index.yaml index.yaml
    git add index.yaml
    git commit --message="Update index.yaml" --signoff

    local repo_url="https://x-access-token:$CR_TOKEN@github.com/$GITHUB_REPOSITORY"
    git push "$repo_url" gh-pages
}

main
