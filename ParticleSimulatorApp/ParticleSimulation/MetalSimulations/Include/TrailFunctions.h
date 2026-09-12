//
//  TrailFunctions.h
//  ParticleSimulatorApp
//
//  Created by DY on 4/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
#pragma once

#include <metal_stdlib>

#include "../../Simulator/ParticleVertex.h"

using namespace metal;

/// Records `position` into a particle's trail ring buffer, advancing the write index.
void pushTrailPosition(thread ParticleAttributes &particle);

/// Resets every sample in a particle's trail to `position`, collapsing it to a single point.
void resetTrail(thread ParticleAttributes &particle);

/// Update handler for creating and resetting a particle's trail
void updateTrail(thread ParticleAttributes &particle);
