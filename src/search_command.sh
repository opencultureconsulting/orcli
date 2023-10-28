# shellcheck shell=bash disable=SC2154

# get project id
projectid="$(get_id "${args[project]}")"

# set facets config
args['--facets']='[ { "type": "list", "expression": "grel:filter(row.columnNames,cn,cells[cn].value.find(/'
args['--facets']+="${args[regex]}"
args['--facets']+='/).length()>0).length()>0", "columnName": "", "selection": [ { "v": { "v": true } } ] } ]'

# set template
template='{{'
template+='forEach(filter(row.columnNames, cn, cells[cn].value.find(/'
template+="${args[regex]}"
template+='/).length()>0), cn,'
if [[ ${args[--index]} ]]; then
    template+='cells["'
    template+="${args[--index]}"
    template+='"].value'
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
