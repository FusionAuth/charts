# FusionAuth Helm Chart

![Build Status](https://github.com/FusionAuth/charts/actions/workflows/release.yml/badge.svg)

[FusionAuth](https://fusionauth.io/) is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting, and much more.

## Installation

See the [chart README](chart/README.md) for detailed information.

## Versioning

Beginning with 1.57.1, the Helm chart version is the same as the FusionAuth app version. This makes it easy to know which version of FusionAuth is set as the default in the chart. If you wish to upgrade the chart, but not the FusionAuth app version, set `image.tag` in the chart's values to the version of FusionAuth that you want to run.

We'll typically release any changes to the chart alongside new FusionAuth app versions. Changes will be called out in the release notes. If changes must be made to the chart outside of the FusionAuth app release cycle, we'll indicate that with a SemVer pre-release tag. For example, `1.57.1-1` would indicate the 1st revision of the chart after the `1.57.1` release, before the next FusionAuth app release.

## Testing Changes

Install the Helm unit test plugin:

```sh
helm plugin install https://github.com/helm-unittest/helm-unittest.git --verify=false
```

Run the chart test matrix locally:

```sh
helm unittest --strict chart
sh scripts/validate-chart.sh chart
```

Changes to the chart should have corresponding tests, and the tests must pass prior to release.

## Updating Chart Documentation

The chart README is generated from README.md.gotpml and `helm-docs`. Do not manually update `chart/README.md`. Update the template and regenerate it.

Install `helm-docs` with homebrew:

```sh
brew install norwoodj/tap/helm-docs
```

Install `helm-docs` with `go install`:

```sh
go install github.com/norwoodj/helm-docs/cmd/helm-docs@v1.14.2
```

Regenerate the chart README after changing `chart/values.yaml`, `chart/Chart.yaml`, or `chart/README.md.gotmpl`:

```sh
helm-docs -x --chart-search-root . --chart-to-generate chart
```

## Releasing the Chart

Make sure you've run tests and generated docs before releasing. The release could fail if these are not done.

Release the chart by pushing a new tag.

```
git tag 1.0.0  <-- replace with your actual tag version
git push origin main --tags
```

The Actions workflow triggered by the tag push will automatically get the latest available version of FusionAuth and set that as the default for the chart, as well as updating the various files where the app version is referenced.
