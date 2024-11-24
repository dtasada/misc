#include <ncurses.h>
#include <stdbool.h>
#include <stdio.h>

#define ctrl(key) ((key) & 0x1f)

void exec_command(char command[1024]) { printf("%s", command); }

int main() {
    initscr();
    raw();
    noecho();

    bool QUIT = false;

    int ch;
    char command[1024] = {0};
    size_t command_s = 0;

    char command_history[1024][1024] = {0};

    while (!QUIT) {
        printw("[cbsh] $ ");
        printw(command);
        ch = getch();

        switch (ch) {
        case ctrl('q'):
            QUIT = true;
            break;
        case KEY_ENTER:
            exec_command(command);
            break;
        default:
            command[command_s++] = ch;
            break;
        }
        erase();
    }
    refresh();

    endwin();
    return 0;
}
