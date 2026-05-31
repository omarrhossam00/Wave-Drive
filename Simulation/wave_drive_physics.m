function wave_drive_physics()
%WAVE_DRIVE_PHYSICS  Analyse the propulsion physics of the wave drive
%
% This script answers: WHY does the wave drive move forward?
%
% At any instant, only some plates are pressed against the ground (those at
% the bottom of their cycle). These plates are stationary in vertical motion
% momentarily, but the WAVE itself moves backward along the tank.
%
% Equivalently: in the ground's reference frame, contact points sweep
% backward → ground exerts forward friction → tank moves forward.
%
% This script visualises:
%   1. Each plate's vertical position vs time (sinusoidal, phase-shifted)
%   2. WHICH plate is in contact with ground at each instant
%   3. The "envelope" of the wave that touches the ground
%   4. Speed analysis: theoretical robot speed vs cam parameters

close all; clc;

%% ── PARAMETERS ─────────────────────────────────────────────────────────
N_cams       = 12;
spacing      = 35;        % mm
eccentricity = 18;        % mm (wave amplitude)
n_rpm        = 60;
omega        = n_rpm*2*pi/60;
total_time   = 4;
dt           = 0.005;

cam_x = ((1:N_cams) - (N_cams+1)/2) * spacing;
phase_offset = 2*pi/N_cams;
wavelength = N_cams*spacing;
wave_speed = wavelength*omega/(2*pi);

%% ── FIGURE LAYOUT ──────────────────────────────────────────────────────
fig = figure('Name','Wave Drive Physics Analysis','NumberTitle','off',...
    'Position',[60 30 1500 850],'Color','w');

% ── Top panel: travelling wave ────────────────────────────────────────
ax1 = subplot(3,2,[1 2]); hold on; grid on; box on;
xlim([min(cam_x)-30, max(cam_x)+30]);
ylim([-eccentricity-5, eccentricity+5]);
xlabel('x along tank [mm]'); ylabel('plate height [mm]');
title('Wave shape vs time — see the wave move along the tank',...
    'FontSize',12,'FontWeight','bold');

% ground line at minimum (− eccentricity)
ground_y = -eccentricity;
plot([min(cam_x)-50, max(cam_x)+50],[ground_y ground_y],'-','Color',[0.6 0.4 0.2],'LineWidth',2);
text(min(cam_x)-25,ground_y+1.5,'ground','Color',[0.6 0.4 0.2],'FontSize',9);

% Wave at multiple time snapshots (faded)
n_ghosts = 5;
ghost_t = linspace(0, 2*pi/omega/2, n_ghosts);   % half a cam revolution
for k = 1:n_ghosts
    th_g = omega*ghost_t(k);
    y_g = eccentricity*sin(th_g + (0:N_cams-1)*phase_offset);
    plot(cam_x, y_g, '-','Color',[0.6 0.6 0.6 0.3],'LineWidth',1);
end

% Live wave
wave_h = plot(ax1, cam_x, zeros(1,N_cams), '-o',...
    'Color',[0.2 0.4 0.8],'LineWidth',2.5,'MarkerSize',9,...
    'MarkerFaceColor',[0.2 0.4 0.8]);

% Highlight the contact plates (those at minimum y)
contact_h = plot(ax1, NaN, NaN,'o','MarkerSize',13,...
    'MarkerFaceColor','r','MarkerEdgeColor','k','LineWidth',1.5);

% Velocity arrow showing wave direction
wave_dir = annotation('arrow',[0.45 0.55],[0.85 0.85],...
    'Color',[0.85 0.2 0.2],'LineWidth',2.5);
wave_label = text(ax1, 0, eccentricity+3, '',...
    'Color',[0.85 0.2 0.2],'FontSize',11,'FontWeight','bold','HorizontalAlignment','center');

% ── Middle panel: each plate's height vs time ─────────────────────────
ax2 = subplot(3,2,3); hold on; grid on; box on;
xlim([0 total_time]); ylim([-eccentricity-3, eccentricity+3]);
xlabel('time [s]'); ylabel('plate height [mm]');
title('Each plate is sinusoidal, phase-shifted','FontSize',11,'FontWeight','bold');
plot(ax2, [0 total_time],[ground_y ground_y],'-','Color',[0.6 0.4 0.2],'LineWidth',1.5);
plate_cols = hsv(N_cams);
plate_lines = gobjects(N_cams,1);
for i = 1:N_cams
    plate_lines(i) = plot(ax2, NaN, NaN,'-','Color',plate_cols(i,:),'LineWidth',1.3);
end
% time cursor
time_cursor = plot(ax2, [0 0], [-eccentricity-3, eccentricity+3], 'k--','LineWidth',1);

% ── Right middle: contact mask (raster) ──────────────────────────────
ax3 = subplot(3,2,4); hold on; box on;
xlabel('time [s]'); ylabel('plate index');
title('Which plates are in contact (touching ground)','FontSize',11,'FontWeight','bold');
xlim([0 total_time]); ylim([0.5 N_cams+0.5]);
% Pre-compute the contact mask
t_vec = 0:dt:total_time;
contact_threshold = -eccentricity*0.85;   % within 15% of bottom
contact_mat = false(N_cams, length(t_vec));
for k = 1:length(t_vec)
    th_now = omega*t_vec(k);
    y_now = eccentricity*sin(th_now + (0:N_cams-1)*phase_offset);
    contact_mat(:,k) = y_now < contact_threshold;
end
% Display as image
imagesc(ax3, t_vec, 1:N_cams, double(contact_mat));
colormap(ax3,[1 1 1; 1 0.4 0.4]);   % white = lift, red = contact
caxis(ax3,[0 1]);
% raster cursor
raster_cursor = plot(ax3,[0 0],[0.5 N_cams+0.5],'k--','LineWidth',1.5);

% ── Bottom: speed analysis ────────────────────────────────────────────
ax4 = subplot(3,2,[5 6]); hold on; grid on; box on;
xlabel('camshaft speed [rpm]'); ylabel('robot speed [mm/s]');
title('Theoretical robot speed vs camshaft speed','FontSize',11,'FontWeight','bold');
n_test = 0:10:300;
v_test = (wavelength * (n_test*2*pi/60))/(2*pi);
plot(ax4, n_test, v_test,'-','Color',[0.2 0.5 0.2],'LineWidth',2);
% mark current operating point
op_pt = plot(ax4, n_rpm, wave_speed,'o','MarkerSize',12,...
    'MarkerFaceColor',[1 0.5 0],'MarkerEdgeColor','k','LineWidth',1.5);
text(ax4, n_rpm+5, wave_speed-5,...
    sprintf('  n=%g rpm\n  v=%.1f mm/s\n   = %.2f m/s',n_rpm,wave_speed,wave_speed/1000),...
    'FontSize',10,'FontWeight','bold');

% Also annotate formula
text(ax4, 10, max(v_test)*0.85,...
    sprintf('v_{robot} = (N_{cams} × spacing × ω) / (2π)\n            = wavelength × frequency'),...
    'FontSize',10,'FontName','FixedWidth','BackgroundColor',[0.96 0.98 0.92],...
    'EdgeColor',[0.5 0.7 0.5]);

%% ── ANIMATION LOOP ────────────────────────────────────────────────────
fprintf('Wave drive physics simulation running...\n');
plate_history = nan(N_cams, length(t_vec));

for k = 1:length(t_vec)
    if ~ishandle(fig), break; end
    t = t_vec(k);
    th_now = omega*t;
    y_now = eccentricity*sin(th_now + (0:N_cams-1)*phase_offset);
    plate_history(:,k) = y_now(:);

    % Update top wave
    set(wave_h,'YData',y_now);
    % contact dots
    in_contact = y_now < contact_threshold;
    if any(in_contact)
        set(contact_h,'XData',cam_x(in_contact),'YData',y_now(in_contact));
    else
        set(contact_h,'XData',NaN,'YData',NaN);
    end

    % Wave direction annotation
    % Wave moves with phase velocity = ωλ/(2π)
    % As θ increases by Δ, plate y at position x peaks at (x where φ_i+Δ = π/2)
    % Phase advances → wave moves in +x direction
    set(wave_label,'String',sprintf('Wave →  v_{wave} = %.0f mm/s    (Robot moves opposite ←)',...
        wave_speed));

    % Plate lines
    if k > 1
        for i = 1:N_cams
            set(plate_lines(i),'XData',t_vec(1:k),'YData',plate_history(i,1:k));
        end
    end
    set(time_cursor,'XData',[t t]);
    set(raster_cursor,'XData',[t t]);

    drawnow limitrate;
end

fprintf('Done. Wave parameters:\n');
fprintf('  Wavelength = %g mm\n', wavelength);
fprintf('  Wave speed = %.2f mm/s = %.3f m/s\n', wave_speed, wave_speed/1000);
fprintf('  Period     = %.3f s\n', 2*pi/omega);
fprintf('\nKey insight: at any instant, ~%d plates touch the ground.\n',...
    round(N_cams/3));
fprintf('As the shaft rotates, contact points sweep BACKWARD relative\n');
fprintf('to the tank, dragging the ground backward → tank moves FORWARD.\n');

end
