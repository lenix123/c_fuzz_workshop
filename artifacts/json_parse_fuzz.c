#include "json.h"

int main(int argc, char** argv) {
    json_char* json;
    json_value* value;

    
    value = json_parse(json,file_size);

    json_value_free(value);
    free(file_contents);
    return 0;
}