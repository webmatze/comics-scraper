#!/bin/bash

# This script takes a JSON file from the ComicVine API and converts it to a ComicInfo XML file.
# It requires the jq command line tool to be installed (https://stedolan.github.io/jq/).

# read piped data from stdin

# check if all arguments are provided or pipe is used
if [ $# -eq 0 ] && [ -t 0 ]; then
    echo "Usage: $0 <json_data> > <output_file>"
    exit 1
fi

piped_json=$(cat /dev/stdin)
json="${1:-$piped_json}" # Your JSON data here

# Parse the JSON
title=$(echo "$json" | jq -r '.results.volume.name')
issue=$(echo "$json" | jq -r '.results.issue_number')
summary=$(echo "$json" | jq -r '.results.description')
series=$(echo "$json" | jq -r '.results.volume.name')
publisher=$(echo "$json" | jq -r '.results.volume.publisher.name')
writer=$(echo "$json" | jq -r '[.results.person_credits[] | select(.role | test("writer")) .name] | join(", ")')
artist=$(echo "$json" | jq -r '[.results.person_credits[] | select(.role | test("artist")) .name] | join(", ")')
cover_date=$(echo "$json" | jq -r '.results.cover_date')

# Generate the XML
printf '<?xml version="1.0" encoding="UTF-8"?>
<ComicInfo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Title>%s</Title>
  <Issue>%s</Issue>
  <Summary>%s</Summary>
  <Series>%s</Series>
  <Publisher>%s</Publisher>
  <Writer>%s</Writer>
  <Artist>%s</Artist>
  <CoverDate>%s</CoverDate>
</ComicInfo>' "$title" "$issue" "$summary" "$series" "$publisher" "$writer" "$artist" "$cover_date"
