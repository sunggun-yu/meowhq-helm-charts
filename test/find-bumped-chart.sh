cd ..

# get the changed files
files_changed="$(git show --pretty="" --name-only)"

# get the directories that includes Chart.yaml file changes to get the charts that changed version
chart_file_changed="$(echo $files_changed | grep -E 'Chart\.ya?ml' | xargs dirname | grep -o "charts/[^/]*" | sort | uniq || true)"

# Initialize an empty array for version-changed charts
version_changed_charts=()

for chart in $chart_file_changed; do
  # Check if there's a version change in the Chart.yaml file
  if git show "$chart" | grep -q "+version"; then
    version_changed_charts+=("$chart")
  fi
done

GITHUB_OUTPUT=$(mktemp /tmp/temp-result.XXXXXX)

if [ ${#version_changed_charts[@]} -gt 0 ]; then
  chart_names=$(printf "%s\n" "${version_changed_charts[@]}")
  echo "charts=${version_changed_charts[@]}" >>$GITHUB_OUTPUT
  echo "result=ok" >>$GITHUB_OUTPUT
else
  echo "error=No version changed charts found" >>$GITHUB_OUTPUT
  echo "result=fail" >>$GITHUB_OUTPUT
fi

cat $GITHUB_OUTPUT
