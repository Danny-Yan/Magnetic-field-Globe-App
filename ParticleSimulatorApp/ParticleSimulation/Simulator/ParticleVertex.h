/*
 ParticleVertex.h
 
 Abstract:
 Vertex data for particles which are transferred to metal, written in Metal Shading Language.
 
 Created by: Danny Yan
 */

#pragma once

#include "../../Utilities/MetalPacking.h"
#include <simd/simd.h>

// Vertex attribute data must respect size and alignment requirements in Metal Shading Language.
// See Table 2.4, "Size and alignment of packed vector data types" in the Metal Shading Language Specification.
#pragma pack(push, 4)
struct CoordSpace{
    packed_float3 northVector;
    packed_float3 eastVector;
    packed_float3 verticalVector;
};

struct MagneticField {
    float declination;
    float inclination;
    float horizontalIntensity;
    float totalIntensity;
    packed_float3 components;
};

struct ParticlePointAttributes {
    packed_float3 position;
    packed_float3 polarCoordinate;
    packed_half3 color;
    float curveDistance;
    float size;
    packed_float3 initialPosition;
    struct CoordSpace coordSpace;
    struct MagneticField magField;
};

struct ParticleAttributes {
    struct ParticlePointAttributes attributes;
    packed_float3 velocity;
};

struct ParticleVertex {
    struct ParticlePointAttributes attributes;
    simd_half2 uv;
};

struct ParticleSimulationParams {
    uint32_t particleCount;
    float deltaTime;
};

// Magnetic Model Struct
// Input:
// Longitude, Latitude, Altitude, Time
//
// Output:
// MagneticField
struct MagneticFieldModel {
    // Mean Radius of IAU-66 ellipsoid (km)
    float IAU66_RADIUS;
    float WGS84_A;
    float WGS84_B;
    
    // Max degree of model
    float MAX_DEG;
   
    // Main Model coefficients
    float c[13 * 13];
    // Secular coefficients
    float cd[13 * 13];
    // Time Adjusted coefficients
    float tc[13 * 13];
    // Theta derivative of p(n, m) (unnormalised)
    float dp[13 * 13];
    // Schmidt normalisation factors
    float snorm[169];
    // Sine of longitude
    float sp[13];
    // Cosine of longitude
    float cp[13];
    
    float fn[13];
    float fm[13];
    
    // Associated Legendre polynomials for m = 1
    float pp[13];
    float k[13 * 13];
    
    // Old time and position values
    float otime;
    float oalt;
    float olat;
    float olon;
    
    // Global epoch of the simulation
    float epoch;
    float r;
    float d;
    float ca;
    float sa;
    float ct;
    float st;
};

#pragma pack(pop)

//static_assert(sizeof(struct ParticlePointAttributes) == 28, "ensure packing");
//static_assert(sizeof(struct ParticleAttributes) == 62, "ensure packing");
//static_assert(sizeof(struct ParticleVertex) == 40, "ensure packing");
//static_assert(sizeof(struct ParticleSimulationParams) == 12, "ensure packing");


