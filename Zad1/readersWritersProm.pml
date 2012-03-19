#define READERS 3
#define WRITERS 3

bit writing = false;  // is an
bit waiting_to_write = false;
byte in_reading = 0;
byte in_writing = 0;
byte readers_waiting_to_write = 0;

active [READERS] proctype Reader() {
  do :: skip ->
    d_step {                                    // atomically,
      (!writing                                 //     if no one is writing,
        && !waiting_to_write                    //             no one waits to write,
        && (readers_waiting_to_write == 0)) ->  //             and no priviledged reader->writer waits to write
      in_reading++                              //         then number of agents reading increases
    }
    assert(in_writing == 0);                    // !! READING
    if
    :: skip ->                                  // if I nondeterministically decide not to become a WRITER
      in_reading--;                             //     then there is one working reader less
    :: skip ->                                  // if I nondeterministically decide to become a WRITER
      atomic {
        in_reading--;
        if :: in_reading == 0 ->                //     if I'm last reader out
          writing = true;                       //         then I can start writing
          in_writing++;
          goto _writing                         //         right away
        :: else ->
          readers_waiting_to_write++;           //     otherwise if there are readers left
        fi
      }
      d_step {                                  // I'm waiting
        ((in_reading == 0)                      //         until no one will be reading
          && !writing) ->                       //         and no one will be writing
        readers_waiting_to_write--;             //     and after that I'm not waiting any more
        writing = true;                         //     and I am writing
        in_writing++;
      }
      _writing:
      assert(in_reading == 0);                  // !! WRITING
      assert(in_writing == 1);                  // !!
      d_step {
        in_writing--;
        writing = false;
        assert(in_writing == 0)
      }
    fi
  od
}

active [WRITERS] proctype Writer() {
  do :: skip ->
    waiting_to_write = true;                    // I am waiting to write
    d_step {                                    // atomically,
      ((in_reading == 0)                        //     if no one is reading,
        && !writing                             //             no one is writing,
        && (readers_waiting_to_write == 0)) ->  //             and no privileged reader->writer waits to write
      writing = true;                           //         then I am writing
      waiting_to_write = false;                 //         and I no more wait to write
      in_writing++                              //         and number of agents writing increases
    }
    assert(in_reading == 0);                    // !! WRITING
    assert(in_writing == 1);                    // !!
    if
    :: skip ->                                  // if I nondeterministically decide not to become a READER
      d_step {
        in_writing--;                           //     then there is one less person writing
        writing = false;                        //     and there is no one writing left
        assert(in_writing == 0)                 //     assuming invariant [](in_writing <= 1) holds
      }
    :: skip ->                                  // if I nondeterministrically decide to become a READER
      d_step {
        in_writing--;                           //     then there is one less person writing
        in_reading++;                           //     and one more reading
        writing = false;                        //     no one is writing
        assert(in_writing == 0);                //     assuming invariant [](in_writing <= 1) holds
      }
      assert(in_writing == 0);                  // !! READING
      in_reading--;
    fi
  od
}
