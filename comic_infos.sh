#!/bin/bash

# Script accepts the parameters: filename and comicvine_api_key
if [[ $# -eq 0 ]] ; then
    echo 'Usage: comic_infos.sh <filename> <comicvine_api_key>'
    exit 1
fi

# if no api key is provided, try to use the environment variable
if [[ $# -eq 1 ]] ; then
    # load environment variables using .env file if available
    if [[ -f .env ]]; then
      set -o allexport # enable export of all variables
      source .env
      set +o allexport # disable export of all variables
    fi

    if [[ -z "${COMICVINE_API_KEY}" ]]; then
        echo 'No COMICVINE_API_KEY environment variable provided, exiting'
        exit 1
    fi
fi

filename="$1"
comicvine_api_key="${2:-$COMICVINE_API_KEY}"
remove_string="__ReadAllComics"

# Remove defined string from the filename
cleaned_filename=${filename//$remove_string/}

# Replace '_' characters with ' '
cleaned_filename=${cleaned_filename//_/ }

# Removing file extension
comic_name=${cleaned_filename%.cbz}

# Comicvine API url
url="https://comicvine.gamespot.com/api/search/"

# Prepare the search query
query=$(echo $comic_name | sed 's/ /%20/g')

# Search the comicvine API for data of comics with the name
response=$(curl -s -H "User-Agent:Mozilla/5.0" -H "Accept: application/json" \
"https://comicvine.gamespot.com/api/search/?api_key=${comicvine_api_key}&format=json&query=${query}&resources=volume")

# Parse the response with jq to get a list of comic names and IDs
comics=$(echo "$response" | jq -r '.results[] | "\(.name) \(.start_year) (\(.id))"')

# Let the user select a comic
selected=$(echo "$comics" | fzf)

# Extract the ID of the selected comic
id=$(echo "$selected" | awk '{print $NF}' | tr -d '()')

# Extract the JSON for the selected comic
selected_json=$(echo "$response" | jq -r ".results[] | select(.id == $id)")

# Extract api_detail_url of the selected comic
api_detail_url=$(echo "$selected_json" | jq -r '.api_detail_url')

# Request all issues for the selected volume
issues_response=$(curl -s -H "User-Agent:Mozilla/5.0" -H "Accept: application/json" \
"${api_detail_url}?api_key=${COMICVINE_API_KEY}&format=json")

# Parse the issues_response with jq to get a list of issue numbers and IDs
issues=$(echo "$issues_response" | jq -r '.results.issues[] | "\(.issue_number) \(.name) (\(.id))"')

# Let the user select an issue
selected_issue=$(echo "$issues" | fzf)

# Extract the ID of the selected issue
issue_id=$(echo "$selected_issue" | awk '{print $NF}' | tr -d '()')

# Extract the JSON for the selected issue
selected_issue_json=$(echo "$issues_response" | jq -r ".results.issues[] | select(.id == $issue_id)")

# Extract api_detail_url of the selected issue
issue_api_detail_url=$(echo "$selected_issue_json" | jq -r '.api_detail_url')

# Request all data for the selected issue
issue_data=$(curl -s -H "User-Agent:Mozilla/5.0" -H "Accept: application/json" \
"${issue_api_detail_url}?api_key=${COMICVINE_API_KEY}&format=json")

echo "$issue_data"
