%% ATFIDP Flight Computer - Flight Animation
% Visualizes the simulated flight state using the generated
% flight_simulation.mat data.

clear;
clc;
close all;

%% Project paths

project_root = fileparts(fileparts(mfilename('fullpath')));

data_file = fullfile( ...
    project_root, ...
    'data', ...
    'flight_simulation.mat');

results_dir = fullfile(project_root, 'results');

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

%% Load simulation data

load(data_file, 'sim', 'flight_data');

fprintf('ATFIDP Flight Animation\n');
fprintf('-----------------------\n');
fprintf('Loaded simulation data successfully.\n');
fprintf('Duration : %.1f s\n', sim.duration);
fprintf('Samples  : %d\n', numel(sim.time));

%% Extract data

time = flight_data.timestamp_s;
altitude = flight_data.altitude_m;
velocity = flight_data.velocity_mps;
temperature = flight_data.temperature_c;
battery = flight_data.battery_v;
status = flight_data.status;

%% Animation limits

altitude_min = min(altitude);
altitude_max = max(altitude);

altitude_margin = 0.10 * (altitude_max - altitude_min);

if altitude_margin == 0
    altitude_margin = 100;
end

y_min = altitude_min - altitude_margin;
y_max = altitude_max + altitude_margin;

%% Create figure

fig = figure( ...
    'Name', 'ATFIDP Flight Computer Animation', ...
    'NumberTitle', 'off', ...
    'Color', 'white', ...
    'Position', [100 100 1200 700]);

%% Flight view

ax1 = subplot(1, 2, 1);

plot(ax1, time, altitude, 'LineWidth', 1.2);
grid(ax1, 'on');
hold(ax1, 'on');

xlabel(ax1, 'Time [s]');
ylabel(ax1, 'Altitude [m]');
title(ax1, 'Simulated Flight Profile');

xlim(ax1, [time(1) time(end)]);
ylim(ax1, [y_min y_max]);

flight_marker = plot( ...
    ax1, ...
    time(1), ...
    altitude(1), ...
    'o', ...
    'MarkerSize', 10, ...
    'MarkerFaceColor', 'auto');

%% Telemetry / health panel

ax2 = subplot(1, 2, 2);

axis(ax2, 'off');
xlim(ax2, [0 1]);
ylim(ax2, [0 1]);

title(ax2, 'ATFIDP Flight Computer Telemetry');

telemetry_text = text( ...
    ax2, ...
    0.05, ...
    0.85, ...
    '', ...
    'FontSize', 13, ...
    'VerticalAlignment', 'top', ...
    'FontName', 'Consolas');

%% Animation

for k = 1:length(time)

    %% Update flight marker

    set( ...
        flight_marker, ...
        'XData', time(k), ...
        'YData', altitude(k));

    %% Determine health state

    switch status(k)

        case 0
            status_text = 'OK';

        case 1
            status_text = 'WARNING';

        case 2
            status_text = 'CRITICAL';

        otherwise
            status_text = 'UNKNOWN';

    end

    %% Update telemetry display

    telemetry_string = sprintf( ...
        ['Time          : %6.1f s\n\n' ...
         'Altitude      : %8.2f m\n' ...
         'Velocity      : %8.2f m/s\n' ...
         'Temperature   : %8.2f deg C\n' ...
         'Battery       : %8.2f V\n\n' ...
         'Health Status : %s'], ...
         time(k), ...
         altitude(k), ...
         velocity(k), ...
         temperature(k), ...
         battery(k), ...
         status_text);

    set( ...
        telemetry_text, ...
        'String', telemetry_string);

    %% Update figure

    drawnow;

    %% Animation speed

    pause(0.02);

end

fprintf('\nAnimation completed successfully.\n');

%% Save final animation frame

figures_dir = fullfile(project_root, 'results', 'figures');

if ~exist(figures_dir, 'dir')
    mkdir(figures_dir);
end

saveas(fig, fullfile(figures_dir, 'ATFIDP_Flight_Animation.png'));

fprintf('Animation figure saved to: %s\n', ...
    fullfile(figures_dir, 'ATFIDP_Flight_Animation.png'));