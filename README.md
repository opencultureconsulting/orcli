# orcli (💎+🤖)

Bash script to control OpenRefine via [its HTTP API](https://docs.openrefine.org/technical-reference/openrefine-api).

![Demo](demo.gif)

## Features

* works with OpenRefine 3.3 to 3.10 (see [Supported versions](#supported-versions))
* run batch processes (import, transform, export)
  * orcli takes care of starting and stopping OpenRefine with temporary workspaces
  * allows execution of arbitrary bash scripts
  * interactive mode for playing around and debugging
  * your existing OpenRefine data will not be touched
* supports stdin, multiple files and URLs
* import CSV, TSV, TXT (line-based or fixed-width), JSON, JSONL, ~~XML~~
* transform data by providing an [undo/redo](https://docs.openrefine.org/manual/running#history-undoredo) JSON file
  * orcli applies each operation separately to provide improved error handling and logging
* export to CSV, TSV, JSONL, ~~HTML, XLS, XLSX, ODS~~
* [templating export](https://docs.openrefine.org/manual/exporting#templating-exporter) to additional formats like JSON or XML

## Requirements

* GNU/Linux or macOS with Bash 4.2+
* [jq](https://jqlang.org)
* [curl](https://curl.se)
* [OpenRefine](https://openrefine.org) 😉 (3.3 or later)

On macOS, install a recent Bash with [Homebrew](https://brew.sh) (macOS ships Bash 3.2) and make sure Homebrew's `bin` directory comes first in your `PATH` (which `brew shellenv` does). jq is preinstalled since macOS 15 (Sequoia), on older versions install it with Homebrew, too:

```sh
brew install bash jq
```

## Install

1. Navigate to the OpenRefine program directory (the one with OpenRefine's startup script `refine`)

2. Download bash script there and make it executable

  ```sh
  curl -fsSLO https://github.com/opencultureconsulting/orcli/raw/main/orcli
  chmod +x orcli
  ```

On macOS, the OpenRefine app (`.dmg`) does not contain the startup script `refine` that orcli needs to start OpenRefine. Use the Linux release (`openrefine-linux-*.tar.gz`) instead, which runs on macOS with an installed Java 11 or later (e.g. `brew install --cask temurin@21`), and put orcli next to its `refine` script:

```sh
curl -fsSL https://github.com/OpenRefine/OpenRefine/releases/download/3.10.1/openrefine-linux-3.10.1.tar.gz | tar -xz
cd openrefine-3.10.1
curl -fsSLO https://github.com/opencultureconsulting/orcli/raw/main/orcli
chmod +x orcli
```

Optional:

* Create a symlink in your $PATH (e.g. to ~/.local/bin)

  ```sh
  mkdir -p ~/.local/bin
  ln -s "${PWD}/orcli" ~/.local/bin/
  ```

  On macOS, ~/.local/bin is not in $PATH by default. Add it to your zsh configuration and open a new terminal:

  ```sh
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
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
  sed -i.bak '$ d' example.sh && rm example.sh.bak
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

* Use [📖 HTML form docs](https://code.opencultureconsulting.com/orcli) or integrated help screens for available options and examples for each command.

  ```sh
  orcli --help
  ```

* If your OpenRefine is running on a different port or host, then use the environment variable OPENREFINE_URL.

  ```sh
  OPENREFINE_URL="http://localhost:3333" orcli list
  ```

* If OpenRefine does not have enough memory to process the data, it becomes slow and may even crash. Check the message after the run command finishes to see how much memory was used and adjust the memory allocated to OpenRefine accordingly with the `--memory` flag (default: 2048M).

* OpenRefine names columns without header by the system language of the server (e.g. `Spalte 1` instead of `Column 1` on a German system). `orcli run` and `orcli test` start OpenRefine in English (unless `JAVA_OPTIONS` is set); to start OpenRefine yourself in English, use `JAVA_OPTIONS=-Duser.language=en ./refine`.

## Supported versions

| OpenRefine | tested with | differences |
|---|---|---|
| 3.10 | 3.10.1 | – |
| 3.9 | 3.9.5 | `transform`: less clear error messages (e.g. `java.lang.IllegalArgumentException: Missing field lengths` instead of `Operation #1: Missing field lengths`) |
| 3.8 | 3.8.7 | `transform`: OpenRefine skips unknown or invalid operations without an error, so orcli only reports `operation was not applied` (details in OpenRefine's log) |
| 3.7 | 3.7.9 | as 3.8; `export csv`/`tsv`: special characters are quoted instead of escaped (e.g. `"x"""` instead of `x"`); `import --encoding` is ignored for multiple files; `import tsv --ignoreQuoteCharacter` removes quote characters |
| 3.6 | 3.6.2 | as 3.7; `import csv --ignoreQuoteCharacter` also removes quote characters |
| 3.5 | 3.5.2 | as 3.7; `export jsonl`: arrays without spaces (`["a","b"]` instead of `[ "a", "b" ]`) |
| 3.4 | 3.4.1 | as 3.5; `import --includeArchiveFileName` has no effect |
| 3.3 | 3.3 | as 3.4; `import --trimStrings` has no effect |

## Development

orcli uses [bashly](https://github.com/DannyBen/bashly/) for generating the one-file script from files in the `src` directory.

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

  To run the tests with all supported OpenRefine releases (downloaded to `~/.cache/orcli`):

  ```sh
  ./test-versions.sh                 # 3.3 3.4.1 3.5.2 3.6.2 3.7.9 3.8.7 3.9.5 3.10.1
  ./test-versions.sh 3.10.1 3.11.0   # or any other releases
  ```

  GitHub Actions ([ci.yml](.github/workflows/ci.yml)) runs shellcheck, checks that `orcli` is up to date with `src` and runs the tests with all supported OpenRefine releases on every pull request (and the tests with the latest release on macOS).

5. Generate docs

  ```sh
  bashly render templates/html-form docs
  ```

### Check new OpenRefine releases

[openrefine-api.sh](openrefine-api.sh) lists the commands (with request parameters), operations (with JSON properties), importers and exporters (with options and default values) of an OpenRefine release as found in its source code (requires git and perl). Compare the latest release orcli supports with a new release to find out whether orcli needs to be adapted (and run `./test-versions.sh` with the new release):

  ```sh
  ./openrefine-api.sh 3.10.1 > openrefine-3.10.1.md   # report for one release
  ./openrefine-api.sh 3.9.5 3.10.1                    # diff between two releases
  ```
