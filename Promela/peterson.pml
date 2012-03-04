byte inCritical = 0;
bool wants[2] = false;
bool who = 0;

active [2] proctype P() {
    do
    :: true ->
        do
        :: true -> break
        :: true -> skip
        od;
    after_own:
        wants[_pid] = true;
        who = _pid;
        !(wants[1 - _pid] && (who == _pid));
        inCritical++;
    critical:
        assert(inCritical == 1);
        inCritical--;
        wants[_pid] = false
    od
}

ltl formula {
    [](P[0]@after_own -> <>P[0]@critical)
}
