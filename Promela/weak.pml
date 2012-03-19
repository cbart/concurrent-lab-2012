#define UP(ident) bool left_hang_ ## ident = true;\
byte waits_at_left ## ident = 0;\
byte waits_at_right ## ident = 0;\
byte left_ ## ident = 1;\
byte right_ ## ident = 0

#define P(semaphore) atomic {\
    if\
    :: left_hang_ ## semaphore ->\
        waits_at_left ## semaphore ++;\
        left_ ## semaphore > 0;\
        left_ ## semaphore --;\
        waits_at_left ## semaphore --;\
    :: else ->\
        waits_at_right ## semaphore ++;\
        right_ ## semaphore > 0;\
        right_ ## semaphore --;\
        waits_at_right ## semaphore --;\
    fi\
}\

#define V(semaphore) d_step {\
    if\
    :: (left_hang_ ## semaphore) && (waits_at_right ## semaphore > 0) ->\
        right_ ## semaphore ++;\
    :: (left_hang_ ## semaphore) && (waits_at_right ## semaphore == 0) ->\
        right_ ## semaphore ++;\
        left_hang_ ## semaphore = false;\
    :: !(left_hang_ ## semaphore) && (waits_at_left ## semaphore > 0) ->\
        left_ ## semaphore ++;\
    :: !(left_hang_ ## semaphore) && (waits_at_left ## semaphore == 0) ->\
        left_ ## semaphore ++;\
        left_hang_ ## semaphore = true;\
    fi\
}
