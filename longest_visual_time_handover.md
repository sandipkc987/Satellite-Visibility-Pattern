# Longest Visibility Time Handover (MATLAB)

##  Overview

This project demonstrates the **Longest Visibility Time handover strategy** for satellite communication systems using MATLAB.

Instead of always switching to the satellite with the best signal at the current moment,  
the terminal connects to the satellite that will remain **visible for the longest future duration**.

This strategy helps:

- reduce unnecessary handovers  
- improve link stability  
- reduce signalling overhead  
- simplify handover decision logic  

This repository provides a **simple educational example** using a small satellite constellation.

---

##  Example Constellation Setup

This example uses a simplified constellation:

- Total satellites: **6**
- Orbital planes: **3**
- Satellites per plane: **2**
- Simulation time steps: **6**
- Sample time: **10 seconds**

Satellite naming convention:

| Plane | Satellites |
|------|-----------|
| Plane-1 | S1, S2 |
| Plane-2 | S3, S4 |
| Plane-3 | S5, S6 |

---

## 👀 Visibility Matrix

At each time step, some satellites are visible from the ground station.

- `1` → satellite visible  
- `0` → satellite not visible  

| Time | S1 | S2 | S3 | S4 | S5 | S6 |
|------|----|----|----|----|----|----|
| t1 | 1 | 0 | 1 | 0 | 0 | 0 |
| t2 | 1 | 0 | 1 | 1 | 0 | 0 |
| t3 | 0 | 1 | 1 | 1 | 0 | 0 |
| t4 | 0 | 1 | 0 | 1 | 1 | 0 |
| t5 | 0 | 0 | 0 | 1 | 1 | 1 |
| t6 | 0 | 0 | 0 | 0 | 1 | 1 |

MATLAB representation:

```matlab
statusByTime = [
    1 0 1 0 0 0;
    1 0 1 1 0 0;
    0 1 1 1 0 0;
    0 1 0 1 1 0;
    0 0 0 1 1 1;
    0 0 0 0 1 1
];
