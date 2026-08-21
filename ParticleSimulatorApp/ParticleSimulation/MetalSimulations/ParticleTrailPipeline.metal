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
    uint32_t oldestSampleIndex = particle.trailCurrentIndex;

    for (uint i = 0; i < MAX_TRAIL_LENGTH; i++){
        // Walk the ring buffer starting from the oldest sample so vertices come out oldest-to-newest.
        uint sampleIndex = (oldestSampleIndex + i) % MAX_TRAIL_LENGTH;

        device ParticleTrailVertex &particleVertex = outputTrailVertices[base + i];
        device ParticleTrailAttributes &trailAttributes = particleVertex.attributes;
        trailAttributes.position = particle.trailPositions[sampleIndex];
        
        trailAttributes.color.x = particle.attributes.color.x;
        trailAttributes.color.y = particle.attributes.color.y;
        trailAttributes.color.z = particle.attributes.color.z;
        
        // Fade from fully transparent at the tail (i == 0) to fully opaque at the particle's current position.
        trailAttributes.color.w = half(i) / half(MAX_TRAIL_LENGTH - 1);
    }
}
/// Builds the trail line vertices for every particle from its `trailPositions` history.
///
/// Writes `PARTICLE_TRAIL_LENGTH` vertices per particle, ordered oldest-to-newest, into `vertices`.
/// Pair this with an index buffer of `.line` segments connecting consecutive samples within each
/// particle's block (see `ParticleMeshGenerator+Trail.swift`).
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
    
//    const uint startIndex = particleIdx * 4;
//    
//    vertices[startIndex + 0] = ParticleTrailVertex { .attributes = particle.attributes, .uv = { 0, 0 }};
//    vertices[startIndex + 1] = ParticleTrailVertex { .attributes = particle.attributes, .uv = { 0, 1 }};
//    vertices[startIndex + 2] = ParticleTrailVertex { .attributes = particle.attributes, .uv = { 1, 1 }};
//    vertices[startIndex + 3] = ParticleTrailVertex { .attributes = particle.attributes, .uv = { 1, 0 }};
}





// TODO: CREATE POPULATE PIPELINE TESTS, CHECK TO SEE IF THIS HAS ANY BUGS

[[kernel]]
void testTrailPopulatePipeline(device ParticleAttributes &particle [[buffer(0)]],
                              device ParticleTrailVertex *vertices [[buffer(1)]]){
    
    thread ParticleAttributes tParticle = particle;
    uint particleIdx = 0;
    trailPopulatePipelineFunction(tParticle, vertices, particleIdx);
    
}
