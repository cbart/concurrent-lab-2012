#ifndef SEMAPHORE_STRONG
#define SEMAPHORE_STRONG

#include "queue.pml"

typedef sem_t {
  bit closed;
  mk_queue(queue, THREADS, pid);
};

#define OPEN 0
#define CLOSED 1

#define INIT_SEM(sem, value) sem.closed = value

chan cont = [0] of {pid};
#define processSleep() cont?eval(_pid)
#define processWake(pid) cont!pid

inline P(sem) {
  atomic {
    if :: sem.closed ->
      enqueue(sem.queue, _pid);
      processSleep()
    :: else -> skip fi;
    sem.closed = true;
  }
}

inline V(sem) {
  pid p;
  atomic {
    if :: nempty(sem.queue) ->
      dequeue(sem.queue, p);
      processWake(p)
    :: empty(sem.queue) ->
      sem.closed = false;
    fi
  }
}

#endif  // SEMAPHORE_STRONG
