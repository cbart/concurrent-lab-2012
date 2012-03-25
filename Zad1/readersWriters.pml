#define READERS 2
#define WRITERS 2

#ifdef DIJKSTRA
#include "semaphore_dijkstra.pml"
#endif

sem_t mutex;
sem_t writers;
sem_t readers;
sem_t readers_turned_to_writers;
byte waiting_to_read = 0;
byte waiting_to_write = 0;
byte readers_waiting_to_write = 0;
byte in_reading = 0;
byte in_writing = 0;

init {
  byte proc = 0;
  atomic {
    INIT_SEM(mutex, OPEN);
    INIT_SEM(writers, OPEN);
    INIT_SEM(readers, CLOSED);
    INIT_SEM(readers_turned_to_writers, CLOSED);
    do
    :: proc < READERS -> run Reader(); proc++
    :: else -> break
    od;
    proc = 0;
    do
    :: proc < WRITERS -> run Writer(); proc++
    :: else -> break
    od
  }
}

proctype Reader() {
  do :: skip ->
    P(mutex);
    waiting_to_read++;
    V(mutex);
    P(readers);  // dziedziczenie muteksa
    waiting_to_read--;
    in_reading++;
    if :: (waiting_to_read > 0) && (waiting_to_write == 0) ->
      V(readers)
    :: else ->
      V(mutex)
    fi;

    assert(in_writing == 0);

    P(mutex);
    in_reading--;
    if
    :: skip ->
      if :: (in_reading == 0) ->
        if :: (readers_waiting_to_write > 0) ->
          V(readers_turned_to_writers)
        :: else ->
          V(mutex);
          V(writers)
        fi
      :: else ->
        V(mutex)
      fi
    :: skip ->
      if :: (in_reading == 0) ->
        in_writing++;
        V(mutex);
        goto _writing
      :: else ->
        readers_waiting_to_write++;
        V(mutex)
      fi;

      P(readers_turned_to_writers);
      readers_waiting_to_write--;
      in_writing++;
      V(mutex);

      _writing:
      assert(in_reading == 0);
      assert(in_writing == 1);

      P(mutex);
      in_writing--;
      if :: (readers_waiting_to_write > 0) ->
        V(readers_turned_to_writers)
      :: !(readers_waiting_to_write > 0) && (waiting_to_read > 0) ->
        V(readers)
      :: else ->
        V(mutex);
        V(writers)
      fi
    fi
  od
}

proctype Writer() {
  do :: skip ->
    P(mutex);
    waiting_to_write++;
    V(mutex);
    P(writers);
    P(mutex);
    waiting_to_write--;
    in_writing++;
    V(mutex);

    assert(in_reading == 0);
    assert(in_writing == 1);

    P(mutex);
    in_writing--;
    if
    :: skip ->
      if :: (waiting_to_read > 0) ->
        V(readers)
      :: else ->
        V(mutex);
        V(writers)
      fi
    :: skip ->
      in_reading++;
      if :: (waiting_to_read > 0) ->
        V(readers)
      :: else ->
        V(mutex)
      fi;

      assert(in_writing == 0);

      P(mutex);
      in_reading--;
      if :: (in_reading == 0) ->
        V(mutex);
        V(writers)
      :: else ->
        V(mutex)
      fi
    fi
  od
}
