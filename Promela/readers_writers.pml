#define SEM bit
#define OPEN 1
#define P(sem) atomic { sem > 0; sem-- }
#define V(sem) atomic { sem++ }
#define READERS 4
#define WRITERS 2

byte readCount = 0;
byte writeCount = 0;

SEM mutex1 = OPEN;
SEM mutex2 = OPEN;
SEM mutex3 = OPEN;
SEM w = OPEN;
SEM r = OPEN;

active [READERS] proctype Reader() {
    P(mutex3);
        P(r);
            P(mutex1);
                readCount++;
                if :: readCount == 1 -> P(w) :: else -> fi;
            V(mutex1);
        V(r);
    V(mutex3);

    // READING IS DONE
    assert(writeCount == 0);

    P(mutex1);
        readCount--;
        if :: readCount == 0 -> V(w) :: else -> fi;
    V(mutex1)
};

active [WRITERS] proctype Writer() {
    P(mutex2);
        writeCount++;
        if :: writeCount == 0 -> V(w) :: else -> fi;
    V(mutex2);

    P(w);
    // WRITING IS PERFORMED
    assert(readCount == 0);
    V(w);

    P(mutex2);
        writeCount--;
        if :: writeCount == 0 -> V(r) :: else -> fi;
    V(mutex2)
}
