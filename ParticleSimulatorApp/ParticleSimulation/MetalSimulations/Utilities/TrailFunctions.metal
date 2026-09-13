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
    thread ParticleTrailBuffers *trails = &particle.trailBuffers;
    
    trails->trailPositions[trails->trailCurrentIndex] = particle.attributes.position;
    trails->trailColor[trails->trailCurrentIndex] = particle.attributes.color;
    trails->trailCurrentIndex = (trails->trailCurrentIndex + 1) % MAX_TRAIL_LENGTH;
}

/// Resets every sample in a particle's trail to `position`, collapsing it to a single point.
void resetTrail(thread ParticleAttributes &particle){
    thread ParticleTrailBuffers *trails = &particle.trailBuffers;
    
    for (int i = 0; i < MAX_TRAIL_LENGTH; i++){
        trails->trailPositions[i] = particle.attributes.position;
        trails->trailColor[i] = particle.attributes.color;
    }
    trails->trailCurrentIndex = 0;
}

/// Update handler for creating and resetting a particle's trail
void updateTrail(thread ParticleAttributes &particle){
    
    if (particle.age == 0){
        resetTrail(particle);
    } else {
        pushTrailPosition(particle);
    }
}
