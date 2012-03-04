#define PHILOSOPHERS 30

byte forkUp[PHILOSOPHERS] = false;

active [PHILOSOPHERS] proctype Philosopher() {
    byte left = _pid;
    byte right = (_pid + 1) % PHILOSOPHERS;
    do
    :: true ->
        atomic {  // Pick up left fork.
            !forkUp[left];
            forkUp[left] = true;
        };
        atomic {  // Pick up right fork.
            !forkUp[right];
            forkUp[right] = true;
        };
        // Eating.
        forkUp[right] = false;  // Put right fork down.
        forkUp[left] = false
    od
}
