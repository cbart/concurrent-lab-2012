#define READERS 3
#define WRITERS 3

bit mutex = 1;
bit memory = 1;
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
    if :: ((waiting_to_write > 0) || (in_writing > 0) || (in_reading == 0)) ->
      V(mutex);
      P(memory);
      P(mutex)
    :: else -> skip fi;
    in_reading++;
    V(mutex);

    assert(in_writing == 0);

    P(mutex);
    in_reading--;
    if :: (in_reading == 0) ->
      V(memory)
    :: else -> skip fi;
    V(mutex)
  od
}

active [WRITERS] proctype Writer() {
  do :: skip ->
    P(mutex);
    waiting_to_write++;
    V(mutex);
    P(memory);
    P(mutex);
    waiting_to_write--;
    in_writing++;
    V(mutex);

    assert(in_reading == 0 && in_writing == 1);

    P(mutex);
    in_writing--;
    V(mutex);
    V(memory);
  od
}
