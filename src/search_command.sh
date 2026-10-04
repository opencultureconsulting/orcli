# shellcheck shell=bash disable=SC2154

# get project id
projectid="$(get_id "${args[project]}")"

# GREL expression to filter columns that match the regex
regex="$(grel_regex "${args[regex]}")"
columns="filter(row.columnNames, cn, cells[cn].value.find(${regex}).length()>0)"

# set facets config
args['--facets']='[ { "type": "list", "expression": '
args['--facets']+="$(json_string "grel:${columns}.length()>0")"
args['--facets']+=', "columnName": "", "selection": [ { "v": { "v": true } } ] } ]'

# set template
template='{{'
template+="forEach(${columns}, cn,"
if [[ ${args[--index]} ]]; then
    template+="cells[$(grel_string "${args[--index]}")].value"
else
    template+='(row.index + 1)'
fi
template+='+ "\t" + cn + "\t" +'
template+='forNonBlank(cells[cn].value, v, if(v.contains("	"), if(v.contains('\''"'\''), '\''"'\'' + v.replace('\''"'\'','\''""'\'') + '\''"'\'', '\''"'\'' + v + '\''"'\''), v),"")'
template+='+ "\n")'
template+='}}'

# assemble specific post data
data+=("project=${projectid}")
data+=("format=template")
data+=("template=${template}")

# call post_export function to post data and validate results
post_export "${data[@]}"
