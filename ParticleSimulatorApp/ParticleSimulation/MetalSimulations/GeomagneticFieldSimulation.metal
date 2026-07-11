/*
 GeomagneticFieldSimulation.metal
 
 Abstract:
    A compute kernel written in Metal Shading Language to simulate the particles in a particle brush stroke,
    and also to populate the mesh of a particle brush with the result of the simulation.

 Created by: Danny Yan
 */

#include <metal_stdlib>
#include "../Simulator/ParticleVertex.h"
#define PI 3.14159265358979323846


using namespace metal;

/// Calculates IGRF Magnetic Field for a  given polar coordinate
MagneticField calculateMagneticField(constant MagneticFieldModel &model, thread MagneticFieldPerParticleVariables &localVar, float yearFraction, thread packed_float3 &polarCoord)
{
    // polarCoord = <r, lat, lon>
    // Use polar coord in calculation
    float altitude = polarCoord.x;
    float altitudekm = altitude; // Probs have to change uh oh
    float rlat = polarCoord.y;
    float rlon = polarCoord.z;
    
    float dt = yearFraction - model.epoch;
    
    float srlon = sin(rlon);
    float srlat = sin(rlat);
    float crlon = cos(rlon);
    float crlat = cos(rlat);
    
    float srlat2 = srlat * srlat;
    float crlat2 = crlat * crlat;
    float a2 = model.WGS84_A * model.WGS84_A;
    float b2 = model.WGS84_B * model.WGS84_B;
    float c2 = a2 - b2;
    float a4 = a2 * a2;
    float b4 = b2 * b2;
    float c4 = a4 - b4;
    
    localVar.sp[1] = srlon;
    localVar.cp[1] = crlon;
    
    // convert geodetic to spherical
    if (altitudekm != localVar.oalt || rlat != localVar.olat) {
        float q = sqrt(a2 - c2 * srlat2);
        float q1 = altitudekm * q;
        float q2 = ((q1 + a2) / (q1 + b2)) * ((q1 + a2) / (q1 + b2));
        float r2 = ((altitudekm * altitudekm) + 2 * q1 + (a4 - c4 * srlat2) / (q * q));
        localVar.ct = srlat / sqrt(q2 * crlat2 + srlat2);
        localVar.st = sqrt(1 - (localVar.ct * localVar.ct));
        localVar.r = sqrt(r2);
        localVar.d = sqrt(a2 * crlat2 + b2 * srlat2);
        localVar.ca = (altitudekm + localVar.d) / localVar.r;
        localVar.sa = c2 * crlat * srlat / (localVar.r * localVar.d);
    }
    if (rlon != localVar.olon){
        for (int m = 2; m < model.MAX_DEG; m++){
            localVar.sp[m] = localVar.sp[1] * localVar.cp[m - 1] + localVar.cp[1] * localVar.sp[m - 1];
            localVar.cp[m] = localVar.cp[1] * localVar.cp[m - 1] - localVar.sp[1] * localVar.sp[m - 1];
        }
    }
    
    float aor = model.IAU66_RADIUS / localVar.r;
    float ar = aor * aor;
    float br = 0;
    float bt = 0;
    float bp = 0;
    float bpp = 0;
    float par = 0;
    float parp = 0;
    float temp1 = 0;
    float temp2 = 0;
    
    for (int n = 1; n < model.MAX_DEG; n++){
        ar = ar * aor;
        int m = 0;
        float d3 = 1;
        float d4 = (n + m + d3) / d3;
        while (d4 > 0){
            
            // Compute unnormalised associated legendre polynomials and derivatives via recursion relations
            if (altitudekm != localVar.oalt || rlat != localVar.olat) {
                if (n == m) {
                    localVar.snorm.inner[n + m * 13] = localVar.st * localVar.snorm.inner[n - 1 + (m - 1) * 13];
                    localVar.dp[m * 13 + n] = localVar.st * localVar.dp[(m - 1) * 13 + (n - 1)] + localVar.ct * localVar.snorm.inner[n - 1 + (m - 1) * 13];
                }
                
                if ( n == 1 && m == 0) {
                    localVar.snorm.inner[n + m * 13] = localVar.ct * localVar.snorm.inner[n - 1 + m * 13];
                    localVar.dp[m * 13 + n] = localVar.ct * localVar.dp[13 * m + (n - 1)] - localVar.st * localVar.snorm.inner[n - 1 + m * 13];
                }
                if (n > 1 && n != m){
                    if (m > n - 2) {
                        localVar.snorm.inner[n - 2 + m * 13] = 0;
                        localVar.dp[13 * m + (n - 2)] = 0;
                    }
                    localVar.snorm.inner[n + m * 13] = localVar.ct * localVar.snorm.inner[n - 1 + m * 13] - model.k[13 * m + n] * localVar.snorm.inner[n - 2 + m * 13];
                    localVar.dp[13 * m + n] = localVar.ct * localVar.dp[13 * m + (n - 1)] - localVar.st * localVar.snorm.inner[n - 1 + m * 13] - model.k[13 * m + n] * localVar.dp[13 * m + (n - 2)];
                    
                }
            }
            
            //  Time adjust
            if (yearFraction != localVar.otime){
                localVar.tc[13 * m + n] = model.c[13 * m + n] + dt * model.cd[13 * m + n];
                
                if (m != 0){
                    localVar.tc[13 * n + m - 1] = model.c[13 * n + m - 1] + dt * model.cd[13 * n + m - 1];
                }
            }
            
            // Accumulate terms of the spherical harmonic expansions
            par = ar * localVar.snorm.inner[ n + m * 13];
            if (m == 0){
                temp1 = localVar.tc[m * 13 + n] * localVar.cp[m];
                temp2 = localVar.tc[m * 13 + n] * localVar.sp[m];
            }
            else {
                temp1 = localVar.tc[m * 13 + n] * localVar.cp[m] + localVar.tc[n * 13 + m - 1] * localVar.sp[m];
                temp2 = localVar.tc[m * 13 + n] * localVar.sp[m] - localVar.tc[n * 13 + m - 1] * localVar.cp[m];
            }
            
            bt = bt - ar * temp1 * localVar.dp[m * 13 + n];
            bp += (model.fm[m] * temp2 * par);
            br += (model.fn[m] * temp1 * par);
            
            // Special case: north/south geographic poles
            if (localVar.st == 0 && m == 1) {
                if (n == 1){
                    localVar.pp[n] = localVar.pp[n - 1];
                } else {
                    localVar.pp[n] = localVar.ct * localVar.pp[n - 1] - model.k[m * 13 + n] * localVar.pp[n - 2];
                }
                parp = ar * localVar.pp[n];
                bpp += (model.fm[m] * temp2 * parp);
            }
            d4 -= 1;
            m += d3;
        }
    }
    
    if (localVar.st == 0) {
        bp = bpp;
    } else {
        bp /= localVar.st;
    }
    
    float northIntensity = -bt * localVar.ca - br * localVar.sa;
    float eastIntensity = bp;
    float verticalIntensity = bt * localVar.sa - br * localVar.ca;
    
    MagneticField outputField = {};
    outputField.components.x = northIntensity;
    outputField.components.y = eastIntensity;
    outputField.components.z = verticalIntensity;
    
    outputField.horizontalIntensity = sqrt((northIntensity * northIntensity) + (eastIntensity * eastIntensity));
    outputField.declination = atan2(eastIntensity, northIntensity);
    outputField.inclination = atan2(verticalIntensity, outputField.horizontalIntensity);
    
    localVar.oalt = altitudekm;
    localVar.olat = rlat;
    localVar.olon = rlon;
    localVar.otime = yearFraction;
    
    return outputField;
}


/// Initialise magnetic model struct
[[kernel]]
void initialiseMagneticModel(constant float4* modelCoefficients [[buffer(0)]],
                             constant float2* modelCoefficientIndices [[buffer(1)]],
                             constant int &modelCoefficientsLength [[buffer(2)]],
                             constant float4 &modelTimeValues [[buffer(3)]],
                             device MagneticFieldModel &model [[buffer(4)]],
                             uint index [[thread_position_in_grid]])
{
    model.IAU66_RADIUS = 6371.2;
    model.WGS84_A      = 6378.127;
    model.WGS84_B      = 6356.7523142;
    model.MAX_DEG      = 12;
    model.epoch =  modelTimeValues[0];
    
    for (int i = 0; i < modelCoefficientsLength; i++){
        float2 indexes = modelCoefficientIndices[i]; // n, m
        float4 coeff = modelCoefficients[i]; // gnm, hnm, dgnm, dhnm
        float n = indexes[0];
        float m = indexes[1];
        float gnm = coeff[0];
        float hnm  = coeff[1];
        float dgnm = coeff[2];
        float dhnm = coeff[3];
        
        int index = int(13 * m + n);
        if (m <= n) {
            model.c[index] = gnm;
            model.cd[index] = dgnm;
            if (m != 0) {
                int indexnm_1 = int(13 * n + ( m - 1 ));
                model.c[indexnm_1] = hnm;
                model.cd[indexnm_1] = dhnm;
            }
        }
    }
    
    
    // Convert schmidt normalised gauss coefficients to unnormalised
    model.snorm.inner[0] = 1;
    float flnmj;
    int j;
    for (int n = 1; n <= model.MAX_DEG; n++){
        model.snorm.inner[n] = model.snorm.inner[n-1] * float(2 * n  - 1) / float(n);
        j = 2;
        int m = 0;
        int d1 = 1;
        int d2 = (n - m + d1) / d1;
        while (d2 > 0) {
            model.k[int(13 * m + n)] = float(((n - 1) * (n - 1)) - (m * m)) / float((2 * n - 1) * (2 * n - 3));
            if (m > 0){
                flnmj = float( (n - m + 1) * j) / float(n + m);
                model.snorm.inner[n + m * 13] = model.snorm.inner[n + (m - 1) * 13] * sqrt(flnmj);
                j = 1;
                model.c[13 * n + (m - 1)] = model.snorm.inner[n + m * 13] * model.c[13 * n + (m - 1)];
                model.cd[13 * n + (m - 1)]  = model.snorm.inner[n + m * 13] * model.cd[13 * n + (m - 1)];
            }
            model.c[m * 13 + n] = model.snorm.inner[n + m * 13] * model.c[m * 13 + n];
            model.cd[m * 13 + n] = model.snorm.inner[n + m * 13] * model.cd[m * 13 + n];
            d2 -= 1;
            m += d1;
        }
        model.fn[n] = float(n + 1);
        model.fm[n] = float(n);
    }
    model.k[13 * 1 + 1] = 0;
    model.fm[0] = 0;
}

/// Convert polar position to geographic position
void convertToGeographic(float3 position, thread packed_float3 &polarPosition, thread float &radius){
    float globeScaleFactor = radius / 1.2;
    float x = position.x * globeScaleFactor;
    float y = position.y * globeScaleFactor;
    float z = position.z * globeScaleFactor;
    
    
    float coordRadius = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));
    float latitude = 0;
    float longitude = 0;
    
    if (coordRadius > 0.0) {
        latitude = asin(y / coordRadius);
        longitude = atan2(y, x);
    }
    
    polarPosition.x = coordRadius;
    polarPosition.y = latitude;
    polarPosition.z = longitude;
}

/// Create shifted coordinate vector space
void createCoordSpace(thread ParticleAttributes &particle){
    
    thread struct CoordSpace *coordSpace = &particle.attributes.coordSpace;
    
    // Vector Space
    float3 polarCoord = particle.attributes.polarCoordinate;
    float altitude = polarCoord.x;
    float rlat = polarCoord.y;
    float3 verticalComponent = particle.attributes.position / altitude;
    float3 northComponent = float3(0, 0, 1) - sin(rlat) * verticalComponent;
    float3 eastComponent = cross(northComponent, verticalComponent);
    
    coordSpace->northVector = northComponent;
    coordSpace->eastVector = eastComponent;
    coordSpace->verticalVector = verticalComponent;
}

///  Apply Magnetic field against coordinate vector space
void applyField (constant ParticleSimulationParams &params, thread MagneticField &result, thread ParticleAttributes &particle){
    // Create shifted coordinate space
    createCoordSpace(particle);
    struct CoordSpace coordSpace = particle.attributes.coordSpace;
    
    // Apply magnetic field force as a velocity vector centered within the coordinate space
    float3 components = result.components;
    float3 velocity = coordSpace.northVector * components.x + coordSpace.eastVector * components.y - coordSpace.verticalVector * components.z;
    particle.velocity = packed_float3(velocity);
    particle.attributes.position += packed_float3(particle.velocity * params.deltaTime);
}

/// Simulate magnetic field on a set of particles
[[kernel]]
void geoMagneticFieldSimulate(device const ParticleAttributes *particles [[buffer(0)]],
                              device ParticleAttributes *output [[buffer(1)]],
                              constant ParticleSimulationParams &params [[buffer(2)]],
                              constant MagneticFieldModel &magneticFieldModel [[buffer(3)]],
                              device MagneticFieldPerParticleVariables &localVar [[buffer(4)]],
                              uint particleIdx [[thread_position_in_grid]])
{
    if (particleIdx >= params.particleCount) {
        return;
    }
    ParticleAttributes particle = particles[particleIdx];
    thread packed_float3 *polarCoord = &particle.attributes.polarCoordinate;
    thread float yearFraction = particle.attributes.yearFraction;
    // Convert cartesian coords to geographicCoords
    float radius = magneticFieldModel.IAU66_RADIUS;
    convertToGeographic(particle.attributes.position, *polarCoord, radius);
    
    thread MagneticFieldPerParticleVariables localVariables = {}; // fresh per-thread, oalt/olat/etc init to sentinel
    localVariables.oalt = -1000; localVariables.olat = -1000; localVariables.olon = -1000; localVariables.otime = -1000;
    localVariables.snorm = magneticFieldModel.snorm;
    
    // Compute magnetic field
    MagneticField result = calculateMagneticField(magneticFieldModel, localVariables, yearFraction, *polarCoord);
    
    // Temp append result of mag field to particle
    particle.attributes.magField = result;
    
    // Apply field to particle
    applyField(params, result, particle);
    
    // Write to output.
    output[particleIdx] = particle;
}



[[kernel]]
void testCalculateMagneticField(device packed_float3 &polarCoordinate [[buffer(0)]],
                                device float &yearFraction [[buffer(1)]],
                                constant MagneticFieldModel &magneticFieldModel [[buffer(2)]],
                                device MagneticFieldPerParticleVariables &localVariables [[buffer(3)]],
                                device MagneticField &output [[buffer(4)]])
                                
{
    thread packed_float3 polarCoord = polarCoordinate;
    thread MagneticFieldPerParticleVariables localVar = localVariables;
    output = calculateMagneticField(magneticFieldModel, localVar, yearFraction, polarCoord);
}

