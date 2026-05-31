function single_cam_simulation()
%SINGLE_CAM_SIMULATION  Animated single eccentric cam with scrolling oscilloscope plots
%
% Building block of the wave drive: ONE eccentric cam → ONE plate moves with SHM.
% The s/v/a plots scroll horizontally like a real oscilloscope.

close all; clc;

%% ── PARAMETERS ─────────────────────────────────────────────────────────
cam_radius   = 30;
eccentricity = 18;
shaft_radius = 6;
shaft_y      = 80;
plate_width  = 90;
plate_thick  = 8;

n_rpm        = 60;
omega        = n_rpm*2*pi/60;
total_time   = 8;
fps          = 40;
dt           = 1/fps;
window_T     = 3.0;       % visible time-window of scrolling plots [s]

%% ── PRE-COMPUTE ─────────────────────────────────────────────────────────
N = ceil(total_time/dt) + 1;
t_vec = (0:N-1)*dt;
theta_vec = omega*t_vec;
s_full = eccentricity * sin(theta_vec);
v_full = eccentricity*omega*cos(theta_vec);
a_full = -eccentricity*omega^2*sin(theta_vec);

s_max = eccentricity;
v_max = eccentricity*omega;
a_max = eccentricity*omega^2;

fprintf('=================================================\n');
fprintf(' SINGLE ECCENTRIC CAM SIMULATION\n');
fprintf('=================================================\n');
fprintf(' Cam radius:      %g mm   |   Eccentricity: %g mm\n', cam_radius, eccentricity);
fprintf(' Speed:           %g rpm  (ω = %.2f rad/s)\n', n_rpm, omega);
fprintf(' Stroke (p-p):    %g mm\n', 2*eccentricity);
fprintf(' Max velocity:    %.2f mm/s\n', v_max);
fprintf(' Max acceleration: %.2f mm/s² (= %.2f g)\n', a_max, a_max/9810);
fprintf('=================================================\n\n');

%% ── COLOURS ────────────────────────────────────────────────────────────
COL_S    = [0.10 0.40 0.90];   % bright blue
COL_V    = [0.00 0.65 0.30];   % bright green
COL_A    = [0.90 0.20 0.20];   % bright red
COL_PHA  = [0.55 0.20 0.75];   % purple
COL_CAM  = [0.30 0.65 0.95];
COL_ECC  = [0.90 0.25 0.25];
COL_TICK = [0.95 0.65 0.10];
COL_PLT  = [0.25 0.30 0.40];
BG_PLOT  = [0.97 0.98 1.00];   % very light blue for plot bg

%% ── FIGURE LAYOUT ──────────────────────────────────────────────────────
fig = figure('Name','Single Eccentric Cam — Wave Drive Building Block',...
    'NumberTitle','off','Position',[60 40 1600 850],'Color','w');

% ── Side view (left, large) ───────────────────────────────────────────
ax1 = subplot(2,3,[1 4]); hold on; axis equal; grid on; box on;
view_lim = cam_radius + eccentricity + 30;
xlim([-view_lim view_lim]);
ylim([0 shaft_y + cam_radius + eccentricity + 35]);
xlabel('x [mm]','FontSize',10);
ylabel('y [mm]','FontSize',10);
title('Side View — Cam + Plate (Flat Follower)','FontSize',12,'FontWeight','bold');
set(ax1,'GridAlpha',0.15);

plot([-view_lim view_lim],[0 0],'-','Color',[0.35 0.35 0.35],'LineWidth',1.3);
plot([-plate_width/2 -plate_width/2],[0 shaft_y+cam_radius+eccentricity+25],...
    'k--','LineWidth',0.7);
plot([+plate_width/2 +plate_width/2],[0 shaft_y+cam_radius+eccentricity+25],...
    'k--','LineWidth',0.7);

% Shaft
th_c = linspace(0,2*pi,60);
fill(shaft_radius*cos(th_c), shaft_y + shaft_radius*sin(th_c),...
    [0.4 0.4 0.4],'EdgeColor','k','LineWidth',1.2);
plot(0, shaft_y, '+k','MarkerSize',12,'LineWidth',1.5);

% Animated handles
cam_patch = fill(NaN, NaN, COL_CAM,'FaceAlpha',0.65,...
    'EdgeColor',COL_CAM*0.5,'LineWidth',2.8);
cam_centre = plot(NaN, NaN,'o','MarkerSize',9,...
    'MarkerFaceColor',COL_ECC,'MarkerEdgeColor','k','LineWidth',1.5);
ecc_line = plot([0 NaN],[shaft_y NaN],'-','Color',COL_ECC,'LineWidth',2.5);
ref_tick = plot([NaN NaN],[NaN NaN],'-','Color',COL_TICK,'LineWidth',2.2);
plate_patch = fill(NaN, NaN, COL_PLT,'FaceAlpha',0.95,'EdgeColor','k','LineWidth',1.3);
contact_dot = plot(NaN, NaN,'o','MarkerSize',9,...
    'MarkerFaceColor','y','MarkerEdgeColor','k','LineWidth',1.3);

% Labels
theta_text = text(-view_lim+5, shaft_y+cam_radius+eccentricity+25,...
    'θ = 0°','FontSize',13,'FontWeight','bold','Color',COL_S);
s_text = text(-view_lim+5, shaft_y+cam_radius+eccentricity+13,...
    's = 0 mm','FontSize',11,'FontWeight','bold','Color',COL_PLT);

% ── s vs t (top right) ────────────────────────────────────────────────
ax2 = subplot(2,3,2); hold on; box on;
set(ax2,'Color',BG_PLOT,'GridLineStyle',':','GridAlpha',0.3);
grid on;
xlim([0 window_T]); ylim([-s_max*1.20  s_max*1.20]);
ylabel('s [mm]','FontSize',11,'FontWeight','bold');
title('Plate Displacement   s = ε sin(ωt)','FontSize',11,'FontWeight','bold','Color',COL_S);
plot([0 window_T],[0 0],'k-','LineWidth',0.6);
plot([0 window_T],[ s_max  s_max],':','Color',[0.5 0.5 0.5],'LineWidth',0.8);
plot([0 window_T],[-s_max -s_max],':','Color',[0.5 0.5 0.5],'LineWidth',0.8);
text(window_T*0.985, s_max,'+ε','FontSize',9,'Color',[0.4 0.4 0.4],'HorizontalAlignment','right');
text(window_T*0.985,-s_max,'-ε','FontSize',9,'Color',[0.4 0.4 0.4],'HorizontalAlignment','right');
disp_live = plot(NaN,NaN,'-','Color',COL_S,'LineWidth',3);
disp_dot = plot(NaN,NaN,'o','MarkerSize',11,'MarkerFaceColor',COL_S,...
    'MarkerEdgeColor','w','LineWidth',1.5);

% ── v vs t ────────────────────────────────────────────────────────────
ax3 = subplot(2,3,3); hold on; box on;
set(ax3,'Color',BG_PLOT,'GridLineStyle',':','GridAlpha',0.3);
grid on;
xlim([0 window_T]); ylim([-v_max*1.20  v_max*1.20]);
ylabel('v [mm/s]','FontSize',11,'FontWeight','bold');
title('Plate Velocity   v = εω cos(ωt)','FontSize',11,'FontWeight','bold','Color',COL_V);
plot([0 window_T],[0 0],'k-','LineWidth',0.6);
plot([0 window_T],[ v_max  v_max],':','Color',[0.5 0.5 0.5],'LineWidth',0.8);
plot([0 window_T],[-v_max -v_max],':','Color',[0.5 0.5 0.5],'LineWidth',0.8);
text(window_T*0.985, v_max,'+εω','FontSize',9,'Color',[0.4 0.4 0.4],'HorizontalAlignment','right');
text(window_T*0.985,-v_max,'-εω','FontSize',9,'Color',[0.4 0.4 0.4],'HorizontalAlignment','right');
vel_live = plot(NaN,NaN,'-','Color',COL_V,'LineWidth',3);
vel_dot = plot(NaN,NaN,'o','MarkerSize',11,'MarkerFaceColor',COL_V,...
    'MarkerEdgeColor','w','LineWidth',1.5);

% ── a vs t ────────────────────────────────────────────────────────────
ax4 = subplot(2,3,5); hold on; box on;
set(ax4,'Color',BG_PLOT,'GridLineStyle',':','GridAlpha',0.3);
grid on;
xlim([0 window_T]); ylim([-a_max*1.20  a_max*1.20]);
xlabel('time [s]','FontSize',10);
ylabel('a [mm/s²]','FontSize',11,'FontWeight','bold');
title('Plate Acceleration   a = -εω² sin(ωt)','FontSize',11,'FontWeight','bold','Color',COL_A);
plot([0 window_T],[0 0],'k-','LineWidth',0.6);
plot([0 window_T],[ a_max  a_max],':','Color',[0.5 0.5 0.5],'LineWidth',0.8);
plot([0 window_T],[-a_max -a_max],':','Color',[0.5 0.5 0.5],'LineWidth',0.8);
text(window_T*0.985, a_max,'+εω²','FontSize',9,'Color',[0.4 0.4 0.4],'HorizontalAlignment','right');
text(window_T*0.985,-a_max,'-εω²','FontSize',9,'Color',[0.4 0.4 0.4],'HorizontalAlignment','right');
acc_live = plot(NaN,NaN,'-','Color',COL_A,'LineWidth',3);
acc_dot = plot(NaN,NaN,'o','MarkerSize',11,'MarkerFaceColor',COL_A,...
    'MarkerEdgeColor','w','LineWidth',1.5);

% ── Phase plot (v vs s) ───────────────────────────────────────────────
ax5 = subplot(2,3,6); hold on; box on; axis equal;
set(ax5,'Color',BG_PLOT,'GridLineStyle',':','GridAlpha',0.3);
grid on;
xlim([-s_max*1.25 s_max*1.25]);
ylim([-v_max*1.25 v_max*1.25]);
xlabel('s [mm]','FontSize',10);
ylabel('v [mm/s]','FontSize',10);
title('Phase Plot — Trajectory Traces an Ellipse','FontSize',11,'FontWeight','bold','Color',COL_PHA);
plot([-s_max*1.25 s_max*1.25],[0 0],'k-','LineWidth',0.5);
plot([0 0],[-v_max*1.25 v_max*1.25],'k-','LineWidth',0.5);
% Ghost full ellipse (very faint to show target)
plot(s_full, v_full,':','Color',[0.7 0.6 0.8],'LineWidth',1.2);
phase_trail = plot(NaN,NaN,'-','Color',COL_PHA,'LineWidth',2.8);
phase_dot = plot(NaN,NaN,'o','MarkerSize',13,'MarkerFaceColor',COL_PHA,...
    'MarkerEdgeColor','w','LineWidth',1.8);

sgtitle(sprintf('Single Eccentric Cam   |   n=%g rpm   |   R=%g mm   |   ε=%g mm   |   stroke=%g mm',...
    n_rpm, cam_radius, eccentricity, 2*eccentricity),...
    'FontSize',13,'FontWeight','bold');

%% ── ANIMATION LOOP (with scrolling plots) ─────────────────────────────
fprintf('Running animation for %g seconds...\n', total_time);

for k = 1:N
    if ~ishandle(fig), break; end
    th = theta_vec(k);
    t_now = t_vec(k);

    % Cam centre
    cx = eccentricity*cos(th);
    cy = shaft_y + eccentricity*sin(th);

    % Cam outline
    cam_xs = cx + cam_radius*cos(th_c);
    cam_ys = cy + cam_radius*sin(th_c);
    set(cam_patch,'XData',cam_xs,'YData',cam_ys);
    set(cam_centre,'XData',cx,'YData',cy);
    set(ecc_line,'XData',[0 cx],'YData',[shaft_y cy]);

    % Reference tick rotates with shaft
    tick_x = cx + cam_radius*cos(th);
    tick_y = cy + cam_radius*sin(th);
    set(ref_tick,'XData',[cx tick_x],'YData',[cy tick_y]);

    % Plate
    plate_y_bot = cy + cam_radius;
    px = [-plate_width/2, plate_width/2, plate_width/2, -plate_width/2];
    py = [plate_y_bot, plate_y_bot, plate_y_bot+plate_thick, plate_y_bot+plate_thick];
    set(plate_patch,'XData',px,'YData',py);
    set(contact_dot,'XData',0,'YData',plate_y_bot);

    % Texts
    set(theta_text,'String',sprintf('θ = %.0f°',mod(th*180/pi,360)));
    set(s_text,'String',sprintf('s = %+.2f mm',s_full(k)));

    % ── SCROLLING PLOTS ──────────────────────────────────────────────
    % Determine visible time window
    if t_now <= window_T
        % Filling up phase: plot from 0 to t_now, axis stays at [0, window_T]
        idx_visible = 1:k;
        xlim_now = [0 window_T];
    else
        % Scrolling phase: window slides
        t_left = t_now - window_T;
        idx_visible = find(t_vec >= t_left & t_vec <= t_now);
        xlim_now = [t_left t_now];
    end

    set(disp_live,'XData',t_vec(idx_visible),'YData',s_full(idx_visible));
    set(vel_live, 'XData',t_vec(idx_visible),'YData',v_full(idx_visible));
    set(acc_live, 'XData',t_vec(idx_visible),'YData',a_full(idx_visible));

    set(disp_dot,'XData',t_now,'YData',s_full(k));
    set(vel_dot, 'XData',t_now,'YData',v_full(k));
    set(acc_dot, 'XData',t_now,'YData',a_full(k));

    set(ax2,'XLim',xlim_now);
    set(ax3,'XLim',xlim_now);
    set(ax4,'XLim',xlim_now);

    % Phase plot — show trail of last full period
    n_period = round((2*pi/omega)/dt);
    idx_phase = max(1,k-n_period):k;
    set(phase_trail,'XData',s_full(idx_phase),'YData',v_full(idx_phase));
    set(phase_dot,  'XData',s_full(k),'YData',v_full(k));

    drawnow limitrate;
end

fprintf('Done.\n');
end
