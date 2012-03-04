#define A_SPEED 1
#define B_SPEED 2
#define C_SPEED 4
#define D_SPEED 8

bool a = 0;
bool b = 0;
bool c = 0;
bool d = 0;
bool light = 0;
byte time = 0;

#define ONE_MINER(_who, _duration, _side) active proctype _who ## _MINER_ ## _side () { \
    d_step { \
        (_who ^ _side) && (light ^ _side); \
        time = time + _duration; \
        _who = _side; \
        light = _side \
    } \
}

ONE_MINER(a, A_SPEED, 0)
ONE_MINER(a, A_SPEED, 1)
ONE_MINER(b, B_SPEED, 0)
ONE_MINER(b, B_SPEED, 1)
ONE_MINER(c, C_SPEED, 0)
ONE_MINER(c, C_SPEED, 1)
ONE_MINER(d, D_SPEED, 0)
ONE_MINER(d, D_SPEED, 1)

#define TWO_MINERS(_who1, _who2, _min_duration, _side) active proctype _who1 ## _WITH_ ## _who2 ## _side () { \
    d_step { \
        (_who1 ^ _side) && (_who2 ^ _side) && (light ^ _side); \
        time = time + _min_duration; \
        _who1 = _side; \
        _who2 = _side; \
        light = _side; \
    } \
}

TWO_MINERS(a, b, B_SPEED, 0)
TWO_MINERS(a, b, B_SPEED, 1)
TWO_MINERS(a, c, C_SPEED, 0)
TWO_MINERS(a, c, C_SPEED, 1)
TWO_MINERS(a, d, D_SPEED, 0)
TWO_MINERS(a, d, D_SPEED, 1)
TWO_MINERS(b, c, C_SPEED, 0)
TWO_MINERS(b, c, C_SPEED, 1)
TWO_MINERS(b, d, D_SPEED, 0)
TWO_MINERS(b, d, D_SPEED, 1)
TWO_MINERS(c, d, D_SPEED, 0)
TWO_MINERS(c, d, D_SPEED, 1)

ltl formula {
    !<>(a && b && c && d && (time <= 15))
}
