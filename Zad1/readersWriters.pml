#define READERS 1
#define WRITERS 1

bit mutex = true;
bit memory = true;
byte wt_readers = 0;
byte wt_writers = 0;
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
    wt_readers++;
    if :: (wt_writers > 0 || in_readers == 0) ->
      v(mutex);
      p(memory)
    :: else -> skip fi;
    in_readers++;
    v(mutex);

    assert(in_writers == 0);

    p(mutex);
    in_readers--;
    if :: in_readers == 0 ->
      v(memory)
    :: else -> skip fi;
    v(mutex)
  od
}

active [WRITERS] proctype Writer() {
  do :: skip ->
    p(mutex);
    wt_writers++;
    v(mutex);
    p(memory);
    p(mutex);
    wt_writers--;
    in_writers++;
    v(mutex);

    assert(in_writers == 1);
    assert(in_readers == 0);

    p(mutex);
    in_writers--;
    if :: skip ->
      if :: wt_readers == 0 ->
        v(mutex)
      :: else -> skip fi;
      v(memory)
    fi
  od
}
