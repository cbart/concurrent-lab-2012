#include <pthread.h>
#include <stdio.h>

#define TIMES 5000000

void own_tasks(void) {
}

void critical_section(int *x) {
    int y;
    y = *x;
    y = y + 1;
    *x = y;
}

void *process(void *x) {
    int i;
    for (i = 0; i < TIMES; i++) {
        own_tasks();
        critical_section((int *)x);
    }
    pthread_exit(NULL);
    return NULL;
}

int main(int argc, char **argv) {
    pthread_t process1, process2;
    int i = 0;
    pthread_create(&process1, NULL, process, (void *)&i);
    pthread_create(&process2, NULL, process, (void *)&i);
    pthread_join(process1, NULL);
    pthread_join(process2, NULL);
    printf("%d\n", i);
    pthread_exit(NULL);
}
