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
struct ParticleBrushAttributes {
    packed_float3 position;
    packed_float3 polarCoordinate;
    packed_half3 color;
    float curveDistance;
    float size;
    packed_float3 initialPosition;
};

struct ParticleBrushParticle {
    struct ParticleBrushAttributes attributes;
    packed_float3 velocity;
};

struct ParticleVertex {
    struct ParticleBrushAttributes attributes;
    simd_half2 uv;
};

struct ParticleSimulationParams {
    uint32_t particleCount;
    float deltaTime;
    float dragCoefficient;
};
#pragma pack(pop)

//static_assert(sizeof(struct ParticleBrushAttributes) == 28, "ensure packing");
//static_assert(sizeof(struct ParticleBrushParticle) == 62, "ensure packing");
//static_assert(sizeof(struct ParticleVertex) == 40, "ensure packing");
//static_assert(sizeof(struct ParticleSimulationParams) == 12, "ensure packing");
