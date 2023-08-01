#!/bin/bash

default_url="https://readallfreecomics.com/"
default_post_selector="#post-area .post > center a attr{href}"
default_image_selector="center center div img[style*=\"max-width\"] attr{src}"
default_next_page_selector=".pagenavi a.next attr{href}"

base_url="${1:-$default_url}"
post_selector="${2:-$default_post_selector}"
image_selector="${3:-$default_image_selector}" 
next_page_selector="${4:-$default_next_page_selector}"

base_download_path="${5:-data}"

function scrape_page {
  posts_page=$(curl -s "$1")

  # Fetch the URLs of the posts
  post_urls=$(echo $posts_page | pup "${post_selector}")

  # Iterate over each post URL
  echo "$post_urls" | while read -r post_url
  do
    page=$(curl -s "$post_url")
   
    # Fetch the title of the page
    title=$(echo "$page" | pup 'title text{}' | awk '{$1=$1};1' | sed 's/ /_/g' | tr -cd '[:alnum:]_-()' )

    # do not extract images if a cbz file already exists
    if [[ -f "$base_download_path/$title.cbz" ]]; then
      echo "cbz file already exists for $post_url"
      continue
    fi

    echo "extracting images from $post_url"

    # Create the directory
    mkdir -p "$base_download_path/$title"

    # Fetch the image URLs on the page
    img_urls=$(echo "$page" | pup "${image_selector}")

    i=0

    # Download each image
    echo "$img_urls" | while read -r img_url
    do
      # increment the counter
      ((i++))
      filename=$(printf "%03d.jpeg" "$i")
      wget -P "$base_download_path/$title" "$img_url" -O "$base_download_path/$title/$filename"
    done

    # create a cbz file from the directory
    zip -r "$base_download_path/$title.cbz" "$base_download_path/$title"

    # remove the directory
    rm -rf "$base_download_path/$title"

  done

  # Fetch the URL of the next page
  next_page_url=$(echo "$posts_page" | pup "$next_page_selector")
  
  # check if next page exists
  if [[ -z "$next_page_url" ]]; then
    echo "no next page"
    return
  fi
  
  echo "scraping next page: $next_page_url"
  scrape_page "$next_page_url"
}

echo "scraping $base_url"
echo "post_selector: $post_selector"
echo "image_selector: $image_selector"
echo "next_page_selector: $next_page_selector"
echo "base_download_path: $base_download_path"

scrape_page "$base_url"
