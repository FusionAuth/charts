# FusionAuth Helm Chart

![Build Status](https://github.com/FusionAuth/charts/actions/workflows/release.yml/badge.svg)

[FusionAuth](https://fusionauth.io/) is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting, and much more.

## Installation

See the [chart README](chart/README.md) for detailed information.

## Releasing the Chart

You can release the chart by bumping the git tag:

```
cd <charts directory>
git tag 1.0.0
git push origin master --tags
```

To default to a new version of FusionAuth, update these 4 files with the new version number:

```
README.md
chart/Chart.yaml
chart/examples/minikube/values.yaml
chart/values.yaml
```

⚠️ Users must always be able to override the default version in the chart by overriding `image.tag`.
