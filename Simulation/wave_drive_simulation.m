function wave_drive_simulation()
%WAVE_DRIVE_SIMULATION  Animated simulation of James Bruton's Wave Drive
%
% Mechanism: A camshaft with N circular eccentric cams (each rotated by
% phase 360°/N from the previous) drives N flat plates up and down.
% As the camshaft rotates, the plates trace a travelling sinusoidal wave.
% The wave pushes the ground backward → robot moves forward.
%
% This simulation shows:
%   1. Side view of the camshaft + plates (the wave)
%   2. Animated motion of all cams synchronously
%   3. Position vs time plot for each plate (phase-shifted sinusoids)
%   4. Robot body translation (computed from wave-ground contact velocity)

close all; clc;

%% ── DESIGN PARAMETERS ──────────────────────────────────────────────────
N_cams      = 12;          % number of cams along the camshaft
spacing     = 35;          % mm between cams along x-axis
cam_radius  = 25;          % mm, base radius of each cam disc
eccentricity= 18;          % mm, offset of cam centre from shaft → wave amplitude
plate_width = 30;          % mm, x-extent of each plate
plate_height= 8;           % mm, plate thickness
shaft_radius= 6;           % mm
shaft_y     = 80;          % shaft height above ground

n_rpm       = 60;          % camshaft speed
omega       = n_rpm*2*pi/60;
total_time  = 6;           % seconds of simulation
fps         = 30;
dt          = 1/fps;

% Wave & robot motion
% Each cam i has phase offset:  phi_i = (i-1) * (2π / N_cams)
% so a full wavelength fits along the camshaft length.
phase_offset = 2*pi / N_cams;

% wavelength along x:
wavelength = N_cams * spacing;          % mm
% wave speed: lambda * f, where f = omega/(2π)
wave_speed = wavelength * omega/(2*pi); % mm/s
% Robot speed = wave_speed (rough — assumes no slip)
% Direction is opposite to wave propagation. By choosing phase to advance
% with x as θ_cam increases, the wave moves in +x → robot moves in -x.
% In this sim we'll show robot moving in +x for visual convenience by
% flipping sign of phase increment with time.

robot_speed = wave_speed;   % mm/s (assume rolling without slip)
fprintf('=================================================\n');
fprintf(' WAVE DRIVE TANK SIMULATION\n');
fprintf('=================================================\n');
fprintf(' Number of cams:     %d\n', N_cams);
fprintf(' Cam spacing:        %g mm\n', spacing);
fprintf(' Eccentricity (amp): %g mm\n', eccentricity);
fprintf(' Cam radius:         %g mm\n', cam_radius);
fprintf(' Shaft speed:        %g rpm  (ω = %.2f rad/s)\n', n_rpm, omega);
fprintf(' Wavelength:         %g mm\n', wavelength);
fprintf(' Wave speed:         %.1f mm/s = %.3f m/s\n', wave_speed, wave_speed/1000);
fprintf(' Robot speed:        %.1f mm/s = %.3f m/s\n', robot_speed, robot_speed/1000);
fprintf('=================================================\n\n');

%% ── PRE-COMPUTE GEOMETRY ──────────────────────────────────────────────
% x-positions of each cam along the shaft
cam_x = ((1:N_cams) - (N_cams+1)/2) * spacing;

% pre-compute one cam's circle outline (parametric)
th_circle = linspace(0, 2*pi, 60);

%% ── FIGURE SETUP ──────────────────────────────────────────────────────
fig = figure('Name','Wave Drive Tank Simulation','NumberTitle','off',...
    'Position',[60 40 1500 800],'Color','w');

% ── Main side view ────────────────────────────────────────────────────
ax1 = subplot(2,2,[1 2]); hold on; axis equal; grid on; box on;
ax_lim_x = [min(cam_x)-80, max(cam_x)+80];
ax_lim_y = [-30, shaft_y + cam_radius + eccentricity + 30];
xlim(ax_lim_x); ylim(ax_lim_y);
xlabel('x [mm]'); ylabel('y [mm]');
title('Wave Drive — Side View (camshaft + plates riding on cams)','FontSize',12,'FontWeight','bold');

% Ground line
plot(ax_lim_x,[0 0],'k-','LineWidth',1.5);
xs = linspace(ax_lim_x(1),ax_lim_x(2),50);
for i=1:length(xs)
    plot([xs(i) xs(i)+8],[-3 -10],'k-','LineWidth',0.5);
end

% Shaft (long horizontal line at shaft_y)
plot(ax_lim_x, [shaft_y shaft_y],'-','Color',[0.3 0.3 0.3],'LineWidth',1,'LineStyle',':');

% Robot body outline (above the cams)
body_y = shaft_y + cam_radius + eccentricity + 8;
body_height = 14;
robot_body = rectangle(ax1,'Position',...
    [min(cam_x)-50, body_y, max(cam_x)-min(cam_x)+100, body_height],...
    'FaceColor',[0.85 0.92 1.0],'EdgeColor',[0.2 0.4 0.7],'LineWidth',2);

% Steering wheel placeholders (front and back)
wh_R = 18;
front_wheel = plot(ax1, NaN, NaN,'-','Color',[0.2 0.2 0.2],'LineWidth',2.5);
back_wheel  = plot(ax1, NaN, NaN,'-','Color',[0.2 0.2 0.2],'LineWidth',2.5);

% Allocate handles for cams and plates
cam_patches  = gobjects(N_cams,1);
cam_centres  = gobjects(N_cams,1);
plate_patches= gobjects(N_cams,1);
contact_dots = gobjects(N_cams,1);

% colours: cycle through hsv for cams
cam_cols = hsv(N_cams);

for i = 1:N_cams
    cam_patches(i) = fill(ax1, NaN, NaN, cam_cols(i,:),...
        'FaceAlpha',0.55,'EdgeColor',cam_cols(i,:)*0.6,'LineWidth',1.5);
    cam_centres(i) = plot(ax1, NaN, NaN, 'k+','MarkerSize',6,'LineWidth',1.2);
    plate_patches(i) = fill(ax1, NaN, NaN, [0.3 0.35 0.4],...
        'FaceAlpha',0.85,'EdgeColor','k','LineWidth',1);
    contact_dots(i) = plot(ax1, NaN, NaN,'o','MarkerSize',6,...
        'MarkerFaceColor','r','MarkerEdgeColor','k','LineWidth',1);
end

% Shaft circles at each cam location (drawn AFTER so on top)
shaft_circles = gobjects(N_cams,1);
for i = 1:N_cams
    shaft_circles(i) = fill(ax1, ...
        cam_x(i)+shaft_radius*cos(th_circle), ...
        shaft_y+shaft_radius*sin(th_circle), ...
        [0.4 0.4 0.4],'EdgeColor','k','LineWidth',1);
end

% Phase angle indicator
theta_text = text(ax1, ax_lim_x(1)+10, ax_lim_y(2)-15,...
    'θ = 0°','FontSize',12,'FontWeight','bold','Color','b');
robot_x_text = text(ax1, ax_lim_x(1)+10, ax_lim_y(2)-30,...
    'robot x = 0 mm','FontSize',11,'Color',[0.2 0.4 0.7],'FontWeight','bold');

% ── Plate height vs cam index plot ────────────────────────────────────
ax2 = subplot(2,2,3); hold on; grid on; box on;
xlabel('cam index'); ylabel('plate height y [mm]');
title('Wave shape (instantaneous)','FontSize',11,'FontWeight','bold');
xlim([0 N_cams+1]); ylim([-eccentricity-2, eccentricity+2]);
wave_line = plot(ax2, 1:N_cams, zeros(1,N_cams),'-o',...
    'Color',[0.2 0.4 0.8],'LineWidth',2.5,'MarkerSize',7,...
    'MarkerFaceColor',[0.2 0.4 0.8]);
plot(ax2, [0.5 N_cams+0.5],[0 0],'k--','LineWidth',0.5);

% ── Plate height vs time ──────────────────────────────────────────────
ax3 = subplot(2,2,4); hold on; grid on; box on;
xlabel('time [s]'); ylabel('plate height y [mm]');
title('Plate motion vs time (each plate is phase-shifted SHM)','FontSize',11,'FontWeight','bold');
xlim([0 total_time]); ylim([-eccentricity-2, eccentricity+2]);
hist_lines = gobjects(N_cams,1);
for i = 1:N_cams
    hist_lines(i) = plot(ax3, NaN, NaN,'-','Color',cam_cols(i,:),'LineWidth',1.2);
end
% history buffers
t_hist = [];
y_hist = nan(N_cams, 0);

%% ── ANIMATION LOOP ─────────────────────────────────────────────────────
robot_x = 0;
fprintf('Running animation for %g seconds (%d frames)...\n',total_time,total_time*fps);

t_start = 0;
for t = t_start:dt:total_time
    if ~ishandle(fig), break; end

    theta_shaft = omega * t;     % shaft rotation angle [rad]
    robot_x = robot_speed * t;   % robot translation [mm]

    % update each cam
    for i = 1:N_cams
        % This cam's phase angle in inertial frame
        phi_i = theta_shaft + (i-1)*phase_offset;

        % Cam centre (eccentric) position relative to shaft
        cx = cam_x(i) + 0;     % cam disc x is fixed; eccentricity offset within disc
        cy = shaft_y;
        cam_off_x = eccentricity * cos(phi_i);
        cam_off_y = eccentricity * sin(phi_i);
        cam_centre_x = cx + cam_off_x;
        cam_centre_y = cy + cam_off_y;

        % Cam outline
        outline_x = cam_centre_x + cam_radius*cos(th_circle);
        outline_y = cam_centre_y + cam_radius*sin(th_circle);
        set(cam_patches(i),'XData',outline_x,'YData',outline_y);
        set(cam_centres(i),'XData',cam_centre_x,'YData',cam_centre_y);

        % Plate: rests on TOP of cam → plate bottom at max y of cam
        plate_y_bottom = cam_centre_y + cam_radius;
        % plate position (height from baseline shaft_y + cam_radius)
        plate_height_signed = plate_y_bottom - (shaft_y + cam_radius);

        % Plate outline (small rectangle floating on cam)
        px = [cx-plate_width/2, cx+plate_width/2, cx+plate_width/2, cx-plate_width/2];
        py = [plate_y_bottom, plate_y_bottom, plate_y_bottom+plate_height, plate_y_bottom+plate_height];
        set(plate_patches(i),'XData',px,'YData',py);

        % Contact point dot (top of cam)
        set(contact_dots(i),'XData',cx,'YData',plate_y_bottom);

        % Update side plot wave shape
        wave_y(i) = plate_height_signed;   %#ok<AGROW>
    end

    % Update wave line (instantaneous wave shape)
    set(wave_line,'YData',wave_y);

    % Update history
    t_hist(end+1) = t;                              %#ok<AGROW>
    y_hist(:,end+1) = wave_y(:);                    %#ok<AGROW>
    for i = 1:N_cams
        set(hist_lines(i),'XData',t_hist,'YData',y_hist(i,:));
    end

    % Update robot body position
    set(robot_body,'Position',...
        [min(cam_x)-50+robot_x*0.05, body_y, max(cam_x)-min(cam_x)+100, body_height]);
    % Note: robot motion is shown reduced (×0.05) to keep it in frame for the demo

    % Steering wheels (front and back, follow robot)
    wh_th = linspace(0,2*pi,30);
    front_x = max(cam_x) + 60 + robot_x*0.05;
    back_x  = min(cam_x) - 30 + robot_x*0.05;
    set(front_wheel,'XData',front_x+wh_R*cos(wh_th),'YData',wh_R+wh_R*sin(wh_th));
    set(back_wheel, 'XData',back_x +wh_R*cos(wh_th),'YData',wh_R+wh_R*sin(wh_th));

    % Texts
    set(theta_text,'String',sprintf('θ_{shaft} = %.0f°  |  t = %.2f s',...
        mod(theta_shaft*180/pi,360), t));
    set(robot_x_text,'String',sprintf('Robot moved: %.1f mm  (real-world; on screen scaled ×0.05)',...
        robot_x));

    drawnow limitrate;
end

fprintf('Animation complete. Robot translation = %.1f mm in %.1f s\n',...
    robot_speed*total_time, total_time);

end
