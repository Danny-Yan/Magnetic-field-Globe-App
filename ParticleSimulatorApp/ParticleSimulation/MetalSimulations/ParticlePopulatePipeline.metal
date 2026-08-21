//
//  ParticlePopulatePipeline.metal
//  ParticleSimulatorApp
//
//  Created by DY on 13/8/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

#include <metal_stdlib>

#include "../Simulator/ParticleVertex.h"
#define PI 3.14159265358979323846


using namespace metal;

/*
 
 
 */
[[kernel]]
void particleBrushPopulate(device const ParticleAttributes *particles [[buffer(0)]],
                          device ParticleVertex *output [[buffer(1)]],
                          constant const uint32_t &particleCount [[buffer(2)]],
                          uint particleIdx [[thread_position_in_grid]])
{
    if (particleIdx >= particleCount) {
        return;
    }
    
    ParticleAttributes particle = particles[particleIdx];
    
    const uint startIndex = particleIdx * 4;
    output[startIndex + 0] = ParticleVertex { .attributes = particle.attributes, .uv = { 0, 0 }};
    output[startIndex + 1] = ParticleVertex { .attributes = particle.attributes, .uv = { 0, 1 }};
    output[startIndex + 2] = ParticleVertex { .attributes = particle.attributes, .uv = { 1, 1 }};
    output[startIndex + 3] = ParticleVertex { .attributes = particle.attributes, .uv = { 1, 0 }};
}
