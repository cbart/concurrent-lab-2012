#include <pthread.h>
#include <stdio.h>

#define TIMES 500000

volatile int x = 0;

void own_tasks(void) {
    int y = 2; int z = 4; z = y + y;
}

void critical_section(void) {
    int y;
    y = x;
    y = y + 1;
    x = y;
}

volatile int wants1 = 0;
volatile int wants2 = 0;
volatile int whoWaits = 0;

void *process_one(void *a) {
    int i;
    for (i = 0; i < TIMES; i++) {
        own_tasks();
        wants1 = 1;
        __sync_synchronize();
        whoWaits = 1;
        while (wants2 && (whoWaits == 1)) { }
        critical_section();
        wants1 = 0;
    }
    pthread_exit(NULL);
    return NULL;
}

void *process_two(void *a) {
    int i;
    for (i = 0; i < TIMES; i++) {
        own_tasks();
        wants2 = 1;
        __sync_synchronize();
        whoWaits = 2;
        while (wants1 && (whoWaits == 2)) { }
        critical_section();
        wants2 = 0;
    }
    pthread_exit(NULL);
    return NULL;
}

int main(int argc, char **argv) {
    pthread_t process1, process2;
    pthread_create(&process1, NULL, process_one, NULL);
    pthread_create(&process2, NULL, process_two, NULL);
    pthread_join(process1, NULL);
    pthread_join(process2, NULL);
    printf("%d\n", x);
    pthread_exit(NULL);
}
