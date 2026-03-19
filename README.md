# Starlink Satellite Visibility Pattern
## Overview
In the code, an idealized set of 1584 TLEs is used to model the Starlink 
first shell, derived from Starlink-1019 (NORAD ID: 44724). Unlike real TLEs 
which account for satellites launched incrementally and orbital planes drifting 
over time due to atmospheric drag and station-keeping maneuvers, the ideal 
Walker-Delta simulation distributes all satellites uniformly with perfect 
spacing across 72 orbital planes.

This is why the simulation shows **26–35 visible satellites simultaneously**, 
instead of the real-world **6–12**. This is the limitation of the ideal 
constellation assumption.

> **Note:** A TLE (Two-Line Element set) is a snapshot of a satellite's orbit 
at a specific moment in time.

---

## TLE Epoch and Simulation Window
The Starlink-1019 TLE epoch of **August 21, 2021** was used to extract the 
shell-defining orbital parameters for the Walker-Delta Model. The simulation 
was conducted over a **3-hour window on August 20, 2025**. Satellite positions 
were determined by propagating those parameters using MATLAB's satellite 
scenario framework.

### Reference Orbital Parameters — Starlink-1019
| Parameter | Value |
|-----------|-------|
| Inclination | 53.0546 deg |
| RAAN | 102.5261 deg |
| Eccentricity | 0.0002146 |
| Arg. of Perigee | 68.2315 deg |
| Mean Anomaly | 291.8902 deg |
| Mean Motion | 15.06408494 rev/day |
| Rev at Epoch | 97740 |

---

## Orbital Radius Calculation
Orbital radius is determined from the mean motion using Kepler's Third Law.

**Step 1 — Convert mean motion to rad/s:**

n = 15.06408494 × (2π / 86400) = 0.001740 rad/s

**Step 2 — Apply Kepler's Third Law (gravitational = centripetal force):**

r = (μ / n²) ^ (1/3)

Where μ = 3.986004418 × 10¹⁴ m³/s² (Earth gravitational parameter)

**Result:** Orbital radius = **6921 km** from Earth's center → **550 km altitude**

Since the eccentricity of Starlink-1019 is approximately 0.0002146, the orbit 
is treated as circular. The difference between perigee and apogee is only 3 km 
out of 6921 km — a variation of just **0.04%** — which is negligible for 
constellation modelling. The semi-major axis is therefore used as a constant 
orbital radius throughout the simulation.

---

## Walker-Delta Constellation Geometry
| Symbol | Value | Meaning |
|--------|-------|---------|
| T | 1584 | Total Satellites |
| P | 72 | Number of Orbital Planes |
| F | 1 | Phasing Factor |

- **Plane spacing:** 360 / 72 = **5 degrees** between consecutive planes  
- **In-plane spacing:** 360 / 22 = **16.36 degrees** between satellites  
- **Phase offset:** 0.2273 degrees per plane — prevents all planes crossing 
the equator simultaneously

---

## Satellite Naming Convention
Each satellite is labeled as:
```
STARLINK-1019 P{plane}-S{slot}
```
For example, **STARLINK-1019 P22-S03** = Plane 22, Slot 3 of the modeled 
Starlink first shell.

---

## Ground Station — Irving, Texas
| Parameter | Value |
|-----------|-------|
| Latitude | 32.8140° N |
| Longitude | 96.9489° W |
| Altitude | 0 m (ground level) |
| Min Elevation Angle | 10 degrees |

A satellite is visible from Irving if it satisfies **both** conditions:
1. The satellite is above the horizon
2. The satellite is at least **10 degrees** above the horizon

---

## Orbit Number Calculation
Orbit number at any simulation time is estimated by extrapolating from the 
TLE epoch:

OrbitNum = floor(RevAtEpoch + MeanMotion × ΔT)

**Example for August 20, 2025:**
- ΔT = Aug 20, 2025 − Aug 17, 2021 ≈ **1464 days**
- Additional orbits = 15.064 × 1464 ≈ **22,054 orbits**
- OrbitNum = 97740 + 22054 = **119,794**

The `floor()` function is used because orbit number must be a whole number.

---

## Handover Strategies

### Strategy 1 — Highest Elevation Angle 
The satellite with the highest elevation angle is selected as the serving 
satellite. At lower elevation angles the signal travels a longer atmospheric 
path — at 10 degrees elevation the path is approximately **5.76× longer** 
than at zenith, causing greater attenuation and degraded link quality.

To prevent excessive ping-pong handovers from marginal elevation differences, 
a **hysteresis constraint** is applied with two simultaneous conditions:

| Condition | Value |
|-----------|-------|
| Elevation improvement required | > 5 degrees |
| Minimum dwell time on current satellite | 10 timesteps = 300 seconds |

If either condition is not met, the terminal stays on the current satellite 
regardless of whether a higher elevation is available. **Forced handovers** 
occur only when the serving satellite drops below the 10-degree minimum mask.

### Strategy 2 — Longest Visual Time
Selects the satellite with the most remaining visibility time above the ground 
station. The terminal stays connected until the satellite drops below the 
horizon — **forced handovers only, no voluntary switching.**

- Minimises total handover count by design  
- Tiebreaker: highest elevation among satellites with equal remaining windows  
- Matches the strategy in: *Romero et al., Handover Management and Doppler 
Shift Compensation in Satellite Communications, University of North Texas*  
- Paper finding: longest visual strategy outperforms strongest-signal when 
handover delay exceeds **130 ms**

---

## Repository Files
| File | Description |
|------|-------------|
| `starlink_walker_constellation_and_tle_table.m` | Constellation setup, TLE table, scenario workspace |
| `highest_elevation_handover.m` | Highest elevation handover strategy with hysteresis |
| `longest_visual_time_handover.m` | Longest visual time handover strategy |
| `visibility_pattern_notes.mlx` | Full live script with research notes |
| `visibility_pattern_notes.pdf` | Exported PDF with all figures |

---

## Simulation Parameters
| Parameter | Value |
|-----------|-------|
| Constellation | Starlink Shell 1 |
| Total Satellites | 1584 |
| Orbital Planes | 72 |
| Satellites per Plane | 22 |
| Altitude | 550 km |
| Inclination | 53.05 deg |
| Sample Interval | 30 seconds |
| Simulation Duration | 3 hours (361 timesteps) |
| Simulation Date | August 20, 2025 |
```



