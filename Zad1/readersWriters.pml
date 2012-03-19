#define READERS 2
#define WRITERS 2

bit mutex = 1;
bit exclusive = 1;
bit shared = 0;
byte waiting_to_read = 0;
byte waiting_to_write = 0;
byte in_reading = 0;
byte in_writing = 0;

inline P(s) {
  d_step {
    s;
    s = false
  }
}

inline V(s) {
  s = true
}

active [READERS] proctype Reader() {
  do :: skip ->
    P(mutex);
    if
    :: (in_writing == 0) || (waiting_to_write == 0) || (in_reading == 0) ->
      waiting_to_read++;
      if :: (in_reading == 0) && (waiting_to_read == 1) ->
        V(mutex);
        P(exclusive);
        P(mutex)
      :: else ->
        V(mutex);
        P(shared)
      fi;
      waiting_to_read--;
    :: else -> skip fi;
    in_reading++;
    if :: (waiting_to_read > 0) && (waiting_to_write == 0) ->
      V(shared)
    :: else ->
      V(mutex)
    fi;

    assert(in_writing == 0);

    P(mutex);
    in_reading--;
    if :: (in_reading == 0) ->
      V(exclusive)
    :: else -> skip fi;
    V(mutex)
  od
}

active [WRITERS] proctype Writer() {
  do :: skip ->
    P(mutex);
    waiting_to_write++;
    V(mutex);
    P(exclusive);
    P(mutex);
    waiting_to_write--;
    in_writing++;
    V(mutex);

    assert(in_reading == 0 && in_writing == 1);

    P(mutex);
    in_writing--;
    V(mutex);
    V(exclusive);
  od
}
