//
//  MetalFunctions.h
//  ParticleSimulatorApp
//
//  Created by DY on 3/8/2026.
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
    float3 nextFloat3(float lower, float upper);
};

// Ease of use
struct RandomBounds{
    float lower;
    float upper;
    RandomBounds(float lower, float upper);
};

bool vectorEquals(float3 a, float3 b);

//half hslChannelToRGB(half p, half q, half t);
//
//half3 hslToRGB(half h, half s, half l);
//
//half colourSpeedLerpHalf(half speed, half color_max_speed, half color_min, half color_max);

half3 colourLinearisationHSLToRGB(float curSpeed, half maxSpeed, half3 minColour, half3 maxColour);

