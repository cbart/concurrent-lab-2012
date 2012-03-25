#ifndef SEMAPHORE_DIJKSTRA
#define SEMAPHORE_DIJKSTRA

typedef sem_t {
    bit open;
};

#define OPEN 1
#define CLOSED 0

#define INIT_SEM(sem, value) sem.open = value

inline P(sem) {
  d_step {
    sem.open ->
    sem.open = false
  }
}

inline V(sem) {
  sem.open = true
}

#endif  // SEMAPHORE_DIJKSTRA
