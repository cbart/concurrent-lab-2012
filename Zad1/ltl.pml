#ifdef READER_WILL_READ

#define reader_waits Reader[READER_LTL_THREAD]@waiting
#define reader_reads Reader[READER_LTL_THREAD]@reading

ltl reader_will_read {
  [](reader_waits -> <>reader_reads)
}

#endif  // READER_WILL_READ


#ifdef WRITER_WILL_WRITE

#define writer_waits Writer[WRITER_LTL_THREAD]@waiting
#define writer_writes Writer[WRITER_LTL_THREAD]@writing

ltl writer_will_write {
  [](writer_waits -> <>writer_writes)
}

#endif  // WRITER_WILL_WRITE


#ifdef WRITER_WILL_READ

#define writer_wants_read Writer[WRITER_LTL_THREAD]@wants_read
#define writer_reads Writer[WRITER_LTL_THREAD]@reading

ltl writer_will_read {
  [](writer_wants_read -> <>writer_reads)
}

#endif  // WRITER_WILL_READ


#ifdef READER_WILL_WRITE

#define reader_wants_read Reader[READER_LTL_THREAD]@wants_write
#define reader_writes Reader[READER_LTL_THREAD]@_writing

ltl reader_will_write {
  [](reader_wants_read -> <>reader_writes)
}

#endif
