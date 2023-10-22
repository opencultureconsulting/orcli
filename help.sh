#!/bin/bash
# generate markdown files in subdirectory "help" from cli help screens
name="orcli"
orcli() {
    ./orcli "$@"
}

version="$(${name} --version)"
files=(src/*_command.sh)

for f in "${files[@]}"; do
command="${f#src/}"
command="${command%_command.sh}"
commands+=( "${command}" )
done

mkdir -p help
for command in "${commands[@]}"; do
    { echo "# ${name} ${command//_/ }"; } > help/"${command}".md
    { echo; echo '```'; } >> help/"${command}".md
    ${name} ${command//_/ } --help >> help/"${command}".md
    { echo '```'; echo; } >> help/"${command}".md
    echo "code: [src/${command}_command.sh](../src/${command}_command.sh)" >> help/"${command}".md
done

{ echo "# ${name} ${version}"; echo; } > help/README.md
{ echo '## command help screens'; echo; } >> help/README.md
for command in "${commands[@]}"; do
    echo "- [${command//_/ }](${command}.md)" >> help/README.md
done
{ echo; echo '## main help screen'; } >> help/README.md
{ echo; echo '```'; } >> help/README.md
${name} --help >> help/README.md
echo '```' >> help/README.md