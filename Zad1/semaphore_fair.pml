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
    round_robin_loop = succ(sem.next_wakeup);
    do
    :: round_robin_loop != sem.next_wakeup ->
      if :: sem.waits[round_robin_loop] ->
        sem.hang[round_robin_loop] = 1;
        sem.next_wakeup = succ(round_robin_loop);
        round_robin_loop = succ(round_robin_loop);
        round_robin_flag = true
      :: else ->
        round_robin_loop = succ(round_robin_loop)
      fi
    :: round_robin_loop == sem.next_wakeup -> break
    od;
    if :: !round_robin_flag ->
      all(sem, OPEN)
    :: else -> skip fi;
    sem.open = true;
    sem.next_wakeup = succ(sem.next_wakeup)
  }
}

#endif  // SEMAPHORE_ROUND_ROBIN
