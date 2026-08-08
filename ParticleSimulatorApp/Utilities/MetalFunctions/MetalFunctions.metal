class RNG {
private:
    uint state;
public:
    // Initialize using the thread id and a CPU-passed seed
    RNG(uint id, uint seed) {
        state = id ^ seed;
    }
    
    // Returns a random uint
    uint nextUint() {
        state = state * 1664525u + 1013904223u;
        return state;
    }
    
    // Returns a float between 0.0 and 1.0
    float nextFloat() {
        return float(nextUint()) / 4294967295.0f;
    }
};
