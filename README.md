# orcli (💎+🤖)

Bash script to control OpenRefine via [its HTTP API](https://docs.openrefine.org/technical-reference/openrefine-api).

## Features

* works with latest OpenRefine version (currently 3.5)
* batch processing (import, transform, export)
  * orcli takes care of starting and stopping OpenRefine with temporary workspaces
  * your existing OpenRefine data will not be touched
* import CSV, ~~TSV, line-based TXT, fixed-width TXT, JSON or XML~~ (and specify input options)
  * supports stdin, multiple files and URLs
* transform data by providing an [undo/redo](https://docs.openrefine.org/manual/running#history-undoredo) JSON file
  * orcli calls specific endpoints for each operation to provide improved error handling and logging
  * supports stdin, multiple files and URLs
* export to TSV, ~~CSV, HTML, XLS, XLSX, ODS~~
* ~~[templating export](https://docs.openrefine.org/manual/exporting#templating-exporter) to additional formats like JSON or XML~~

## Requirements

* GNU/Linux with Bash 4+
* [jq](https://stedolan.github.io/jq)
* [curl](https://curl.se)
* [OpenRefine](https://openrefine.org) 😉

## Install

1. Navigate to the OpenRefine program directory

2. Download bash script there and make it executable

```sh
wget https://github.com/opencultureconsulting/orcli/raw/main/orcli
chmod +x orcli
```

3. Optional: Create a symlink in your $PATH (e.g. to ~/.local/bin)

```sh
ln -s "${PWD}/orcli" ~/.local/bin/
```

## Usage

Use integrated help screens for available options and examples for each command.

```sh
orcli --help
```

## Development

orcli uses [bashly](https://github.com/DannyBen/bashly/) for generating the one-file script from files in the `src` directory

1. Install bashly (requires ruby)

```sh
gem install bashly
```

2. Edit code in [src](src) directory

3. Generate script

```sh
bashly generate --upgrade
```
