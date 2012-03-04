byte number[2] = 0;
byte inCritical = 0;

active [2] proctype Lamport() {
    byte temp;
    do
    :: true ->
        number[_pid] = 1;
        temp = number[1 - _pid];
        number[_pid] = temp + 1;
        !((number[_pid] > number[1 - _pid]) && number[1 - _pid]);
        inCritical++;
        assert(number[_pid] < 254);
        assert(inCritical == 1);
        inCritical--;
        number[_pid] = 0;
    od
}
