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

#endif // __METAL_VERSION__
