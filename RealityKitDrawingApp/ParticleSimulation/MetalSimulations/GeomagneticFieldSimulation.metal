/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A compute kernel written in Metal Shading Language to simulate the particles in a particle brush stroke, 
  and also to populate the mesh of a particle brush with the result of the simulation.
*/

#include <metal_stdlib>

#include "../Simulator/ParticleBrushVertex.h"
#define PI 3.14159265358979323846


using namespace metal;

[[kernel]]
void geoMagneticFieldSimulate(device const particleBrushParticle *particles [[buffer(0)]],
                          device particleBrushParticle *output [[buffer(1)]],
                          constant particleBrushSimulationParams &params [[buffer(2)]],
                          uint particleIdx [[thread_position_in_grid]])
{
    if (particleIdx >= params.particleCount) {
        return;
    }
    
    particleBrushParticle particle = particles[particleIdx];

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




