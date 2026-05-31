# 🌊 Wave Drive Tank
### Mechanism Analysis & Computational Simulation
*Theory of Machines II — Sheet Project | Helwan National University*

> **Rotary motion → Travelling sine wave → Linear translation**

---

## Overview

The **Wave Drive Tank** uses a rotating camshaft to generate a travelling sine wave of plates touching the ground. As the wave sweeps backward, static friction propels the robot forward. Each plate moves only up & down (SHM), but the collection of N phase-shifted plates creates a horizontal travelling wave.

**Advantages:** distributes load over many plates · great for soft/uneven terrain · speed scales linearly with RPM · single motor input · no exposed wheels

---

## Mathematics

| Quantity | Equation |
|---|---|
| Displacement | `s(t) = ε · sin(ωt)` |
| Velocity | `v(t) = ε · ω · cos(ωt)` |
| Acceleration | `a(t) = −ε · ω² · sin(ωt)` |

**Phase equation (N cams):** `yᵢ(t) = ε · sin(ωt + (i−1) · 2π/N)`

**Robot speed:** `v_robot = λ · ω / 2π` — Design point: 60 RPM → **0.42 m/s**

---

## MATLAB Simulation Suite

```matlab
>> MAIN_wave_drive   % then choose [1]–[5] or [a] for all
```

| # | Simulation | Description |
|---|---|---|
| 1 | Single Cam | Animated cam + scrolling s, v, a plots + phase portrait |
| 2 | Single vs Wave | 1 cam vs N cams side-by-side |
| 3 | 2D Side View | Full mechanism with rotating shaft, cams, and plates |
| 4 | 3D Tank View | Complete 3D model with terrain and steering wheels |
| 5 | Physics Analysis | Contact pattern, ghost-wave snapshots, touch raster |

---

## Design Trade-offs

| Parameter | Effect |
|---|---|
| More cams (N ↑) | Smoother wave, heavier shaft |
| Larger ε | More grip, higher peak acceleration |
| Faster RPM | Linear speed gain; limited by vibration |
| Larger R | More ground clearance; no effect on wave shape |

---

## Team

Robotics & Mechatronics Engineering — Helwan National University

Khaled Abdel Moneim · Mohamed Ahmed Abdelrazek · Omar Hossam Hassan · Adham Omar Youssef · Mariam Mohamed Abdel-Aal · Hassan Ahmed Hassan · Ramy Ragab Abdelghafour · Seif El-Din Said Ahmed · Mohsen Ahmed Mohsen · Abdelrahman Ihab Hamouda

---

*Inspired by James Bruton — "Experimental Wave Drive V2" · Theory of Machines II · 2026*
