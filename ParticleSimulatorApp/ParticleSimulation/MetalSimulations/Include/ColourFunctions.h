//
//  ColourFunctions.h
//  ParticleSimulatorApp
//
//  Created by DY on 4/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

#pragma once
#include <metal_stdlib>

#include "../../Simulator/ParticleVertex.h"
//#include "../../../Utilities/SharedMetalFunctions.h"

using namespace metal;

//class ColourAllocator {
//private:
//    
//    // Helper function for HSL to RGB conversion
//    half hslChannelToRGB(half p, half q, half t);
//    
//    // Conversion functions
//    half3 hslToRGB(half h, half s, half l);
//    half3 hslToRGB(half3 hsl);
//
//    half3 rgbToHSL(half r, half g, half b);
//    half3 rgbToHSL(half3 rgb);
//    
//    // Linear interpolation of colour against speed
//    half colourSpeedLerpHalf(half speed, half color_max_speed, half color_min, half color_max);
//    half3 colourSpeedLerpHalf3(half speed,
//                               half color_max_speed,
//                               half3 color_min,
//                               half3 color_max);
//    
//    /// Convert RGB -> HSL, perform lerp then convert HSL -> RGB
//    half3 colourLinearisationRGB(float curSpeed, half maxSpeed, half3 minColour, half3 maxColour);
//public:
//    // Colour Layers
//    void normalLayerFunction(thread half3 &colour, constant ParticleSimulationParams &params);
//    void heatMapLayerFunction(thread half3 &colour,
//                              constant ParticleSimulationParams &params,
//                              thread ParticleAttributes &particle);
//};


void updateColor(thread ParticleAttributes &particle, constant ParticleSimulationParams &params);
