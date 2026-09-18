//
//  RNGFunctions.h
//  ParticleSimulatorApp
//
//  Created by DY on 4/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
#pragma once

#include <metal_stdlib>

constant float MAX_UNSIGNED_32_BIT = 4294967296.0f; // 2^32

struct RNG{
private:
    uint state;
    
    // Marsaglia's xorshift algorithm to generate uniform random numbers
    uint nextIntXORShift();
    
    // General random float function
    float nextFloatPrivate(float lower, float upper);
    
public:
    RNG(uint id, uint seed);
    
    // Rand float gen within a certain range [lower, upper]
    float nextFloat(struct RandomBounds bounds);
    float nextFloat(float lower, float upper);
    
    // Rand float vector3 gen within a certain range [lower, upper] -> (Creates a box of evenly distributed vectors)
    float3 nextFloat3(struct RandomBounds bounds);
    
    float3 nextFloat3(struct RandomBounds xBounds,
                           struct RandomBounds yBounds,
                           struct RandomBounds zBounds);
    float3 nextFloat3(float lower, float upper);
};

// Ease of use
struct RandomBounds{
    float lower;
    float upper;
    RandomBounds(float lower, float upper);
    RandomBounds(float size);
};
