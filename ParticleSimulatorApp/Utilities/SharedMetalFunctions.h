/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Utility types to bridge packed Metal types (`packed_float3`, `packed_float2`, `packed_half3`)
  from Metal Shading Language to Swift.
*/

#pragma once

#ifndef __METAL_VERSION__

#include <metal/metal.h>
#include <simd/simd.h>

typedef MTLPackedFloat3 packed_float3;
typedef simd_float2 packed_float2;
typedef struct { _Float16 x, y, z; } packed_half3;

// TODO: FIX CONVERSION OF PACKED_HALF4 -> HALF4
typedef struct { _Float16 x, y, z, w; } packed_half4;

#endif

// https://stackoverflow.com/questions/60250968/unsupported-architecture-shared-enum-between-metal-and-swift
#ifndef MetalFunctions_h
#define MetalFunctions_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#else

#import <Foundation/Foundation.h>
#endif /* __METAL_VERSION__ */
#endif /* SharedIndizes_h */

typedef NS_ENUM(int32_t, ParticleVisualisationLayer)
{
    normalLayer = 0,
    heatMapLayer = 1,
};
