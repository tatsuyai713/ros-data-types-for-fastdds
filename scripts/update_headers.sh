#!/bin/bash

camel_to_snake() {
    local input="$1"
    echo "$input" | sed -E 's/([A-Z]+)([A-Z][a-z])/\1_\2/g' | sed -E 's/([a-z\d])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}

directory="."

find "$directory" -type f -name "*.h" | while read -r file; do
    if [[ "$file" != *"PubSubTypes.h"* ]]; then
        base_name=$(basename "$file" .h)

        parent_dir="$(dirname "${file}")"
        parent_dir_name="$(basename "${parent_dir}")"

        grandparent_dir="$(dirname "${parent_dir}")"
        grandparent_dir_name="$(basename "${grandparent_dir}")"

        pubsubtypes_file="${base_name}PubSubTypes.h"
        snake_case=$(camel_to_snake "$file")
        
        if ! grep -q "#include \"$pubsubtypes_file\"" "$file"; then
            # echo "#include \"fast_dds_header.hpp\"" >> "$file"
            echo "#include \"$pubsubtypes_file\"" >> "$file"

            sed -i '/^class '${base_name}'$/ {
N
s/^class '${base_name}'/class '${base_name}' : public std::enable_shared_from_this<'${base_name}'>/
N
a\
\ \ \ \ using SharedPtr = std::shared_ptr<'${base_name}'>;
            }' "$file"
            
            cp "$file" "${snake_case}pp"

        else
            echo "#include \"$pubsubtypes_file\" already exists in $file"
        fi
    fi
done

