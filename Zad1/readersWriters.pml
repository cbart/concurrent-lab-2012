#define READERS 1
#define WRITERS 1

bit mutex = true;
bit memory = true;
byte readers = 0;
byte writers = 0;
byte in_readers = 0;
byte in_writers = 0;

inline p(s) {
  d_step {
    s;
    s = false
  }
}

inline v(s) {
  s = true
}

active [READERS] proctype Reader() {
  do :: skip ->
    p(mutex);
    if :: (writers > 0 || readers == 0) ->
      v(mutex);
      p(memory);
      p(mutex)
    :: else -> skip fi;
    readers++;
    v(mutex);

    in_readers++;
    assert(in_writers == 0);
    in_readers--;

    p(mutex);
    readers--;
    if :: readers == 0 ->
      v(memory)
    :: else -> skip fi;
    v(mutex)
  od
}

active [WRITERS] proctype Writer() {
  do :: skip ->
    p(mutex);
    writers++;
    v(mutex);
    p(memory);

    in_writers++;
    assert(in_writers == 1);
    assert(in_readers == 0);
    in_writers--;

    p(mutex);
    writers--;
    v(mutex);
    v(memory)
  od
}
