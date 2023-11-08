# shellcheck shell=bash disable=SC2154 disable=SC2155
projectid="$(get_id "${args[project]}")"

# get columns that contain multiple values
if [[ ${args[--separator]} || ${args[--mode]} == "records" ]]; then
    if [[ ${args[--separator]} ]]; then
        engine='{"facets":[{"type":"list","columnName":"","expression":"grel:filter(row.columnNames,cn,cells[cn].value.contains(\"'
        engine+="${args[--separator]}"
        engine+='\"))","selection":[]}],"mode":"row-based"}'
    fi
    if [[ ${args[--mode]} == "records" ]]; then
        engine='{"facets":[{"type":"list","columnName":"","expression":"grel:filter(row.columnNames,cn,row.record.cells[cn].value.length()>1)","selection":[]}],"mode":"row-based"}'
    fi
    readarray -t columns_mv < <(curl -fs --data project="$projectid" --data "engine=${engine}" "${OPENREFINE_URL}/command/core/compute-facets" | jq -r '.facets[].choices[].v.v')
    readarray -t columns < <(curl -fs --get --data project="$projectid" "${OPENREFINE_URL}/command/core/get-columns-info" | jq -r '.[].name')
    readarray -t columns_mix < <(for i in "${columns[@]}"; do
        skip=
        for j in "${columns_mv[@]}"; do
            if [[ "$i" == "$j" ]]; then
                echo "\"$j⊌\"" # add special character that is used in template below
                skip=1; break
            fi
        done
        if [[ -z $skip ]]; then
            echo "\"$i\""
        fi
    done)
    multivalued=$(IFS=, ; echo "[${columns_mix[*]}]")
fi

# set template
template='{{'
if [[ ${args[--mode]} == "records" ]]; then
    template+='if(row.index - row.record.fromRowIndex == 0,'
fi
template+='"%7B".unescape("url") + " " +'
template+='forEach('
if [[ ${args[--separator]} || ${args[--mode]} == "records" ]]; then
    template+="$multivalued"
else
    template+='row.columnNames'
fi
template+=', cn, forNonBlank('
if [[ ${args[--separator]} || ${args[--mode]} == "records" ]]; then
    template+='cells[cn.chomp("⊌")].value, v, if(cn.endsWith("⊌"), "\"" + cn.chomp("⊌") + "\": " +'
    if [[ ${args[--separator]} ]]; then
    template+="v.split(\"${args[--separator]}\").jsonize()"
    fi
    if [[ ${args[--mode]} == "records" ]]; then
    template+='row.record.cells[cn.chomp("⊌")].value.jsonize()'
    fi
    template+=', "\"" + cn + "\": " + v.jsonize())'
else
    template+='cells[cn].value, v, "\"" + cn + "\": " + v.jsonize()'
fi
template+=', null)'
template+=').join(", ")'
template+='+ " " + "%7D".unescape("url") + "\n"'
if [[ ${args[--mode]} == "records" ]]; then
    template+=', "")'
fi
template+='}}'

# assemble specific post data
data+=("project=${projectid}")
data+=("format=template")
data+=("template=${template}")

# call post_export function to post data and validate results
post_export "${data[@]}"
