/*
 SimpleParticleSimulation.metal
 
 Abstract:
    A compute kernel written in Metal Shading Language to simulate the particles in a particle brush stroke,
    and also to populate the mesh of a particle brush with the result of the simulation.

 Created by: Danny Yan
 */

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



/*
 Template particle simulator code
 Particles oscillate in random directions
 */
[[kernel]]
void particleBrushSimulate(device const ParticleAttributes *particles [[buffer(0)]],
                          device ParticleAttributes *output [[buffer(1)]],
                          constant ParticleSimulationParams &params [[buffer(2)]],
                          uint particleIdx [[thread_position_in_grid]])
{
    if (particleIdx >= params.particleCount) {
        return;
    }
    
    ParticleAttributes particle = particles[particleIdx];

    const float speed2 = length_squared(particle.velocity);
//    const float dragForce = -speed2 * (params.dragCoefficient * params.deltaTime);
    const float speed = sqrt(speed2);
//    const float newSpeed = max(0.0f, speed - dragForce);
    
//    if (min(newSpeed, speed) > 0.0001) {
//        particle.velocity = particle.velocity / speed * newSpeed;
//    } else {
//        particle.velocity = 0;
//    }
    
    const float springConst = 1.0;
    const float3 acceleration = - springConst * (particle.attributes.position - particle.attributes.initialPosition);

    particle.velocity += acceleration * params.deltaTime;
//    particle.velocity = particle.velocity / speed * newSpeed;
    particle.attributes.position += particle.velocity * params.deltaTime;

    // Write to output.
    output[particleIdx] = particle;
}




