#!/bin/bash

camel_to_snake() {
    local input="$1"
    echo "$input" | sed -E 's/([A-Z]+)([A-Z][a-z])/\1_\2/g' | sed -E 's/([a-z\d])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}
snake_to_camel() {
    local input="$1"
    echo "$input" | sed -r 's/(^|_)([a-z])/\U\2/g'
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
        } > "$directory_path/$snake_name.hpp"
        echo "Modified the file $file_name"

    fi
done


# ファイルのチェック
find "$folder_path" -type f -name "*_request.hpp" | while read -r request_file_path; do
    echo "Found request file: $request_file_path"
    
    # _request.hppを_response.hppに置き換えたファイルパスを生成
    response_file_path="${request_file_path/_request.hpp/_response.hpp}"
    
    # 対応する_response.hppファイルが存在するかチェック
    if [ -f "$response_file_path" ]; then
        echo "Corresponding response file exists: $response_file_path"
        
        # ベース名を生成
        base_name="${request_file_path%_request.hpp}.hpp"
        
        # 新しいベース名のファイルを作成
        touch "$base_name"

        class_name=$(basename $base_name | cut -d'.' -f1)
        camel_class_name=$(snake_to_camel $class_name)

        directory_path=$(dirname "$base_name")
        directory_name=$(basename "$directory_path")

        parent_path=$(dirname "$directory_path")
        parent_directory_path=$(basename "$parent_path")
                
        include_guard=$(echo "${parent_directory_path}__${directory_name}__${class_name}.hpp" | tr '[:lower:]' '[:upper:]' | tr '/' '_' | tr '.' '_')

        {
        echo -e "#ifndef ${include_guard}"
        echo -e "#define ${include_guard}\n"
        echo -e "#include \"${class_name}_request.hpp\"\n"
        echo -e "#include \"${class_name}_response.hpp\"\n"
        echo -e "namespace ${parent_directory_path} {\n"
        echo -e "  namespace ${directory_name} {\n"
        echo -e "    struct ${camel_class_name} {\n"
        echo -e "      using Request = ${parent_directory_path}::${directory_name}::${camel_class_name}_Request;"
        echo -e "      using Response = ${parent_directory_path}::${directory_name}::${camel_class_name}_Response;"
        echo -e "    };\n"
        echo -e "  };\n"
        echo -e "};\n"
        echo -e "#endif  // ${include_guard}"
        } > "$base_name"
        echo "Created file: $base_name"
    else
        echo "Corresponding response file does not exist for: $request_file_path"
    fi
done
