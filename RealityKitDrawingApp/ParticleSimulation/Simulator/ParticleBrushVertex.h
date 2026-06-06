/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Vertex data for the particle brush style, written in Metal Shading Language.
*/

#pragma once

#include "../../Utilities/MetalPacking.h"
#include <simd/simd.h>

// Vertex attribute data must respect size and alignment requirements in Metal Shading Language.
// See Table 2.4, "Size and alignment of packed vector data types" in the Metal Shading Language Specification.
#pragma pack(push, 4)
struct particleBrushAttributes {
    packed_float3 position;
    packed_float3 polarCoordinate;
    packed_half3 color;
    float curveDistance;
    float size;
    packed_float3 initialPosition;
};

struct particleBrushParticle {
    struct particleBrushAttributes attributes;
    packed_float3 velocity;
};

struct particleBrushVertex {
    struct particleBrushAttributes attributes;
    simd_half2 uv;
};

struct particleBrushSimulationParams {
    uint32_t particleCount;
    float deltaTime;
    float dragCoefficient;
};
#pragma pack(pop)

//static_assert(sizeof(struct particleBrushAttributes) == 28, "ensure packing");
//static_assert(sizeof(struct particleBrushParticle) == 62, "ensure packing");
//static_assert(sizeof(struct particleBrushVertex) == 40, "ensure packing");
//static_assert(sizeof(struct particleBrushSimulationParams) == 12, "ensure packing");
