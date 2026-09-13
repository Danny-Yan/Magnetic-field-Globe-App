//
//  ParticleTrailPipeline.metal
//  ParticleSimulatorApp
//
//  Created by DY on 13/8/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

#include <metal_stdlib>

#include "../Simulator/ParticleVertex.h"
#define PI 3.14159265358979323846


using namespace metal;

void trailPopulatePipelineFunction(thread ParticleAttributes &particle,
                                   device ParticleTrailVertex *outputTrailVertices,
                                   uint particleIdx){

    uint32_t base = particleIdx * MAX_TRAIL_LENGTH;
    uint32_t oldestSampleIndex = particle.trailBuffers.trailCurrentIndex;

    for (uint i = 0; i < MAX_TRAIL_LENGTH; i++){
        // Walk the ring buffer starting from the oldest sample so vertices come out oldest-to-newest.
        uint sampleIndex = (oldestSampleIndex + i) % MAX_TRAIL_LENGTH;

        device ParticleTrailVertex &particleVertex = outputTrailVertices[base + i];
        device ParticleTrailAttributes &trailAttributes = particleVertex.attributes;
        trailAttributes.position = particle.trailBuffers.trailPositions[sampleIndex];
        trailAttributes.color = particle.trailBuffers.trailColor[sampleIndex];
        
        
        // Fade from fully transparent at the tail (i == 0) to fully opaque at the particle's current position.
//        trailAttributes.color.w = half(i) / half(MAX_TRAIL_LENGTH - 1);
    }
}
/// Builds the trail line vertices for every particle from its `trailPositions` history.
[[kernel]]
void geoMagneticTrailPopulate(device ParticleAttributes *particles [[buffer(0)]],
                              device ParticleTrailVertex *outputTrailVertices [[buffer(1)]],
                              constant uint32_t &particleCount [[buffer(2)]],
                              uint particleIdx [[thread_position_in_grid]]){
    if (particleIdx >= particleCount) {
        return;
    }

    thread ParticleAttributes particle = particles[particleIdx];
    
    trailPopulatePipelineFunction(particle, outputTrailVertices, particleIdx);
}

/// Tests trail line creation
[[kernel]]
void testTrailPopulatePipeline(device ParticleAttributes &particle [[buffer(0)]],
                              device ParticleTrailVertex *vertices [[buffer(1)]]){
    
    thread ParticleAttributes tParticle = particle;
    uint particleIdx = 0;
    trailPopulatePipelineFunction(tParticle, vertices, particleIdx);
}
