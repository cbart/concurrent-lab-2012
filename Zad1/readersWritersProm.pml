#define READERS 2
#define WRITERS 2

bit reading = false;
bit writing = false;
bit waiting_to_write = false;
byte in_reading = 0;
byte in_writing = 0;
byte readers_waiting_to_write = 0;

active [READERS] proctype Reader() {
  do :: skip ->
    d_step {                                    // Atomically
      (!writing                                 //     if no one is writing,
        && !waiting_to_write                    //             no one waits to write,
        && (readers_waiting_to_write == 0)) ->  //             and no priviledged reader->writer waits to write
      reading = true;                           //         then now we are reading
      in_reading++                              //         and number of agents reading increases
    }
    assert(in_writing == 0);                    // !! READING
    if
    :: skip ->                                  // if I nondeterministically decide not to become a WRITER
      d_step {
        in_reading--;                           //     then there is one working reader less
        if :: in_reading == 0 ->                //     and if there are no more readers (I was the last)
          reading = false                       //         then no one is reading anymore
        :: else -> skip fi
      }
    :: skip ->                                  // if I nondeterministically decide to become a WRITER
      atomic {
        in_reading--;
        if :: in_reading == 0 ->                //     if I'm last reader out
          reading = false;                      //         then I stop reading
          writing = true;                       //         and I can start writing
          in_writing++;
          goto _writing                         //         right away
        :: else ->
          readers_waiting_to_write++;           //     otherwise if there are readers left
        fi
      }
      d_step {
        !reading && !writing ->                 //         I'm waiting until readers finish and reader-writers finish
        readers_waiting_to_write--;             //         And after that I'm not waiting any more
        writing = true;                         //         And I am writing
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
    d_step {                                    // Atomically
      (!reading                                 //     if no one is reading,
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
        reading = true;                         //     and I am reading
      }
      assert(in_writing == 0);                  // !! READING
      d_step {
        in_reading--;
        if :: in_reading == 0 ->
          reading = false
        :: else -> skip fi
      }
    fi
  od
}
