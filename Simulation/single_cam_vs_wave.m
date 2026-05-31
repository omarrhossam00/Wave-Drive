function single_cam_vs_wave()
%SINGLE_CAM_VS_WAVE  Side-by-side comparison
%
% LEFT panel : ONE cam → ONE plate moves with SHM
% RIGHT panel: N cams (phase-shifted) → N plates form a TRAVELLING WAVE
%
% This visualises how the wave drive is built up from a single cam.

close all; clc;

%% ── PARAMETERS ─────────────────────────────────────────────────────────
N_cams       = 12;
spacing      = 35;
cam_radius   = 25;
eccentricity = 18;
shaft_radius = 6;
shaft_y      = 70;
plate_width  = 30;
plate_thick  = 6;

n_rpm        = 60;
omega        = n_rpm*2*pi/60;
total_time   = 5;
fps          = 30;
dt           = 1/fps;

phase_offset = 2*pi/N_cams;

%% ── FIGURE LAYOUT ──────────────────────────────────────────────────────
fig = figure('Name','Single Cam vs Full Wave Drive','NumberTitle','off',...
    'Position',[40 40 1600 850],'Color','w');

th_c = linspace(0,2*pi,60);

% ════════════════════════════════════════════════════════════════════
% LEFT: Single cam
% ════════════════════════════════════════════════════════════════════
ax_L = subplot(2,3,[1 4]); hold on; axis equal; grid on; box on;
title('SINGLE CAM (building block)','FontSize',12,'FontWeight','bold','Color',[0.10 0.35 0.75]);
view_lim = cam_radius + eccentricity + 25;
xlim([-view_lim view_lim]);
ylim([0 shaft_y + cam_radius + eccentricity + 30]);
xlabel('x [mm]'); ylabel('y [mm]');

% Vertical guides for plate slide
plot([-plate_width*1.5 -plate_width*1.5],[0 shaft_y+cam_radius+eccentricity+25],...
    'k--','LineWidth',0.6,'Color',[0.6 0.6 0.6]);
plot([+plate_width*1.5 +plate_width*1.5],[0 shaft_y+cam_radius+eccentricity+25],...
    'k--','LineWidth',0.6,'Color',[0.6 0.6 0.6]);
plot([-view_lim view_lim],[0 0],'-','Color',[0.4 0.4 0.4],'LineWidth',1.2);

% Shaft cross-section
fill(shaft_radius*cos(th_c),shaft_y+shaft_radius*sin(th_c),...
    [0.4 0.4 0.4],'EdgeColor','k','LineWidth',1);
plot(0,shaft_y,'+k','MarkerSize',12,'LineWidth',1.5);

% Cam patch
camL_patch = fill(NaN,NaN,[0.30 0.65 0.95],...
    'FaceAlpha',0.55,'EdgeColor',[0.10 0.35 0.75],'LineWidth',2.2);
camL_centre = plot(NaN,NaN,'o','MarkerSize',7,'MarkerFaceColor',[0.85 0.2 0.2],...
    'MarkerEdgeColor','k','LineWidth',1);
ecc_line = plot([0 NaN],[shaft_y NaN],'-','Color',[0.85 0.20 0.20],'LineWidth',2);
ref_tick = plot([0 NaN],[shaft_y NaN],'-','Color',[0.8 0.6 0.1],'LineWidth',1.5);

% Plate
plateL = fill(NaN,NaN,[0.30 0.34 0.42],'FaceAlpha',0.95,'EdgeColor','k','LineWidth',1);

% Annotations
thL_text = text(-view_lim+5, shaft_y+cam_radius+eccentricity+22,...
    'θ = 0°','FontSize',12,'FontWeight','bold','Color','b');
sL_text = text(-view_lim+5, shaft_y+cam_radius+eccentricity+12,...
    's = 0 mm','FontSize',11,'FontWeight','bold','Color',[0.30 0.34 0.42]);

% ════════════════════════════════════════════════════════════════════
% RIGHT: Wave drive (N cams)
% ════════════════════════════════════════════════════════════════════
ax_R = subplot(2,3,[2 3 5 6]); hold on; axis equal; grid on; box on;
title('WAVE DRIVE — N cams phase-shifted (each is the "single cam" repeated)',...
    'FontSize',12,'FontWeight','bold','Color',[0.10 0.55 0.30]);

cam_x = ((1:N_cams)-(N_cams+1)/2)*spacing;
xlim([min(cam_x)-50 max(cam_x)+50]);
ylim([0 shaft_y+cam_radius+eccentricity+30]);
xlabel('x along tank [mm]'); ylabel('y [mm]');

% Ground
plot([min(cam_x)-50 max(cam_x)+50],[0 0],'-','Color',[0.4 0.4 0.4],'LineWidth',1.2);

% Shaft (long line)
plot([min(cam_x)-spacing max(cam_x)+spacing],[shaft_y shaft_y],...
    '-','Color',[0.3 0.3 0.3],'LineWidth',2);

% Allocate handles
camR_patches = gobjects(N_cams,1);
plateR = gobjects(N_cams,1);
shaftR = gobjects(N_cams,1);
cam_cols = hsv(N_cams);
for i = 1:N_cams
    camR_patches(i) = fill(NaN,NaN,cam_cols(i,:),...
        'FaceAlpha',0.55,'EdgeColor',cam_cols(i,:)*0.6,'LineWidth',1.5);
    plateR(i) = fill(NaN,NaN,[0.30 0.34 0.42],'FaceAlpha',0.95,...
        'EdgeColor','k','LineWidth',0.6);
end
% Shaft circles at each cam
for i = 1:N_cams
    shaftR(i) = fill(cam_x(i)+shaft_radius*cos(th_c),...
        shaft_y+shaft_radius*sin(th_c),...
        [0.4 0.4 0.4],'EdgeColor','k','LineWidth',0.8);
end

% Wave line connecting plate tops
wave_line = plot(NaN,NaN,'-o','Color',[0.85 0.2 0.6],'LineWidth',2,...
    'MarkerSize',6,'MarkerFaceColor',[0.85 0.2 0.6]);

thR_text = text(min(cam_x)-40, shaft_y+cam_radius+eccentricity+25,...
    'θ_{shaft} = 0°','FontSize',12,'FontWeight','bold','Color','b');

%% ── ANIMATION LOOP ────────────────────────────────────────────────────
fprintf('=================================================\n');
fprintf(' SINGLE CAM vs WAVE DRIVE - SIDE BY SIDE\n');
fprintf('=================================================\n');
fprintf(' LEFT  : 1 cam → 1 plate (SHM)\n');
fprintf(' RIGHT : %d cams → %d plates (travelling wave)\n', N_cams, N_cams);
fprintf('=================================================\n\n');

t_vec = 0:dt:total_time;
fprintf('Running animation...\n');

for k = 1:length(t_vec)
    if ~ishandle(fig), break; end
    t = t_vec(k);
    theta_shaft = omega*t;

    % ── LEFT: single cam ──────────────────────────────────────────────
    cx = eccentricity*cos(theta_shaft);
    cy = shaft_y + eccentricity*sin(theta_shaft);
    set(camL_patch,'XData',cx+cam_radius*cos(th_c),'YData',cy+cam_radius*sin(th_c));
    set(camL_centre,'XData',cx,'YData',cy);
    set(ecc_line,'XData',[0 cx],'YData',[shaft_y cy]);
    tick_x = cx+cam_radius*cos(theta_shaft);
    tick_y = cy+cam_radius*sin(theta_shaft);
    set(ref_tick,'XData',[cx tick_x],'YData',[cy tick_y]);
    plate_y_bot = cy+cam_radius;
    px = [-plate_width*1.5/2, plate_width*1.5/2, plate_width*1.5/2, -plate_width*1.5/2];
    py = [plate_y_bot,plate_y_bot,plate_y_bot+plate_thick,plate_y_bot+plate_thick];
    set(plateL,'XData',px,'YData',py);
    s_now = eccentricity*sin(theta_shaft);
    set(thL_text,'String',sprintf('θ = %.0f°',mod(theta_shaft*180/pi,360)));
    set(sL_text,'String',sprintf('s = %+.2f mm',s_now));

    % ── RIGHT: N cams → wave ──────────────────────────────────────────
    wave_y_pts = zeros(1,N_cams);
    for i = 1:N_cams
        phi_i = theta_shaft + (i-1)*phase_offset;
        cxi = cam_x(i) + eccentricity*cos(phi_i);
        cyi = shaft_y + eccentricity*sin(phi_i);
        set(camR_patches(i),'XData',cxi+cam_radius*cos(th_c),...
            'YData',cyi+cam_radius*sin(th_c));
        plate_y_bot = cyi+cam_radius;
        px = [cam_x(i)-plate_width/2,cam_x(i)+plate_width/2,...
              cam_x(i)+plate_width/2,cam_x(i)-plate_width/2];
        py = [plate_y_bot,plate_y_bot,plate_y_bot+plate_thick,plate_y_bot+plate_thick];
        set(plateR(i),'XData',px,'YData',py);
        wave_y_pts(i) = plate_y_bot;
    end
    set(wave_line,'XData',cam_x,'YData',wave_y_pts);
    set(thR_text,'String',sprintf('θ_{shaft} = %.0f°  |  Wave moves →',...
        mod(theta_shaft*180/pi,360)));

    drawnow limitrate;
end

fprintf('Done. The wave drive = N copies of the single cam, each phase-shifted.\n');

end
