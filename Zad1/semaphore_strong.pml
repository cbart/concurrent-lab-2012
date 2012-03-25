#ifndef SEMAPHORE_STRONG
#define SEMAPHORE_STRONG

typedef sem_t {
  bit open;
  byte waits = 0;
  byte queue[THREADS] = 0;
};

#define OPEN 1
#define CLOSED 0

#define INIT_SEM(sem, value) sem.open = value

byte strong_loop = 0;

inline P(sem) {
  d_step {
    sem.queue[sem.waits] = _pid;
    sem.waits++;
  };
  d_step {
    sem.open && sem.queue[0] == _pid ->
    sem.open = false;
    strong_loop = 1;
    do
    :: strong_loop < THREADS ->
      sem.queue[strong_loop - 1] = sem.queue[strong_loop];
      strong_loop++
    :: strong_loop >= THREADS -> break
    od;
    sem.waits--
  }
}

inline V(sem) {
  sem.open = true
}

#endif  // SEMAPHORE_STRONG
