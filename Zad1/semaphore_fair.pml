#ifndef SEMAPHORE_ROUND_ROBIN
#define SEMAPHORE_ROUND_ROBIN

typedef sem_t {
  bit open;
  byte next_wakeup = 0;
  bit hang[THREADS] = 1;
  bit waits[THREADS] = false;
};

#define OPEN 1
#define CLOSED 0

#define INIT_SEM(sem, value) sem.open = value; all(sem, OPEN)

byte round_robin_loop = 0;
bit round_robin_flag = 0;

inline all(sem, value) {
  round_robin_loop = 0;
  do
  :: round_robin_loop < THREADS ->
    sem.hang[round_robin_loop] = value;
    round_robin_loop++
  :: round_robin_loop >= THREADS -> break
  od
}

#define succ(n) ((n + 1) % THREADS)
#define waits(sem) sem.waits[_pid - 1]
#define hang(sem) sem.hang[_pid - 1]
#define n(sem, i) ((sem.next_wakeup + i) % THREADS)

inline P(sem) {
  waits(sem) = true;
  d_step {
    sem.open && hang(sem) ->
    sem.open = false;
    waits(sem) = false;
    all(sem, CLOSED);
  };
}

inline V(sem) {
  d_step {
    round_robin_flag = false;
    round_robin_loop = 0;
    do
    :: round_robin_loop < THREADS ->
      if :: sem.waits[n(sem, round_robin_loop)] ->
        sem.hang[n(sem, round_robin_loop)] = 1;
        sem.next_wakeup = succ(n(sem, round_robin_loop));
        round_robin_flag = true;
        break
      :: else ->
        round_robin_loop = succ(round_robin_loop)
      fi
    :: round_robin_loop >= THREADS -> break
    od;
    if :: !round_robin_flag ->
      all(sem, OPEN)
    :: else -> skip
    fi;
    sem.open = true
  }
}

#endif  // SEMAPHORE_ROUND_ROBIN
