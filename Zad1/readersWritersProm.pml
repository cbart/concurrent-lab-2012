#define READERS 1
#define WRITERS 2
#define READER_LTL_THREAD 0
#define WRITER_LTL_THREAD 2

bit waiting_to_write = false;
byte in_reading = 0;
byte in_writing = 0;
byte readers_waiting_to_write = 0;

active [READERS] proctype Reader() {
  do :: skip ->
    waiting:
    d_step {                                    // atomically,
      ((in_writing == 0)                        //     if no one is writing,
        && !waiting_to_write                    //             no one waits to write,
        && (readers_waiting_to_write == 0)) ->  //             and no priviledged reader->writer waits to write
      in_reading++                              //         then number of agents reading increases
    }
    reading:
    assert(in_writing == 0);                    // !! READING
    if
    :: skip ->                                  // if I nondeterministically decide not to become a WRITER
      in_reading--;                             //     then there is one working reader less
    :: skip ->                                  // if I nondeterministically decide to become a WRITER
      wants_write:
      atomic {
        in_reading--;
        if :: in_reading == 0 ->                //     if I'm last reader out
          in_writing++;                         //         then I can start writing
          goto _writing                         //         right away
        :: else ->
          readers_waiting_to_write++            //     otherwise if there are readers left
        fi
      }
      d_step {                                  // I'm waiting
        ((in_reading == 0)                      //         until no one will be reading
          && (in_writing == 0)) ->              //         and no one will be writing
        readers_waiting_to_write--;             //     and after that I'm not waiting any more
        in_writing++;                           //     and I am writing
      }
      _writing:
      assert(in_reading == 0);                  // !! WRITING
      assert(in_writing == 1);                  // !!
      in_writing--;
    fi
  od
}

active [WRITERS] proctype Writer() {
  do :: skip ->
    waiting:
    waiting_to_write = true;                    // I am waiting to write
    d_step {                                    // atomically,
      ((in_reading == 0)                        //     if no one is reading,
        && (in_writing == 0)                    //             no one is writing,
        && (readers_waiting_to_write == 0)) ->  //             and no privileged reader->writer waits to write
      waiting_to_write = false;                 //         then I no more wait to write
      in_writing++                              //         and number of agents writing increases
    }
    writing:
    assert(in_reading == 0);                    // !! WRITING
    assert(in_writing == 1);                    // !!
    if
    :: skip ->                                  // if I nondeterministically decide not to become a READER
      in_writing--;                             //     then there is one less person writing
    :: skip ->                                  // if I nondeterministrically decide to become a READER
      wants_read:
      d_step {
        in_writing--;                           //     then there is one less person writing
        in_reading++;                           //     and one more reading
      }
      reading:
      assert(in_writing == 0);                  // !! READING
      in_reading--;
    fi
  od
}


#include "ltl.pml"
