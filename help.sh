#!/bin/bash
# generate markdown files in subdirectory "help" from cli help screens
name="orcli"
orcli() {
    ./orcli "$@"
}

version="$(${name} --version)"
files=(src/commands/**/*.sh)
files+=(src/commands/*.sh)

for f in "${files[@]}"; do
    command="${f#src/commands/}"
    command="${command%.sh}"
    command="${command//\//_}"  
    commands+=( "${command}" )
done

mkdir -p help
for command in "${commands[@]}"; do
    { echo "# ${name} ${command//_/ }"; } > help/"${command}".md
    { echo; echo '```'; } >> help/"${command}".md
    ${name} ${command//_/ } --help >> help/"${command}".md
    { echo '```'; echo; } >> help/"${command}".md
    echo "code: [src/commands/${command//_/\/}.sh](../src/commands/${command//_/\/}.sh)" >> help/"${command}".md
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
