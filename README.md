# Helm Charts for Meowhq K8s Clusters

This repository serves as a collection of Helm Charts designed for Meowhq clusters. In addition, it aims to showcase the following goals and solutions:

> meowhq is name of my home lab cluster 😉

## Goals

1. **Manage all Helm Charts in a Monorepo:** Consolidate all Helm Charts within a single GitHub repository.
2. **Automate Helm Chart Versioning:** Automate the versioning of Helm Charts when changes are pushed to the main branch.
3. **Publish Charts to a Registry/Repository:** Automatically publish the updated charts to a registry/repository when their versions are incremented.
4. **Selective Publishing:** Publish only the charts that have been modified and had their versions updated.
5. **Utilize Community Charts Efficiently:** Avoid reinventing the wheel; utilize existing community charts, customize them by adding required resources, setting default values, and using container images from proxy cache repositories like Harbor or Artifactory when necessary.
6. **Automatically Updating Helm Dependencies:** Incorporating changes from the upstream chart to quickly adopt the latest features and fixes.

## Solution

### Manage all the Helm Charts in Monorepo

1. Create a single GitHub repository and organize Helm Charts within the `charts` directory.
2. Utilize [`release-please`](https://github.com/googleapis/release-please) to automate the versioning of Helm Charts, allowing it to update the version in `Chart.yaml` file automatically.
3. Configure `release-please` to support Monorepo structures, ensuring that only charts with changes receive version updates in their `Chart.yaml` files.
4. Implement automated workflows using GitHub Actions and [`release-please-action`](https://github.com/google-github-actions/release-please-action).
5. Implement a GitHub Actions workflow with a shell script to analyze the Git history, determining which directories `Chart.yaml` files have received updates, and selectively publish them.
6. Leverage Helm chart dependencies and adopt a subchart methodology. Update dependencies when building a chart to include them in the package.
7. Utilize [`Renovate`](https://github.com/renovatebot/renovate) to automatically fetch updates for Helm dependencies and seamlessly integrate them into github actions workflows

By following these solutions, you can effectively manage and automate the versioning and publishing of Helm Charts within your Monorepo while optimizing the use of community charts.
