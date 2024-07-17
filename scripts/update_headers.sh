#!/bin/bash

camel_to_snake() {
    local input="$1"
    echo "$input" | sed -E 's/([A-Z]+)([A-Z][a-z])/\1_\2/g' | sed -E 's/([a-z\d])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}

folder_path="$(pwd)"
echo "Start processing in $folder_path"

find "$folder_path" -type f -name "*.h" | while read -r file_path; do
    echo "Found $file_path"
    if [[ "$file_path" != *"PubSubTypes.h"* ]]; then

        file_name=$(basename $file_path)

        class_name=$(basename $file_name | cut -d'.' -f1)
        
        file_content=$(cat $file_path)

        modified_line=$(echo "$file_content" | grep -n "#include \"${class_name}PubSubTypes.h\"")
        echo "Modified line: $modified_line"

        if [ -n "$modified_line" ]; then
            echo "The file $file_name has already been modified. Skipping..."
            continue
        fi

        file_content=$(echo "$file_content" | sed '/#include/ i\
#include <memory>' | sed '0,/#include <memory>/! {/#include <memory>/d}')


        modified_content=$(echo "$file_content" | sed "s/class $class_name/class $class_name : public std::enable_shared_from_this<$class_name>/")

        modified_content_with_include=$(echo "$modified_content" | sed "$ a #include \"${class_name}PubSubTypes.h\"")

        modified_content_with_insert=$(echo "$modified_content_with_include" | awk -v insert_code="            using SharedPtr = std::shared_ptr<${class_name}>;" '/class '$class_name'/ {p=1} p && /public:/ {print; print insert_code; p=0} 1')

        echo "$modified_content_with_insert" > $file_path
        snake_name=$(camel_to_snake $class_name)

        directory_path=$(dirname "$file_path")
        directory_name=$(basename "$directory_path")

        parent_path=$(dirname "$directory_path")
        parent_directory_path=$(basename "$parent_path")
                
        include_guard=$(echo "${parent_directory_path}__${directory_name}__${class_name}.hpp" | tr '[:lower:]' '[:upper:]' | tr '/' '_' | tr '.' '_')

        {
        echo -e "#ifndef ${include_guard}"
        echo -e "#define ${include_guard}\n"
        echo -e "#include \"${class_name}PubSubTypes.h\"\n"
        echo -e "template <>\nstruct ParentTypeTraits<${parent_directory_path}::${directory_name}::${class_name}> {"
        echo -e "    using Type = ${parent_directory_path}::${directory_name}::${class_name}PubSubType;"
        echo -e "};\n"
        echo -e "#endif  // ${include_guard}"
        } >> "$directory_path/$snake_name.hpp"
        echo "Modified the file $file_name"

    fi
done

