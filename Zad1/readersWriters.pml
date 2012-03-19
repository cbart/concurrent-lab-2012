#define READERS 2
#define WRITERS 2

bit mutex = 1;
bit writers = 1;
bit readers = 0;
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
    if :: (in_reading == 0) ->
      V(mutex);
      V(writers)
    :: else ->
      V(mutex)
    fi
  od
}

active [WRITERS] proctype Writer() {
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
    if :: (waiting_to_read > 0) ->
      V(readers)
    :: else ->
      V(mutex);
      V(writers)
    fi
  od
}
