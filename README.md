# FusionAuth Helm Chart

![Build Status](https://github.com/FusionAuth/charts/actions/workflows/release.yml/badge.svg)

[FusionAuth](https://fusionauth.io/) is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting, and much more.

## Installation

See the [chart README](chart/README.md) for detailed information.

## Versioning

Beginning with 1.57.1, the Helm chart version is the same as the FusionAuth app version. This makes it easy to know which version of FusionAuth is set as the default in the chart. If you wish to upgrade the chart, but not the FusionAuth app version, set `image.tag` in the chart's values to the version of FusionAuth that you want to run.

We'll typically release any changes to the chart alongside new FusionAuth app versions. Changes will be called out in the release notes. If changes must be made to the chart outside of the FusionAuth app release cycle, we'll indicate that with a SemVer pre-release tag. For example, `1.57.1-1` would indicate the 1st revision of the chart after the `1.57.1` release, before the next FusionAuth app release.

## Releasing the Chart

Release the chart by pushing a new tag.

```
git tag 1.0.0  <-- replace with your actual tag version
git push origin main --tags
```

The Actions workflow triggered by the tag push will automatically get the latest available version of FusionAuth and set that as the default for the chart, as well as updating the various files where the app version is referenced.
