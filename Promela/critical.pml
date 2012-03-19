#include "weak.pml"

UP(s);

byte section = 0;

active [3] proctype Q() {
    do
    :: true ->
        before:
        P(s);
        section++;
        critical:
        assert(section == 1);
        section--;
        V(s)
    od
}

ltl liveness {
    [](Q[1]@before -> <>Q[1]@critical)
}
