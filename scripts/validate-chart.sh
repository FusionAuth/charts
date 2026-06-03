#!/usr/bin/env sh
set -eu

chart="${1:-chart}"

helm lint "$chart" \
  --set database.host=postgres \
  --set database.dbUser.username=fusionauth \
  --set database.dbUser.password=password \
  --set search.host=opensearch

helm template test "$chart" \
  --set database.host=postgres \
  --set database.dbUser.username=fusionauth \
  --set database.dbUser.password=password \
  --set search.engine=database \
  --set ingress.enabled=true \
  --set ingress.hosts[0]=example.com \
  --set ingress.paths[0].path=/ \
  --set ingress.paths[0].pathType=Prefix \
  --set autoscaling.enabled=true \
  --set podDisruptionBudget.enabled=true \
  --set networkPolicy.enabled=true \
  --set serviceMonitor.enabled=true \
  >/dev/null
