### FusionAuth Helm Chart ${CHART_VERSION}

**⚠️ The FusionAuth app version matches the chart version.** The means that, by default, upgrading the chart will also upgrade the FusionAuth app version.

If you do not want a chart upgrade to modify the app version, set the `image.tag` value in the chart. You can set this in a custom values file, or by passing `--set image.tag=[version]` to the helm install/upgrade command, where `[version]` is the FusionAuth app version that you wish to use.

To see what's new in FusionAuth ${CHART_VERSION}, go to the [release notes](https://fusionauth.io/docs/release-notes/).
