#ifndef SEMAPHORE_DIJKSTRA
#define SEMAPHORE_DIJKSTRA

typedef sem_t {
    bit closed;
};

#define OPEN 1
#define CLOSED 0

#define INIT_SEM(sem, value) sem.closed = value

inline P(sem) {
  d_step {
    sem.closed ->
    sem.closed = false
  }
}

inline V(sem) {
  sem.closed = true
}

#endif  // SEMAPHORE_DIJKSTRA
