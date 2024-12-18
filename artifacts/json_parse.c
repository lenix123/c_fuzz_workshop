#include <stdio.h>
#include <unistd.h>
#include "json.h"

int main(int argc, char** argv) {
    size_t len;
    char buf[1024];
    json_char* json;
    json_value* value;

    len = read(STDIN_FILENO, buf, 1023);
    buf[len] = '\0';
    json = (json_char*)buf;

    value = json_parse(json, len);
    if (value == NULL) {
        printf("FAILED to parse json\n");
        return 1;
    }

    printf("SUCCESS to parse json\n");
    json_value_free(value);
    return 0;
}
