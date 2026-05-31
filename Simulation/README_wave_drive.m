% =================================================================
% WAVE DRIVE TANK SIMULATION
% Inspired by James Bruton's "Experimental Wave Drive V2"
% https://www.youtube.com/watch?v=yMGVp4BM6tk
% =================================================================
%
% MECHANISM CONCEPT:
% ------------------
% A camshaft runs along the bottom of the tank. On the shaft are N
% identical CIRCULAR cams, each mounted ECCENTRICALLY. Each cam is
% phase-shifted from its neighbour by 360°/N.
%
% On top of each cam sits a plate. As the shaft rotates, each plate
% moves up and down following a sinusoidal motion:
%     y_i(t) = ε · sin(ω·t + (i-1)·Δφ)
% where:
%     ε  = eccentricity (wave amplitude)
%     ω  = shaft angular velocity
%     Δφ = 2π / N (phase between adjacent plates)
%
% Together the N plates form a TRAVELLING SINE WAVE along the tank.
% The wave moves at speed:  v_wave = (N · spacing · ω) / (2π)
%                                   = wavelength × shaft frequency
%
% PROPULSION:
% -----------
% At any instant, ~1/3 of the plates are pushing against the ground.
% In the GROUND frame, these contact points sweep backward as the wave
% travels backward → ground exerts forward friction → tank moves forward.
%
% Theoretical robot speed (no slip):  v_robot = v_wave
%
% =================================================================
% FILES IN THIS FOLDER:
% =================================================================
%
% MAIN_wave_drive.m
%   Interactive launcher — choose which simulation to run
%
% wave_drive_simulation.m
%   2D side view, fully animated:
%     - rotating camshaft with N coloured eccentric cams
%     - plates riding on each cam
%     - "wave shape (instantaneous)" plot below
%     - "plate height vs time" plot showing phase-shifted sinusoids
%     - robot body translates above the cams
%
% wave_drive_3D.m
%   3D view with:
%     - ground plane (terrain)
%     - long horizontal camshaft
%     - cam discs visible from the side
%     - plates as 3D rectangles
%     - tank body and 4 steering wheels
%
% wave_drive_physics.m
%   Analysis of the propulsion mechanism:
%     - travelling wave snapshots (ghost waves at past times)
%     - which plates are in contact with the ground (red highlight)
%     - contact pattern raster (time vs plate index)
%     - robot speed vs camshaft speed plot
%
% =================================================================
% HOW TO RUN:
% =================================================================
%   1. In MATLAB, set this folder as Current Folder
%   2. >> MAIN_wave_drive
%   3. Pick option [1], [2], [3], or [a] (all three)
%
% =================================================================
% PARAMETERS YOU CAN TUNE (top of each script):
% =================================================================
%   N_cams       - number of cams along the shaft (more → smoother wave)
%   spacing      - distance between adjacent cams [mm]
%   eccentricity - cam centre offset = wave amplitude [mm]
%   cam_radius   - base radius of cam disc [mm]
%   n_rpm        - shaft rotational speed [rpm]
%
%   Wavelength = N_cams × spacing
%   Robot speed = (wavelength × n_rpm × 2π / 60) / (2π)
%               = N_cams × spacing × n_rpm / 60
%
% =================================================================
% NEXT STEPS (extensions):
% =================================================================
%   - Add slip model: real robot speed < wave speed when friction is low
%   - Steering: differential cam speed on left/right tracks
%   - Replace circular cams with custom profile cams (cycloidal motion)
%     for smoother lift/return
%   - Connect to real-world data: CAD imports for body, wheels, etc.
% =================================================================
