#include "./MetalFunctions.h"
using namespace metal;

RNG::RNG(uint id, uint seed) {
    state = id ^ seed;
}


// Xor shift algorithm to create random number with range [0, 2^32)
uint RNG::nextIntXORShift(){
    state ^= state << 13;
    state ^= state >> 17;
    state ^= state << 5;
    return state;
}
float RNG::nextFloatPrivate(float lower, float upper) {
    float rnd = float(nextIntXORShift());
    return lower + (rnd / (MAX_UNSIGNED_32_BIT) * ( upper - lower ));
}
// Rand float gen within a certain range [lower, upper]
float RNG::nextFloat(struct RandomBounds bounds) {
    float lower = bounds.lower;
    float upper = bounds.upper;
    return nextFloatPrivate(lower, upper);
}

float RNG::nextFloat(float lower, float upper) {
    return nextFloatPrivate(lower, upper);
}


RandomBounds::RandomBounds(float lower, float upper){
    this->lower = lower;
    this->upper = upper;
}


[[kernel]]
void testMetalRNGFunction(device packed_float4 &params [[buffer(0)]],
                          device packed_float3 &output [[buffer(1)]]){
    float lower = params.x;
    float upper = params.y;
    float id = params.z;
    float seed = params.w;

    RNG rng = RNG(id, seed);
    
    RandomBounds bound = RandomBounds(lower, upper);
    output = float3(rng.nextFloat(bound), rng.nextFloat(bound), rng.nextFloat(bound));
}
