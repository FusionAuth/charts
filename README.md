# FusionAuth Helm Chart

![Build Status](https://github.com/FusionAuth/charts/actions/workflows/release.yml/badge.svg)

[FusionAuth](https://fusionauth.io/) is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting, and much more.

## Installation

See the [chart README](chart/README.md) for detailed information.

## Releasing the Chart

Release the chart by pushing a new tag.

```
git tag 1.0.0  <-- replace with your actual tag version
git push origin main --tags
```

The Actions workflow triggered by the tag push will automatically get the latest available version of FusionAuth and set that as the default for the chart, as well as updating the various files where the app version is referenced.
