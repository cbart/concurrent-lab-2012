#define UP(ident) bool ident = true

inline P(semaphore) {
    d_step {
        semaphore;
        semaphore = false
    }
}

inline V(semaphore) {
    d_step {
        assert(!semaphore);
        semaphore = true
    }
}
