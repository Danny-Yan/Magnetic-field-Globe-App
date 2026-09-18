/*
 ParticleVertex.h
 
 Abstract:
 Vertex data for particles which are transferred to metal, written in Metal Shading Language.
 
 Created by: Danny Yan
 */

#pragma once

#include "../../Utilities/SharedMetalFunctions.h"
#include <simd/simd.h>

// TODO: FIGURE OUT HOW TO MAKE THIS DYNAMIC (DUNNO IF THIS IS POSSIBLE)
#define MAX_TRAIL_LENGTH 20

// Vertex attribute data must respect size and alignment requirements in Metal Shading Language.
// See Table 2.4, "Size and alignment of packed vector data types" in the Metal Shading Language Specification.
#pragma pack(push, 4)

/// Coordinate Space of a particle in the magnetic field
struct CoordSpace{
    packed_float3 northVector;
    packed_float3 eastVector;
    packed_float3 verticalVector;
};

/// Output Magnetic Field
struct MagneticField {
//    float declination;
//    float inclination;
//    float horizontalIntensity;
//    float totalIntensity;
    packed_float3 components;
};

/// Seperated particle attributes for rendering
struct ParticlePointAttributes {
    packed_float3 position;
    packed_float3 polarCoordinate;
    packed_half3 color;
    float size;
};

/// Trail buffers that each particle stores
struct ParticleTrailBuffers {
    packed_float3 trailPositions[MAX_TRAIL_LENGTH];
    packed_half3 trailColor[MAX_TRAIL_LENGTH];
    uint trailCurrentIndex;
};

/// Individual particle attributes
struct ParticleAttributes {
    struct ParticlePointAttributes attributes;
    struct ParticleTrailBuffers trailBuffers;
    packed_float3 velocity;
    
    // TODO: Re implement particle attributes that are non necessary for rendering
    packed_float3 centre;
    struct CoordSpace coordSpace;
    float age;
    uint particleIdx;
};

///Particle vertex which is rendered to the low level mesh
struct ParticleVertex {
    struct ParticlePointAttributes attributes;
    simd_half2 uv;
};

/// Seperated trail attributes for rendering
struct ParticleTrailAttributes {
    packed_float3 position;
    packed_half3 color;
    float size;
};

/// Individual trail vertex that is rendered to the low level mesh; each trail is created
/// from an array of [ParticleTrailVertex] joined together as a single connected line segment
struct ParticleTrailVertex {
    struct ParticleTrailAttributes attributes;
};

/// Normal Colour Layer
struct SimulationNormalLayerParams {
    packed_half3 normalColour;
};

/// Heat Map Colour Layer
struct SimulationHeatMapLayerParams {
    float minSpeed;
    float maxSpeed;
    packed_half3 minColour;
    packed_half3 maxColour;
};

/// Shared simulation settings that are used to interface between the UI and metal shader
struct ParticleSimulationParams {
    uint32_t particleCount;
    float particleSize;
    packed_float3 southPoleSpawnCentre;
    packed_float3 particleBoundingBox;
    float particleLifeSpan;
    float deltaTime;
    float forceMultiplier;
    
    float yearFraction;
    
    ParticleVisualisationLayer chosenLayerEnum;
    
    struct SimulationNormalLayerParams normalLayer;
    struct SimulationHeatMapLayerParams heatMapLayer;
};

/// Hack for allowing buffer transfer between initialisation phase
/// and simulation phase
struct SchmidtScalingWrapper {
    float inner[169];
};

/// Magnetic Model that for storing variables
/// initialised in the initialisation phase and who are shared amongst
/// all particles
struct MagneticFieldModel {
    
    // Mean Radius of IAU-66 ellipsoid (km)
    float IAU66_RADIUS;
    float WGS84_A;
    float WGS84_B;
    
    // Max degree of model
    float MAX_DEG;
    
    // Global epoch of the simulation
    float epoch;
   
    // Time of simulation as a fraction
    float yearFraction;

    // Main Model coefficients
    float c[169];
    // Secular coefficients
    float cd[169];
    
    float fn[13];
    float fm[13];
    
    struct SchmidtScalingWrapper snorm;
    
    // Associated Legendre polynomials for m = 1
    float k[169];
};

/// Local variables used per field calculation
struct MagneticFieldPerParticleVariables {
    float ct;
    float st;
    float r;
    float d;
    float ca;
    float sa;
    
    float otime;
    float oalt;
    float olat;
    float olon;
    
    // Time adjusted coefficients
    float tc[169];
    // Theta derivative of p(n, m) (unnormalised)
    float dp[169];
    // Schmidt normalisation factors
    struct SchmidtScalingWrapper snorm;
    // Sine of longitude
    float sp[13];
    // Cosine of longitude
    float cp[13];
    
    float pp[13];
};

#pragma pack(pop)

//static_assert(sizeof(struct ParticlePointAttributes) == 28, "ensure packing");
//static_assert(sizeof(struct ParticleAttributes) == 62, "ensure packing");
//static_assert(sizeof(struct ParticleVertex) == 40, "ensure packing");
//static_assert(sizeof(struct ParticleSimulationParams) == 12, "ensure packing");


