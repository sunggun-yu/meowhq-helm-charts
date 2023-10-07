#!/bin/bash

charts_dir="charts"
release_please_config_file="release-please-config.json"
release_please_manifest_file=".release-please-manifest.json"
tmp_config_file=$(mktemp)
tmp_manifest_file=$(mktemp)
onboarding_chart_version="0.0.0"
has_changes=false

# Check if release_please_config_file exists
if [ ! -f "$release_please_config_file" ]; then
  echo "Error: $release_please_config_file not found."
  exit 1
fi

# initialize array to store updated charts
updated_charts=()
# Iterate through subdirectories in charts_dir
for sub_dir in "$charts_dir"/*; do
  # Check if sub_dir is a directory
  if [ -d "$sub_dir" ]; then

    # find Chart.yaml/yml for chart
    chart_file=$(find $sub_dir -maxdepth 1 -type f -name "Chart.yaml" -o -name "Chart.yml")

    # Check if either Chart.yaml or Chart.yml exists and is non-empty
    if [ -s "$chart_file" ]; then
      if ! jq -e --arg sub_dir "$sub_dir" '.packages | has($sub_dir)' "$release_please_config_file" >/dev/null; then
        # Use jq to update the JSON file
        jq --arg sub_dir "$sub_dir" '.packages |= . + {($sub_dir): {}}' "$release_please_config_file" > "$tmp_config_file"
        mv "$tmp_config_file" "$release_please_config_file"

        # set inititial version as 0.0.0 in release-please manifest to get bumped to 1.0.0 in release-please workflow
        jq --arg sub_dir "$sub_dir" \
          --arg chart_version "$onboarding_chart_version" \
          '. |= if has($sub_dir) then . else . + {($sub_dir): ($chart_version)} end' \
          "$release_please_manifest_file" > "$tmp_manifest_file"
        mv "$tmp_manifest_file" "$release_please_manifest_file"

        # update name of chart in Chart.yaml file with directory name of chart
        chart_name=$(basename $sub_dir)
        yq e ".name = \"$chart_name\"" $chart_file -i

        # set inititial version as Chart version
        yq e ".version = \"$onboarding_chart_version\"" $chart_file -i
        cat $chart_file

        # set has_changes true
        has_changes=true
        # add name of chart, which is directory name, into updated_chars array
        updated_charts+=($sub_dir)
      fi
    else
      echo "$sub_dir has no Chart.yaml/Chart.yml file or it is empty. it will be ignored"
    fi
  fi
done

echo "has_changes=$has_changes"
echo "updated_chars=${updated_charts[@]}"

# Output the updated JSON file
cat "$release_please_config_file"
cat "$release_please_manifest_file"

if [ -z $GITHUB_OUTPUT ]; then
GITHUB_OUTPUT=$(mktemp)
non_gha=true
fi

echo "test_github_output=some-value" >> "$GITHUB_OUTPUT"
cat $GITHUB_OUTPUT
if [ $non_gha ]; then
  rm $GITHUB_OUTPUT
fi
