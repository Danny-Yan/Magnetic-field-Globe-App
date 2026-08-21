//
//  GeomagneticFieldTesting.metal
//  ParticleSimulatorApp
//
//  Created by DY on 13/8/2026.
//  Copyright © 2026 Apple. All rights reserved.
//


#include "./GeomagneticFieldSimulation/GeomagneticFieldSimulation.h"

#include <metal_stdlib>
#include "../Simulator/ParticleVertex.h"
#include "../../Utilities/MetalFunctions/MetalFunctions.h"
#define PI 3.14159265358979323846

using namespace metal;

/// Test magnetic field calculation
[[kernel]]
void testCalculateMagneticField(device packed_float3 &polarCoordinate [[buffer(0)]],
                                device float &yearFraction [[buffer(1)]],
                                constant MagneticFieldModel &magneticFieldModel [[buffer(2)]],
                                device MagneticFieldPerParticleVariables &localVariables [[buffer(3)]],
                                device MagneticField &output [[buffer(4)]]){
    
    thread packed_float3 polarCoord = polarCoordinate;
    thread MagneticFieldPerParticleVariables localVar = localVariables;
    
    // Test mag calculate
    output = calculateMagneticField(magneticFieldModel, localVar, yearFraction, polarCoord);
    
    localVariables = localVar;
}

/// Test coordinate space creation
[[kernel]]
void testCreateCoordSpace(device ParticleAttributes &particle [[buffer(0)]]){
    thread ParticleAttributes p = particle;
    
    // Test coord space creation
    createCoordSpace(p);
    
    particle = p;
}


/// Test applying magnetic field on a particle
[[kernel]]
void testApplyMagneticField(device ParticleAttributes &p [[buffer(0)]],
                            constant MagneticFieldModel &magneticFieldModel [[buffer(1)]],
                            constant float &deltaTime [[buffer(2)]]){
    
    thread ParticleAttributes particle = p;
    // Convert cartesian (x, y, z) to geographic (r, lat, lon) values
    convertToGeographic(particle);
    
    // Local Variables
    thread MagneticFieldPerParticleVariables localVariables = {};
    localVariables.oalt = -1000; localVariables.olat = -1000; localVariables.olon = -1000; localVariables.otime = -1000;
    localVariables.snorm = magneticFieldModel.snorm;
    
    // Compute magnetic field
    thread packed_float3 *polarCoord = &particle.attributes.polarCoordinate;
    thread float yearFraction = particle.attributes.yearFraction;
    MagneticField result = calculateMagneticField(magneticFieldModel, localVariables, yearFraction, *polarCoord);
    
    // Test applying field
    applyField(deltaTime, result, particle);
    p = particle;
}

