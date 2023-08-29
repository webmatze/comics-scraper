#!/bin/bash

DEBUG=false

default_post_selector="#post-area .post > center a attr{href}"
default_image_selector="center center div img[style*=\"max-width\"] attr{src}"
default_next_page_selector=".pagenavi a.next attr{href}"
default_download_path="data"

function show_help {
  echo "Usage: comics_scraper.sh [OPTIONS]"
  echo "Options:"
  echo "  -u, --url URL                 Specify the base URL to scrape comics from (mandatory)"
  echo "  -p, --post-selector SELECTOR  Specify the CSS selector to extract post URLs (default: '$default_post_selector')"
  echo "  -i, --image-selector SELECTOR Specify the CSS selector to extract image URLs (default: '$default_image_selector')"
  echo "  -d, --download-path PATH      Specify the base download path (default: '$default_download_path')"
  echo "  -v, --verbose                 Show verbose output"
  echo "  -h, --help                    Show this help message"
}

if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi

while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    -u|--url)
      base_url="$2"
      shift
      shift
      ;;
    -p|--post-selector)
      post_selector="$2"
      shift
      shift
      ;;
    -i|--image-selector)
      image_selector="$2"
      shift
      shift
      ;;
    -d|--download-path)
      base_download_path="$2"
      shift
      shift
      ;;
    -v|--verbose|--debug)
      DEBUG=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Invalid option: $1"
      show_help
      exit 1
      ;;
  esac
done

if [[ -z "$base_url" ]]; then
  echo "Error: no URL provided"
  show_help
  exit 1
fi

if ! command -v pup &> /dev/null
then
  echo "Error: pup command not found. Please install pup and try again."
  exit 1
fi

post_selector="${post_selector:-$default_post_selector}"
image_selector="${image_selector:-$default_image_selector}" 
base_download_path="${base_download_path:-$default_download_path}"

function fetch_post_urls {
  local url="$1"
  
  local posts_page=$(curl -s "$url")
  local post_urls=$(echo "$posts_page" | pup "$post_selector")
  echo "$post_urls"
}

function download_images {
  local page="$1"
  local title="$2"
  
  # do not extract images if a cbz file already exists
  if [[ -f "$base_download_path/$title.cbz" ]]; then
    echo "cbz file already exists for $post_url"
    return
  fi
  
  if $DEBUG; then
    echo "extracting images from $post_url"
  fi
  
  # Create the directory
  mkdir -p "$base_download_path/$title"
  
  # Fetch the image URLs on the page
  local img_urls=$(echo "$page" | pup "$image_selector")
  
  local i=0
  
  # Download each image
  echo "$img_urls" | while read -r img_url
  do
    # increment the counter
    ((i++))
    local filename=$(printf "%03d.jpeg" "$i")
    wget -P "$base_download_path/$title" "$img_url" -O "$base_download_path/$title/$filename"
  done
  
  # create a cbz file from the directory
  zip -r "$base_download_path/$title.cbz" "$base_download_path/$title"
  
  # remove the directory
  rm -rf "$base_download_path/$title"
}

function scrape_page {
  local url="$1"
  
  # Fetch the URLs of the posts
  local post_urls=$(fetch_post_urls "$url")

  if [[ -z "$post_urls" ]]; then
    echo "Error: No URLs could be found using the provided post_selector: '$post_selector'."
    exit 1
  fi
  
  # Iterate over each post URL
  echo "$post_urls" | while read -r post_url
  do
    local page=$(curl -s "$post_url")
   
    # Fetch the title of the page
    local title=$(echo "$page" | pup 'title text{}' | awk '{$1=$1};1' | sed 's/ /_/g' | tr -cd '[:alnum:]_-()' )
    
    download_images "$page" "$title"
  done

  echo "done downloading all comics on the page."
}

if $DEBUG; then
  echo "scraping $base_url"
  echo "post_selector: $post_selector"
  echo "image_selector: $image_selector"
  echo "base_download_path: $base_download_path"
fi

scrape_page "$base_url"
