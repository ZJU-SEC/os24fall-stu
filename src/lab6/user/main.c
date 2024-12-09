#include "stdio.h"
#include "unistd.h"
#include "string.h"

#define CAT_BUF_SIZE 509

char string_buf[2048];
char filename[2048];

int atoi(char* str) {
    int ret = 0;
    int len = strlen(str);
    for (int i = 0; i < len; i++) {
        ret = ret * 10 + str[i] - '0';
    }
    return ret;
}

char *get_param(char *cmd) {
    while (*cmd == ' ') {
        cmd++;
    }
    int pos = 0;
    while (*cmd != '\0' && *cmd != ' ') {
        string_buf[pos++] = *(cmd++);
    }
    string_buf[pos] = '\0';
    return string_buf;
}

char *get_string(char *cmd) {
    while (*cmd == ' ') {
        cmd++;
    }

    if (*cmd == '"') { // quote wrapped
        cmd++;
        int pos = 0;
        while (*cmd != '"') {
            string_buf[pos++] = *(cmd++);
        }
        string_buf[pos] = '\0';
        return string_buf;
    } else {
        return get_param(cmd);
    }
}

void parse_cmd(char *cmd, int len) {
    if (cmd[0] == 'e' && cmd[1] == 'c' && cmd[2] == 'h' && cmd[3] == 'o') {
        cmd += 4;
        char *echo_content = get_string(cmd);
        len = strlen(echo_content);
        cmd += len;
        write(1, echo_content, len);
        write(1, "\n", 1);
    } else if (cmd[0] == 'c' && cmd[1] == 'a' && cmd[2] == 't') {
        char *filename = get_param(cmd + 3);
        char last_char;
        int fd = open(filename, O_RDONLY);
        if (fd == -1) {
            printf("can't open file: %s\n", filename);
            return;
        }
        char cat_buf[CAT_BUF_SIZE];
        while (1) {
            int num_chars = read(fd, cat_buf, CAT_BUF_SIZE);
            if (num_chars == 0) {
                if (last_char != '\n') {
                    printf("$\n");
                }
                break;
            }
            for (int i = 0; i < num_chars; i++) {
                if (cat_buf[i] == 0) {
                    write(1, "x", 1);
                } else {
                    write(1, &cat_buf[i], 1);
                }
                last_char = cat_buf[i];
            }
        }
        close(fd);
    } else if (cmd[0] == 'e' && cmd[1] == 'd' && cmd[2] == 'i' && cmd[3] == 't' ) {
        cmd += 4;
        while (*cmd == ' ' && *cmd != '\0') {
            cmd++;
        }
        char* temp = get_param(cmd);
        int len = strlen(temp); 
        char filename[len + 1];
        for (int i = 0; i < len; i++) {
            filename[i] = temp[i];
        }
        filename[len] = '\0';
        cmd += len;

        while (*cmd == ' ' && *cmd != '\0') {
            cmd++;
        }
        temp = get_param(cmd);
        len = strlen(temp);
        char offset[len + 1];
        for (int i = 0; i < len; i++) {
            offset[i] = temp[i];
        }
        offset[len] = '\0';
        cmd += len;

        while (*cmd == ' ' && *cmd != '\0') {
            cmd++;
        }
        temp = get_string(cmd);
        len = strlen(temp);
        char content[len + 1];
        for (int i = 0; i < len; i++) {
            content[i] = temp[i];
        }
        content[len] = '\0';
        cmd += len;

        int offset_int = atoi(offset);

        int fd = open(filename, O_RDWR);
        lseek(fd, offset_int, SEEK_SET);
        write(fd, content, len);
        close(fd);
    } else {
        printf("command not found: %s\n", cmd);
    }
}

int main() {
    write(1, "hello, stdout!\n", 15);
    write(2, "hello, stderr!\n", 15);
    char read_buf[2];
    char line_buf[128];
    int char_in_line = 0;
    printf(YELLOW "SHELL > " CLEAR);
    while (1) {
        read(0, read_buf, 1);
        if (read_buf[0] == '\r') {
            write(1, "\n", 1);
        } else if (read_buf[0] == 0x7f) {
            if (char_in_line > 0) {
                write(1, "\b \b", 3);
                char_in_line--;
            }
            continue;
        }
        write(1, read_buf, 1);
        if (read_buf[0] == '\r') {
            line_buf[char_in_line] = '\0';
            parse_cmd(line_buf, char_in_line);
            char_in_line = 0;
            printf(YELLOW "SHELL > " CLEAR);
        } else {
            line_buf[char_in_line++] = read_buf[0];
        }
    }
    return 0;
}