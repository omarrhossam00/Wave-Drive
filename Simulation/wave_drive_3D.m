function wave_drive_3D()
%WAVE_DRIVE_3D  3D animated simulation of the Wave Drive Tank
%
% Shows:
%   - Long camshaft running along the tank
%   - N circular eccentric cams (each phase-shifted)
%   - N plates riding on each cam, forming a travelling sinusoidal wave
%   - Robot body (tank), front steering wheels
%   - Ground plane

close all; clc;

%% ── PARAMETERS ─────────────────────────────────────────────────────────
N_cams       = 14;
spacing      = 30;            % mm between adjacent cams
cam_radius   = 22;            % cam disc base radius
eccentricity = 16;            % cam centre offset = wave amplitude
plate_w_x    = 26;            % plate length along x (small)
plate_w_z    = 80;            % plate width along z (across the tank)
plate_thick  = 6;             % plate thickness in y
shaft_R      = 5;             % shaft radius
shaft_y0     = 70;            % shaft height above ground
cam_thickness= 8;             % thickness in z (just for visualisation)

n_rpm        = 50;
omega        = n_rpm*2*pi/60;
total_time   = 6;
fps          = 30;
dt           = 1/fps;

% Phases
phase_offset = 2*pi/N_cams;

cam_x = ((1:N_cams) - (N_cams+1)/2) * spacing;     % positions along x
total_length = max(cam_x) - min(cam_x) + spacing;

% wavelength / wave speed
wavelength  = N_cams*spacing;
wave_speed  = wavelength*omega/(2*pi);
robot_speed = wave_speed;

fprintf('=================================================\n');
fprintf(' WAVE DRIVE TANK - 3D SIMULATION\n');
fprintf('=================================================\n');
fprintf(' Cams: %d   |   Spacing: %g mm   |   Eccentricity: %g mm\n',...
    N_cams, spacing, eccentricity);
fprintf(' Speed: %g rpm  →  Wave speed = %.1f mm/s\n', n_rpm, wave_speed);
fprintf('=================================================\n\n');

%% ── FIGURE SETUP ──────────────────────────────────────────────────────
fig = figure('Name','Wave Drive Tank — 3D Simulation','NumberTitle','off',...
    'Position',[40 30 1600 900],'Color','w');

% Main 3D axis
ax = subplot(2,3,[1 2 4 5]);
hold on; grid on; box on; axis equal;
view(ax, 35, 22);
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
title('Wave Drive Tank — 3D View','FontSize',13,'FontWeight','bold');
xlim([min(cam_x)-100, max(cam_x)+100]);
ylim([-20, shaft_y0 + cam_radius + eccentricity + 50]);
zlim([-plate_w_z/2-30, plate_w_z/2+30]);
lighting gouraud
camlight('headlight')
material dull

% ── GROUND ────────────────────────────────────────────────────────────
[Xg,Zg] = meshgrid(linspace(min(cam_x)-200,max(cam_x)+200,20),...
                   linspace(-plate_w_z,plate_w_z,8));
Yg = zeros(size(Xg));
surf(ax, Xg, Yg, Zg,'FaceColor',[0.85 0.82 0.78],'EdgeColor',[0.6 0.55 0.5],...
    'FaceAlpha',0.5,'EdgeAlpha',0.3);

% ── SHAFT (long cylinder along x at y=shaft_y0) ───────────────────────
[xc,yc,zc] = cylinder(shaft_R, 18);
% Cylinder is along z by default → rotate so axis is along x
% Standard: cylinder(r,n) gives unit-height cylinder along z
xc = xc * 1; zc = zc;            % keep
% Build manually: shaft from x_min to x_max
shaft_x_range = [min(cam_x)-spacing/2, max(cam_x)+spacing/2];
phi = linspace(0,2*pi,24);
[Xsh, PHIs] = meshgrid(shaft_x_range, phi);
Ysh = shaft_y0 + shaft_R*cos(PHIs);
Zsh = shaft_R*sin(PHIs);
surf(ax, Xsh, Ysh, Zsh, 'FaceColor',[0.5 0.5 0.5],'EdgeColor','none');

% ── CAMS, PLATES, ROBOT BODY (handles for animation) ──────────────────
cam_handles   = gobjects(N_cams,1);
plate_handles = gobjects(N_cams,1);
cam_cols = hsv(N_cams);

for i = 1:N_cams
    cam_handles(i)   = patch(ax, NaN, NaN, NaN,'r',...
        'FaceColor',cam_cols(i,:),'FaceAlpha',0.85,...
        'EdgeColor',cam_cols(i,:)*0.6,'LineWidth',0.8);
    plate_handles(i) = patch(ax, NaN, NaN, NaN, [0.25 0.28 0.35],...
        'FaceColor',[0.30 0.34 0.42],'EdgeColor','k','LineWidth',0.6,...
        'FaceAlpha',0.95);
end

% Robot body (a translucent box hovering above the cams)
body_y0 = shaft_y0 + cam_radius + eccentricity + 20;
body_height = 30;
body_w_z   = plate_w_z + 30;
body_handle = patch(ax, NaN, NaN, NaN, 'b',...
    'FaceColor',[0.78 0.86 0.95],'FaceAlpha',0.55,...
    'EdgeColor',[0.2 0.4 0.7],'LineWidth',1.5);

% Front and back steering wheels
wh_R = 16;
front_wh = gobjects(2,1);
back_wh  = gobjects(2,1);
for k = 1:2
    front_wh(k) = patch(ax, NaN, NaN, NaN,[0.2 0.2 0.2],...
        'FaceColor',[0.18 0.18 0.18],'EdgeColor','k');
    back_wh(k)  = patch(ax, NaN, NaN, NaN,[0.2 0.2 0.2],...
        'FaceColor',[0.18 0.18 0.18],'EdgeColor','k');
end

% ── Side wave plot (top right) ────────────────────────────────────────
ax2 = subplot(2,3,3); hold on; grid on; box on;
xlabel('x along tank [mm]'); ylabel('plate height [mm]');
title('Wave shape (instantaneous)','FontSize',10,'FontWeight','bold');
xlim([min(cam_x)-spacing, max(cam_x)+spacing]);
ylim([-eccentricity-3, eccentricity+3]);
plot(ax2, [min(cam_x) max(cam_x)],[0 0],'k--');
wave_line = plot(ax2, cam_x, zeros(1,N_cams),'-o',...
    'Color',[0.2 0.4 0.8],'LineWidth',2.5,'MarkerSize',7,...
    'MarkerFaceColor',[0.2 0.4 0.8]);

% ── Plate motion vs time (bottom right) ───────────────────────────────
ax3 = subplot(2,3,6); hold on; grid on; box on;
xlabel('time [s]'); ylabel('plate height y [mm]');
title('Plate height vs time (phase-shifted SHM)','FontSize',10,'FontWeight','bold');
xlim([0 total_time]); ylim([-eccentricity-3, eccentricity+3]);
hist_lines = gobjects(N_cams,1);
for i = 1:N_cams
    hist_lines(i) = plot(ax3, NaN, NaN,'-','Color',cam_cols(i,:),'LineWidth',1.1);
end

% Texts
sgt = sgtitle(sprintf('Wave Drive — N=%d cams, %g rpm, ε=%g mm', N_cams, n_rpm, eccentricity),...
    'FontSize',13,'FontWeight','bold');
status_text = annotation('textbox',[0.4 0.005 0.2 0.025],'String','t = 0',...
    'EdgeColor','none','HorizontalAlignment','center',...
    'FontSize',11,'FontWeight','bold','Color',[0.2 0.4 0.7]);

% Animation history
t_hist = [];
y_hist = zeros(N_cams,0);
wave_y = zeros(1,N_cams);

%% ── ANIMATION LOOP ────────────────────────────────────────────────────
robot_x_disp_scale = 0.10;   % visual scale for robot motion (real motion would slide off-screen)
fprintf('Running 3D animation...\n');

for t = 0:dt:total_time
    if ~ishandle(fig), break; end
    theta_shaft = omega*t;
    robot_x_real = robot_speed * t;
    robot_x_vis  = robot_x_real * robot_x_disp_scale;

    for i = 1:N_cams
        phi_i = theta_shaft + (i-1)*phase_offset;
        cam_off_x = eccentricity * cos(phi_i);
        cam_off_y = eccentricity * sin(phi_i);

        cam_cx = cam_x(i) + cam_off_x;
        cam_cy = shaft_y0 + cam_off_y;

        % Build cam disc (parametric polygon) extruded in z
        n_pts = 28;
        th = linspace(0,2*pi,n_pts);
        cx = cam_cx + cam_radius*cos(th);
        cy = cam_cy + cam_radius*sin(th);
        % Two faces: front (z = +half) and back (z = -half) + side
        z_pos = cam_thickness/2;
        z_neg = -cam_thickness/2;
        % Build a simple closed disc on the front side (visible)
        fX = [cx, fliplr(cx)];
        fY = [cy, fliplr(cy)];
        fZ = [z_pos*ones(1,n_pts), z_neg*ones(1,n_pts)];
        % Just plot front face for clarity (cheaper)
        set(cam_handles(i), 'XData', cx', 'YData', cy', 'ZData', z_pos*ones(n_pts,1));

        % Plate (rectangular box on top of cam)
        plate_y_bot = cam_cy + cam_radius;
        plate_y_top = plate_y_bot + plate_thick;
        % box vertices
        x_min = cam_x(i)-plate_w_x/2; x_max = cam_x(i)+plate_w_x/2;
        z_min = -plate_w_z/2;         z_max = plate_w_z/2;
        % Plate top face only (visible)
        plate_X = [x_min x_max x_max x_min];
        plate_Y = [plate_y_top plate_y_top plate_y_top plate_y_top];
        plate_Z = [z_min z_min z_max z_max];
        set(plate_handles(i),'XData',plate_X','YData',plate_Y','ZData',plate_Z');

        wave_y(i) = plate_y_bot - (shaft_y0 + cam_radius);
    end

    % update wave plot
    set(wave_line,'YData',wave_y);

    % history update
    t_hist(end+1) = t;                  %#ok<AGROW>
    y_hist(:,end+1) = wave_y(:);        %#ok<AGROW>
    for i = 1:N_cams
        set(hist_lines(i),'XData',t_hist,'YData',y_hist(i,:));
    end

    % robot body
    bx_min = min(cam_x)-40+robot_x_vis;
    bx_max = max(cam_x)+40+robot_x_vis;
    bx_top_X = [bx_min bx_max bx_max bx_min];
    bx_top_Y = [body_y0+body_height body_y0+body_height body_y0+body_height body_y0+body_height];
    bx_top_Z = [-body_w_z/2 -body_w_z/2 body_w_z/2 body_w_z/2];
    set(body_handle,'XData',bx_top_X','YData',bx_top_Y','ZData',bx_top_Z');

    % steering wheels (front and back, two per axle)
    wh_th = linspace(0,2*pi,20);
    for k = 1:2
        side = (k-1.5)*body_w_z*0.85;     % ±side
        front_x_c = max(cam_x)+50+robot_x_vis;
        back_x_c  = min(cam_x)-50+robot_x_vis;
        set(front_wh(k), 'XData',(front_x_c+wh_R*cos(wh_th))',...
            'YData',(wh_R+wh_R*sin(wh_th))','ZData',side*ones(numel(wh_th),1));
        set(back_wh(k),  'XData',(back_x_c +wh_R*cos(wh_th))',...
            'YData',(wh_R+wh_R*sin(wh_th))','ZData',side*ones(numel(wh_th),1));
    end

    set(status_text,'String',sprintf('t = %.2f s  |  θ = %.0f°  |  Robot displacement = %.0f mm',...
        t, mod(theta_shaft*180/pi,360), robot_x_real));

    drawnow limitrate;
end

fprintf('Done. Total robot displacement (real) = %.1f mm = %.2f m\n',...
    robot_speed*total_time, robot_speed*total_time/1000);

end
