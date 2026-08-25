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

bool vectorEquals(float3 a, float3 b){
    return (a.x == b.x) && (a.y == b.y) && (a.z == b.z);
}

// Helper function for HSL to RGB conversion
half hslChannelToRGB(half p, half q, half t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1.0 / 6.0) return p + (q - p) * 6 * t;
    if (t < 1.0 / 2.0) return q;
    if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6;
    return p;
}

half3 hslToRGB(half h, half s, half l){
    half r, g, b;
    
    if (s == 0) {
        r = g = b = l; // achromatic
    }
    else {
        half q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        half p = 2 * l - q;
        r = hslChannelToRGB(p, q, h + 1.0 / 3.0);
        g = hslChannelToRGB(p, q, h);
        b = hslChannelToRGB(p, q, h - 1.0 / 3.0);
    }
    
    return {
        r,
        g,
        b
    };
}

// Linear interpolation of colour against speed
half colourSpeedLerpHalf(half speed, half color_max_speed, half color_min, half color_max) {
    return (color_max - color_min) * (half)(speed / color_max_speed) + color_min;
}

// Linear interpolation of colour against speed using HSL
half3 colourLinearisationHSLToRGB(float curSpeed, half maxSpeed, half3 minColour, half3 maxColour) {
    half speed = half(curSpeed);
    half h = colourSpeedLerpHalf(speed, maxSpeed, minColour[0], maxColour[0]) / 360.0f;
    half s = colourSpeedLerpHalf(speed, maxSpeed, minColour[1], maxColour[1]);
    half l = colourSpeedLerpHalf(speed, maxSpeed, minColour[2], maxColour[2]);
    // Convert HSL to RGB
    half3 rgb = hslToRGB(h, s, l);
    //printf("Speed: %f, H: %f, S: %f, L: %f, R: %d, G: %d, B: %d\n", speed, h, s, l, rgb[0], rgb[1], rgb[2]);
    return rgb;
}
