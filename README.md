# Comics Scraper

A versatile and user-friendly bash script that scrapes and downloads comics from various websites, ultimately packaging them into .cbz files for easy reading.

## Prerequisites

- You will need to have `bash`, `curl`, `pup`, `awk`, `sed`, `tr`, `wget`, and `zip` installed on your system.
- To install `pup` (a command line parser for HTML), you can follow the instructions given [here](https://github.com/ericchiang/pup).

## Installation

1. Clone the repository:
    ```
    git clone https://github.com/webmatze/comics-scraper.git
    ```
2. Change the permissions of the script to make it executable:
    ```
    chmod +x comics_scraper.sh
    ```

## Usage

By default, the script targets the imaginary `https://readallfreecomics.com/` and uses a set of default selectors to locate and download the comics. However, you can customize these settings by providing additional arguments.

You can run the script as follows:

```
./comics_scraper.sh <base_url> <post_selector> <image_selector> <next_page_selector> <base_download_path>
```

- `base_url`: The URL of the website from where to scrape the comics.
- `post_selector`: The CSS selector to fetch the URLs of the posts.
- `image_selector`: The CSS selector to fetch the image URLs on the post page.
- `next_page_selector`: The CSS selector to fetch the URL of the next page.
- `base_download_path`: The base path where the .cbz files will be saved.

If no arguments are provided, the script will use the default values. 

## Disclaimer

This project is for education purposes only. Please use it only for free comics.
I do not support illegal downloads!

## Contributing

If you wish to contribute to this project, please submit an issue or a pull request!
