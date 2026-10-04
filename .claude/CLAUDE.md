# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`orcli` is a Bash CLI that controls [OpenRefine](https://openrefine.org) through its HTTP API (`curl` + `jq`, Bash 4.2+) on Linux and macOS (avoid GNU-only tool options such as `sed -i`, `readlink -f`/`-e`, `ps --no-headers` or `grep -P` in `src/` and `tests/`, and use braces for variables followed by non-ASCII characters, e.g. `"${j}⊌"`, because Bash on macOS reads UTF-8 bytes as part of the variable name; CI also runs the tests on macOS). It supports OpenRefine 3.3 to 3.10 (tested with 3.3, 3.4.1, 3.5.2, 3.6.2, 3.7.9, 3.8.7, 3.9.5 and 3.10.1; differences between versions are documented in the README section "Supported versions" — keep it up to date); development targets the latest release, so check older releases with `./test-versions.sh` (see Tests). It is meant to be dropped into the OpenRefine program directory, next to OpenRefine's `refine` startup script.

## Build system: bashly

The top-level `orcli` file is **generated** by [bashly](https://bashly.dev) from `src/` and committed to the repo. Never edit `orcli` by hand; edit `src/` and regenerate:

```sh
gem install bashly          # once (requires ruby)
bashly generate --upgrade   # regenerate ./orcli from src/
```

- `src/bashly.yml` defines every command, arg, flag, default, conflict and example (and the version number). Flags/args shared between commands are defined once with YAML anchors (`&file`, `&project`, `&quiet`, `&separator`, …) and reused with aliases (`*file`) — reuse them when adding commands.
- `src/<command>_command.sh` holds each command's body; nested commands use underscores (`import csv` → `import_csv_command.sh`). bashly exposes parsed input via the `args` associative array (`${args[--flag]}`, `${args[file]}`).
- `src/lib/*.sh` are shared functions bashly inlines into the script: `error`/`log` (stderr logging, honors `--quiet` and `ORCLI_QUIET`; `error` also prints the tail of OpenRefine's log when running inside `orcli run`), `get_csrf`, `get_id`/`get_ids` (resolve exact project name or 13-digit id), `init_import` + `post_import` (shared import pipeline; `import_options` adds the options of flags shared by import commands, commands add format-specific ones with `option key json`), `post_export` (shared export pipeline with `--facets`/`--mode`/`--output`), `post_command` (posts url-encoded data with CSRF token to other commands and checks the response `code`, because OpenRefine responds to many errors with HTTP 200 and `{"code":"error"}`; use it for every command that changes a project), `fetch_files` (download http(s) URLs into a lazily created `init_tmpdir`), `require_stdin` (usage and exit if stdin is selected but empty), `start_openrefine` (used by `run` and `test`), `interactive`, `send_completions`. `json.sh` escapes user input for JSON (`json_string`, `json_array`) and GREL (`grel_string`, `grel_regex`) in pure bash; always use it when inserting user input into options, facets or templates. `src/lib/validations/` holds bashly validators (`validate: integer`, `validate: positive_integer`) for numeric flags.
- Keep orcli lean and fast: prefer bash parameter expansion over spawning processes (`jq`, `cut`, `grep`) and avoid extra requests to OpenRefine.
- `src/initialize.sh` runs before every command.

After changing commands or help text, also regenerate the docs:

```sh
./help.sh                                  # writes help/*.md from --help screens
bashly render templates/html-form docs     # writes docs/*.html (published HTML form docs)
```

Releases bump `version:` in `src/bashly.yml`, then regenerate `orcli` and `docs/`.

## Checking OpenRefine releases

`./openrefine-api.sh VERSION` (git + perl) sparse-clones the OpenRefine source at that tag (or takes a local checkout path) and prints a Markdown report of all commands (request parameters), operations (`@JsonCreator` properties), importers (options with "UI default" from `createParserUIInitializationData()` and "parse default" from `JSONUtilities.getXxx(options, …, default)`) and exporters (options with defaults). `./openrefine-api.sh OLD NEW` prints the diff of both reports — use it on every new OpenRefine release to see whether orcli needs changes. orcli always sends an `options` JSON on import, so the *parse* defaults are the relevant ones. The script is regex-based (a heuristic); it handles the source layout of 3.3–3.10 (`main/src` and, since 3.9, `modules/*/src/main/java`; exporters registered in `ExporterRegistry` until 3.8 and in `controller.js` since 3.9).

## Architecture notes

- **Imports** (`import_*_command.sh`): call `init_import` (downloads http(s) URLs and `/dev/fd` pipes into a tmp dir; zips multiple files into `Untitled.zip` so OpenRefine treats them as one archive), build format-specific `options` JSON, then `post_import` posts to `create-project-from-upload` and validates the resulting project id / row count. Only CSV, TSV, TXT, JSON, JSONL are implemented. `import txt` uses OpenRefine's line-based importer (`--linesPerRow`; it ignores `headerLines`, so there is no header row) or, if `--columnWidths` is given, the fixed-width importer. The fixed-width importer applies `ignoreLines` after inserting `--columnNames`, so `import_txt_command.sh` converts `--ignoreLines` into `skipDataLines` in that case to behave like the other importers.
- **Exports** (`export_*_command.sh`): build `format`/options and call `post_export`, which posts to `export-rows`. `export template` uses OpenRefine's templating exporter.
- **Transform** (`transform_command.sh`): splits an undo/redo history JSON into individual operations and posts each one separately to `apply-operations` (as a one-element recipe) for logging and error messages per operation. Since OpenRefine 3.9 `apply-operations` validates operations up front (since 3.10 with clearer errors) and is more reliable than the operation-specific endpoints, whose request parameters also differ from the history JSON for some operations. Long-running operations (fetching URLs, reconciliation) respond with `pending`; `transform` then polls `get-processes` until they are done. Before 3.10 `apply-operations` responds without `historyEntries`, and before 3.9 it silently skips unknown or invalid operations (3.9 rejects them, with less clear messages), so `transform` compares the length of `get-history` before and after each operation and fails if nothing was applied.
- **`run`** (`run_command.sh`): starts OpenRefine (`refine -d <tmpdir> -x refine.headless=true`) with a throwaway workspace on `--port` (default 3333, `--memory` default 2048M), waits for `get-version` (polling every 0.25 s up to `--timeout`, failing early if OpenRefine exits), then runs the given bash script(s) with `alias orcli=<path>` in a `bash -e` subshell, or opens an interactive shell. A trap kills OpenRefine and removes the tmp workspace on exit.
- **Import encoding**: `post_import` also declares `--encoding` as charset in the multipart `Content-Type` header, because OpenRefine before 3.8 prefers its guessed (or declared) file encoding over the `encoding` option. This does not help for multiple files (zipped by `init_import`), whose encoding OpenRefine guesses per extracted file.
- All other commands talk to an already-running OpenRefine at `OPENREFINE_URL` (default `http://localhost:3333`).

## Tests

```sh
./orcli test
```

Requires OpenRefine's `refine` script in the same directory as `orcli` and nothing else listening on port 3333 (or another `--port`). OpenRefine is extracted into the repo root (`refine`, `server`, `webapp`, `refine.ini` are gitignored) by:
- `.claude/hooks/session-start.sh` in Claude Code cloud sessions — also installs the bashly version that generated `./orcli`, puts it on `PATH` and sets a UTF-8 locale (`import-csv-unicode.sh` fails under `POSIX`). Bump `OPENREFINE_VERSION` there and in `.devcontainer/devcontainer.json` together.
- `.devcontainer/devcontainer.json` in Codespaces/devcontainers.

`test` starts OpenRefine with a tmp workspace (same mechanism as `run`) and executes every `tests/*.sh` from inside `tests/`, printing PASSED/FAILED per file. There is no built-in single-test option; to run one test, run that file through `run` from inside `tests/`, e.g. `cd tests && ../orcli run import-csv.sh`.

`./test-versions.sh [VERSION...]` runs `orcli test` with each supported OpenRefine release (default 3.3 3.4.1 3.5.2 3.6.2 3.7.9 3.8.7 3.9.5 3.10.1; downloaded once to `~/.cache/orcli` or `$ORCLI_CACHE`, from GitHub releases or, for 3.6.x, Maven Central). Where OpenRefine versions legitimately differ (error messages, TSV quoting before 3.8, JSONL array formatting before 3.6 — the JSONL tests compare `jq -c` output, `includeArchiveFileName` before 3.5 and `trimStrings` before 3.4 have no effect), tests choose the expected output by the version from `get-version` (`case` on `3.[3-6] | 3.[3-7].*` etc.; note that x.y.0 releases such as 3.3 report the version without patch number); keep operations in tests to those available in all supported versions. OpenRefine localizes default column names (`Column 1`) by the server's Java language (e.g. `Spalte 1` on a German macOS), so tests with such columns normalize the header row of the output with `sed` instead of expecting English.

GitHub Actions (`.github/workflows/ci.yml`, on pull requests only) runs `shellcheck --shell=bash src/**/*.sh`, checks that `bashly generate --upgrade` leaves the repo unchanged (so commit the regenerated `orcli`) and runs `./test-versions.sh` as a matrix over all supported OpenRefine releases (keep that list in sync with `test-versions.sh`).

Test convention (one file per command/flag, named `<command>-<flag>.sh`): copy input and expected output from `tests/data/` into a `mktemp -d` dir, run `orcli` commands there, and finish with `diff -u "${t}.assert" "${t}.output"` — the diff's exit code is the test result. Keep test input in `tests/data/` rather than remote URLs: when `orcli` is used standalone (without the repo), `test` downloads the repo's `main.zip` and extracts only `tests/*.sh` and `tests/data/*`, so tests must reference data via the relative `data/` path. `transform.sh` deliberately imports from a `raw.githubusercontent.com` URL to cover URL import and needs network access.
