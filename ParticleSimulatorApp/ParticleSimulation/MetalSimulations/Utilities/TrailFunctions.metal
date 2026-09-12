//
//  TrailFunctions.metal
//  ParticleSimulatorApp
//
//  Created by DY on 4/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

#include "../Include/TrailFunctions.h"

/// Records `position` into a particle's trail ring buffer, advancing the write index.
void pushTrailPosition(thread ParticleAttributes &particle){
    particle.trailPositions[particle.trailCurrentIndex] = particle.attributes.position;
    particle.trailColor[particle.trailCurrentIndex] = particle.attributes.color;
    particle.trailCurrentIndex = (particle.trailCurrentIndex + 1) % MAX_TRAIL_LENGTH;
}

/// Resets every sample in a particle's trail to `position`, collapsing it to a single point.
void resetTrail(thread ParticleAttributes &particle){
    for (int i = 0; i < MAX_TRAIL_LENGTH; i++){
        particle.trailPositions[i] = particle.attributes.position;
        particle.trailColor[i] = particle.attributes.color;
    }
    particle.trailCurrentIndex = 0;
}

/// Update handler for creating and resetting a particle's trail
void updateTrail(thread ParticleAttributes &particle){
    if (particle.attributes.age == 0){
        resetTrail(particle);
    } else {
        pushTrailPosition(particle);
    }
}
