#!/bin/bash

charts_dir="charts"
release_please_config_file="release-please-config.json"
release_please_manifest_file=".release-please-manifest.json"
tmp_config_file=$(mktemp)
tmp_manifest_file=$(mktemp)

# Check if release_please_config_file exists
if [ ! -f "$release_please_config_file" ]; then
  echo "Error: $release_please_config_file not found."
  exit 1
fi

# Create a temporary JSON file as a copy of the release_please_config_file and release_please_manifest_file
cp "$release_please_config_file" "$tmp_config_file"
cp "$release_please_manifest_file" "$tmp_manifest_file"

# Iterate through subdirectories in charts_dir
for sub_dir in "$charts_dir"/*; do
  # Check if sub_dir is a directory
  if [ -d "$sub_dir" ]; then
    chart_yaml="$sub_dir/Chart.yaml"
    chart_yml="$sub_dir/Chart.yml"

    # Check if either Chart.yaml or Chart.yml exists and is non-empty
    if [ -s "$chart_yaml" ] || [ -s "$chart_yml" ]; then
      # Use jq to update the JSON file
      jq --arg sub_dir "$sub_dir" '.packages |= if has($sub_dir) then . else . + {($sub_dir): {}} end' "$tmp_config_file" > "$tmp_config_file.tmp"
      mv "$tmp_config_file.tmp" "$tmp_config_file"
      
      # set inititial version in manifest as 0.0.0 to get bumped by release-please on initial workflow
      jq --arg sub_dir "$sub_dir" '. |= if has($sub_dir) then . else . + {($sub_dir): "0.0.0"} end' "$tmp_manifest_file" > "$tmp_manifest_file.tmp"
      mv "$tmp_manifest_file.tmp" "$tmp_manifest_file"
    else
      echo "$sub_dir has no Chart.yaml/Chart.yml file or it is empty. it will be ignored"
    fi
  fi
done

# you should do diff to check changes. diff with jq. it returns true | false
has_changes=$(jq -s '.[0].packages as $base | .[1].packages as $updated | ($base == $updated) | not' "$release_please_config_file" "$tmp_config_file")

# Check if there are differences
if [ true == $has_changes ]; then
  # There are differences; perform your actions here
  echo "New charts detected. updating $release_please_config_file ..."
  mv $tmp_config_file $release_please_config_file
  mv $tmp_manifest_file $release_please_manifest_file
else
  echo "No new charts detected."
  rm $tmp_config_file || true
  rm $tmp_manifest_file || true
fi

# Output the updated JSON file
cat "$release_please_config_file"
cat "$release_please_manifest_file"

if [ -z $GITHUB_OUTPUT ]; then
GITHUB_OUTPUT=$(mktemp)
non_gha=true
fi

echo "aaa=aaa" >> "$GITHUB_OUTPUT"
cat $GITHUB_OUTPUT
if [ $non_gha ]; then
  rm $GITHUB_OUTPUT
fi
