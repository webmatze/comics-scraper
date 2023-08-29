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

The script can be used with the following command:
```bash
./comics_scraper.sh [OPTIONS]
```

### Options

- -u, --url URL: Specify the base URL to scrape comics from (mandatory).
- -p, --post-selector SELECTOR: Specify the CSS selector to extract post URLs (default: #post-area .post > center a attr{href}).
- -i, --image-selector SELECTOR: Specify the CSS selector to extract image URLs (default: center center div img[style*="max-width"] attr{src}).
- -d, --download-path PATH: Specify the base download path (default: data).
- -v, --verbose: Show verbose output.
- -h, --help: Show the help message.

### Example usage
By default, the script uses a set of default selectors to locate and download the comics.
```bash
./comics_scraper.sh -u https://readallfreecomics.com/
```
However, you can customize these settings by providing additional arguments.
```bash
./comics_scraper.sh -u https://readallfreecomics.com/ -p "#post-area .post > center a attr{href}" -i "center center div img[style*=\"max-width\"] attr{src}" -d data -v
```

## Disclaimer

This project is for education purposes only. Please use it only for free comics.
I do not support illegal downloads!

## Contributing

If you wish to contribute to this project, please submit an issue or a pull request!
