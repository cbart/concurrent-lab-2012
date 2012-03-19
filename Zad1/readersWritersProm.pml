#define READERS 3
#define WRITERS 3

bit reading = false;
bit writing = false;
bit waiting_to_write = false;
byte in_reading = 0;
byte in_writing = 0;

active [READERS] proctype Reader() {
  do :: skip ->
    d_step {
      !writing && !waiting_to_write ->
      reading = true;
      in_reading++
    }
    assert(in_writing == 0);
    if
    :: skip ->  // just leave memory
      d_step {
        in_reading--;
        if :: in_reading == 0 ->
          reading = false
        :: else -> skip fi
      }
    fi
  od
}

active [WRITERS] proctype Writer() {
  do :: skip ->
    waiting_to_write = true;
    d_step {
      !reading && !writing ->
      writing = true;
      waiting_to_write = false;
      in_writing++
    }
    assert(in_reading == 0);
    assert(in_writing == 1);
    if
    :: skip ->  // just leave memory
      d_step {
        in_writing--;
        writing = false;
      }
    :: skip ->  // read yourself something
      d_step {
        in_writing--;
        in_reading++;
        writing = false;
        reading = true;
      }
      assert(in_writing == 0);
      d_step {
        in_reading--;
        if :: in_reading == 0 ->
          reading = false
        :: else -> skip fi
      }
    fi
  od
}
