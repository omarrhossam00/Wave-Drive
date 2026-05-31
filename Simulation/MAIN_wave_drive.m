%% WAVE DRIVE TANK — Main Runner
% Inspired by James Bruton's "Experimental Wave Drive V2"
% https://www.youtube.com/watch?v=yMGVp4BM6tk

clc; close all;
fprintf('=========================================================\n');
fprintf('  WAVE DRIVE TANK SIMULATION SUITE                       \n');
fprintf('  Inspired by James Bruton''s Experimental Wave Drive V2 \n');
fprintf('=========================================================\n\n');

fprintf('Available simulations:\n');
fprintf('  [1] single_cam_simulation  -  ONE cam: SHM building block\n');
fprintf('  [2] single_cam_vs_wave     -  Side-by-side: 1 cam vs N cams\n');
fprintf('  [3] wave_drive_simulation  -  2D side view (camshaft, cams, plates)\n');
fprintf('  [4] wave_drive_3D          -  3D view of full tank\n');
fprintf('  [5] wave_drive_physics     -  Physics analysis (contact, speed)\n');
fprintf('  [a] Run ALL five sequentially\n');
fprintf('  [q] Quit\n\n');

choice = input('Choice: ','s');

switch lower(choice)
    case '1'
        single_cam_simulation();
    case '2'
        single_cam_vs_wave();
    case '3'
        wave_drive_simulation();
    case '4'
        wave_drive_3D();
    case '5'
        wave_drive_physics();
    case 'a'
        fprintf('\n[1/5] Single cam (SHM building block)...\n');
        single_cam_simulation();
        fprintf('\n[2/5] Single cam vs wave (side-by-side)...\n');
        single_cam_vs_wave();
        fprintf('\n[3/5] 2D side view...\n');
        wave_drive_simulation();
        fprintf('\n[4/5] 3D view...\n');
        wave_drive_3D();
        fprintf('\n[5/5] Physics analysis...\n');
        wave_drive_physics();
    otherwise
        fprintf('Cancelled.\n');
end
