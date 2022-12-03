# orcli (💎+🤖)

Bash script to control OpenRefine via [its HTTP API](https://docs.openrefine.org/technical-reference/openrefine-api).

## Features

* works with latest OpenRefine version (currently 3.6)
* run batch processes (import, transform, export)
  * orcli takes care of starting and stopping OpenRefine with temporary workspaces
  * allows execution of arbitrary bash scripts
  * interactive mode for playing around and debugging
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

Optional:

* Create a symlink in your $PATH (e.g. to ~/.local/bin)

  ```sh
  ln -s "${PWD}/orcli" ~/.local/bin/
  ```

* Install Bash tab completion

  * temporary

    ```sh
    source <(orcli completions)
    ```

  * permanently

    ```sh
    mkdir -p ~/.bashrc.d
    orcli completions > ~/.bashrc.d/orcli
    ```

## Getting Started

1. Launch an interactive playground

  ```sh
  ./orcli run --interactive
  ```

2. Create OpenRefine project `duplicates` from comma-separated-values (CSV) file

  ```sh
  orcli import csv "https://git.io/fj5hF" --projectName "duplicates"
  ```

3. Remove duplicates by applying an undo/redo JSON file

  ```sh
  orcli transform "duplicates" "https://git.io/fj5ju"
  ```

4. Export data from OpenRefine project to tab-separated-values (TSV) file `duplicates.tsv`

  ```sh
  orcli export tsv "duplicates" --output "duplicates.tsv"
  ```

5. Write out your session history to file `example.sh` (and delete the last line to remove the history command)

  ```sh
  history -a "example.sh"
  sed -i '$ d' example.sh
  ```

6. Exit playground

  ```sh
  exit
  ```

7. Run whole process again

  ```sh
  ./orcli run example.sh
  ```

## Usage

* Use integrated help screens for available options and examples for each command.

  ```sh
  orcli --help
  ```

* If your OpenRefine is running on a different port or host, then use the environment variable OPENREFINE_URL.

  ```sh
  OPENREFINE_URL="http://localhost:3333" orcli list
  ```

* If OpenRefine does not have enough memory to process the data, it becomes slow and may even crash. Check the message after the run command finishes to see how much memory was used and adjust the memory allocated to OpenRefine accordingly with the `--memory` flag (default: 2048M).

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

4. Run tests

  ```sh
  ./orcli test
  ```