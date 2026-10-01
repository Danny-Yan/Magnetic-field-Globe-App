# Particle Simulator for Earth's Magnetic Field
Simulates particles moving through Earth's Magnetic Field in real time on the Apple Vision Pro. This is accomplished through implementing a compute shader in 
Metal to calculate the force applied for a given geographic position by either the WMM2020 or WMM2025 model of [Earth's Magnetic Field](https://www.ncei.noaa.gov/products/world-magnetic-model). 
This computed force vector is then applied to a particle's velocity every frame to simulate it moving through the field. A low level mesh stores
a particle's rendering attributes (size, velocity, position, texture coordinates), which then gets pushed to the screen every frame.

<img width="1114" height="612" alt="Magnetic Field Result" src="https://github.com/user-attachments/assets/247589a1-3e7f-4acb-97dc-24ce75712374" />

## Configurable settings
### Pre simulation settings
- Particle Number
- Magnetic Model Version (WMM2020, WMM2025)

### Simulation settings
- A configurable date for the simulation (within the current model time span)
- Size of particle objects
- A multiplier for the intensity of the magnetic field force
- Particle simulation boundaries
Multiple separate colour layers are also configurable,
namely a solid colour layer which shows only a single solid
colour, along with a heat map layer which maps particle’s
speed as dictated by the force exerted on said particle, to a
gradient of colours.
