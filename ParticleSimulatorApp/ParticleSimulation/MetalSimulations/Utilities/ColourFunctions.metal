//
//  ColourFunctions.metal
//  ParticleSimulatorApp
//
//  Created by DY on 4/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
#include "../Include/ColourFunctions.h"
#include "../../../Utilities/SharedMetalFunctions.h"

/// Helper function for HSL to RGB conversion
float hslChannelToRGB(float p, float q, float t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1.0 / 6.0) return p + (q - p) * 6 * t;
    if (t < 1.0 / 2.0) return q;
    if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6;
    return p;
}


/// Convert HSL colour -> RGB, seperated channels
float3 hslToRGB(float h, float s, float l){
    float r, g, b;
    
    if (s == 0) {
        r = g = b = l; // achromatic
        
    }else {
        float q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        float p = 2 * l - q;
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

/// Convert HSL colour -> RGB
float3 hslToRGB(float3 hsl){
    return hslToRGB(hsl.x, hsl.y, hsl.z);
}

/// Convert RGB colour -> HSL, seperated channels
///
/// Source - https://stackoverflow.com/a/58426404
/// Posted by Crashalot, modified by community. See post 'Timeline' for change history
/// Retrieved 2026-09-05, License - CC BY-SA 4.0
float3 rgbToHSL(float r, float g, float b) {
    
//    r /= 255;
//    g /= 255;
//    b /= 255;
    
    // Find greatest and smallest channel values
    float cMin = min(r, min(g, b));
    float cMax = max(r, max(g, b));
    float delta = cMax - cMin;
    float h = 0;
    float s = 0;
    float l = 0;

    // Calculate hue
    // No difference
    if (delta == 0) {
        h = 0;
        
        // Red is max
    } else if (cMax == r) {
        h = fmod((g - b) / delta, 6);
        
        // Green is max
    } else if (cMax == g) {
        h = (b - r) / delta + 2;
        
        // Blue is max
    } else {
        h = (r - g) / delta + 4;
    }
    
    h = round(h * 60);

    // Make negative hues positive behind 360°
    if (h < 0){
        h += 360;
    }
    
    // Calculate lightness
    l = (cMax + cMin) / 2;

    // Calculate saturation, avoid division by 0
    s = delta == 0 ? 0 : delta / (1 - abs(2 * l - 1));

    return float3(h, s, l);
}

/// RGB colour -> HSL
float3 rgbToHSL(float3 rgb){
    return rgbToHSL(rgb.x, rgb.y, rgb.z);
}

/// Linear interpolation of single rgb colour channel against speed
float colourSpeedLerpHalf(float speed,
                          float minSpeed,
                          float maxSpeed,
                          float colourMin,
                          float colourMax) {
    return (colourMax - colourMin) * float((speed - minSpeed)/ (maxSpeed - minSpeed)) + colourMin;
}


/// Linear interpolation of rgb colour against speed
float3 colourSpeedLerpHalf3(float speed,
                            float minSpeed,
                            float maxSpeed,
                            float3 colourMin,
                            float3 colourMax){
    float h = colourSpeedLerpHalf(speed, minSpeed, maxSpeed, colourMin[0], colourMax[0]) / 360.0;
    float s = colourSpeedLerpHalf(speed, minSpeed, maxSpeed, colourMin[1], colourMax[1]);
    float l = colourSpeedLerpHalf(speed, minSpeed, maxSpeed, colourMin[2], colourMax[2]);
    
    return float3(h, s, l);
}

/// Convert RGB -> HSL, perform lerp then convert HSL -> RGB
float3 colourLinearisationRGB(float curSpeed, float minSpeed, float maxSpeed, float3 minColour, float3 maxColour) {
    
    float3 minColourHSL = rgbToHSL(minColour);
    float3 maxColourHSL = rgbToHSL(maxColour);

    // Perform linear interpolation
    float speed = max( min( curSpeed, maxSpeed ), minSpeed );
    float3 hsl = colourSpeedLerpHalf3(speed, minSpeed, maxSpeed, minColourHSL, maxColourHSL);
    
    // Convert HSL to RGB
    float3 rgb = hslToRGB(hsl);
    return rgb;
}

/// Colour assigned to normal layer
void normalLayerFunction(thread half3 &colour, constant ParticleSimulationParams &params){
    colour = params.normalLayer.normalColour;
}

/// Colour assigned to heat map layer
void heatMapLayerFunction(thread half3 &colour,
                          constant ParticleSimulationParams &params,
                          thread ParticleAttributes &particle){
    
    // Speed to colour calculation
    float speed = length(particle.velocity);
    float minSpeed = params.heatMapLayer.minSpeed;
    float maxSpeed = params.heatMapLayer.maxSpeed;
    
    // Calc rgb value between a min and max based on it's speed
    float3 minColour = float3(params.heatMapLayer.minColour);
    float3 maxColour = float3(params.heatMapLayer.maxColour);
    float3 rgbColour = colourLinearisationRGB(speed, minSpeed, maxSpeed, minColour, maxColour);
    
////    colour = rgbColour;
//    if ( rgbColour.x != 0 && rgbColour.y != 0 && rgbColour.z != 0){
//        testColour = rgbColour;
//    }
    
    colour = half3(rgbColour);
}

/// Updates colour according to the current layer config
void updateColor(thread ParticleAttributes &particle,
                 constant ParticleSimulationParams &params){

    // Chose colour based on layer
    half3 colour = half3(1.0, 1.0, 0);
    
    switch (params.chosenLayerEnum) {
            
        case normalLayer:
            normalLayerFunction(colour, params);
            break;
            
        case heatMapLayer:
            heatMapLayerFunction(colour, params, particle);
            break;
        default:
            colour = half3(1.0, 0, 1.0);
            break;
    }
    
    particle.attributes.color = packed_half3(colour);
}

[[kernel]]
void testUpdateColour(device ParticleAttributes &particle,
                 constant ParticleSimulationParams &params){
    thread ParticleAttributes p = particle;
    
    updateColor( p, params);
    
    particle = p;
}
