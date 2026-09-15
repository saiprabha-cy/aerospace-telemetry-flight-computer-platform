%% ATFIDP - OpenRocket Flight Analysis

clear;
clc;
close all;

%% Project paths

project_root = fileparts(fileparts(mfilename('fullpath')));

data_file = fullfile( ...
    project_root, ...
    'data', ...
    'openrocket_flight.mat');

results_dir = fullfile(project_root, 'results', 'figures');

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

%% Load OpenRocket data

load(data_file, 'T');

fprintf('ATFIDP OpenRocket Flight Analysis\n');
fprintf('---------------------------------\n');

fprintf('Samples: %d\n\n', height(T));

%% Extract trajectory data

time = T.x_Time_s_;
altitude = T.Altitude_m_;
vertical_velocity = T.VerticalVelocity_m_s_;
vertical_acceleration = T.VerticalAcceleration_m_s__;
total_velocity = T.TotalVelocity_m_s_;
mach = T.MachNumber___;

%% Calculate key flight parameters

[max_altitude, altitude_idx] = max(altitude);
[max_velocity, velocity_idx] = max(total_velocity);
[max_acceleration, acceleration_idx] = max(vertical_acceleration);
[max_mach, mach_idx] = max(mach);

time_apogee = time(altitude_idx);
time_max_velocity = time(velocity_idx);
time_max_acceleration = time(acceleration_idx);
time_max_mach = time(mach_idx);

flight_duration = time(end);

%% Display results

fprintf('Flight Results\n');
fprintf('--------------\n');

fprintf('Flight duration       : %.2f s\n', flight_duration);
fprintf('Apogee altitude       : %.2f m\n', max_altitude);
fprintf('Time to apogee        : %.2f s\n', time_apogee);
fprintf('Maximum velocity      : %.2f m/s\n', max_velocity);
fprintf('Time of max velocity  : %.2f s\n', time_max_velocity);
fprintf('Maximum acceleration  : %.2f m/s^2\n', max_acceleration);
fprintf('Time of max accel.    : %.2f s\n', time_max_acceleration);
fprintf('Maximum Mach number   : %.3f\n', max_mach);
fprintf('Time of max Mach      : %.2f s\n', time_max_mach);

%% Plot 1 - Altitude

fig1 = figure;

plot(time, altitude, 'LineWidth', 1.5);
grid on;

xlabel('Time [s]');
ylabel('Altitude [m]');
title('ATFIDP OpenRocket - Altitude');

saveas(fig1, ...
    fullfile(results_dir, 'OpenRocket_Altitude.png'));

%% Plot 2 - Velocity

fig2 = figure;

plot(time, total_velocity, 'LineWidth', 1.5);
grid on;

xlabel('Time [s]');
ylabel('Velocity [m/s]');
title('ATFIDP OpenRocket - Total Velocity');

saveas(fig2, ...
    fullfile(results_dir, 'OpenRocket_Velocity.png'));

%% Plot 3 - Acceleration

fig3 = figure;

plot(time, vertical_acceleration, 'LineWidth', 1.5);
grid on;

xlabel('Time [s]');
ylabel('Acceleration [m/s^2]');
title('ATFIDP OpenRocket - Vertical Acceleration');

saveas(fig3, ...
    fullfile(results_dir, 'OpenRocket_Acceleration.png'));

%% Plot 4 - Mach number

fig4 = figure;

plot(time, mach, 'LineWidth', 1.5);
grid on;

xlabel('Time [s]');
ylabel('Mach');
title('ATFIDP OpenRocket - Mach Number');

saveas(fig4, ...
    fullfile(results_dir, 'OpenRocket_Mach.png'));

%% Save analysis results

analysis.max_altitude = max_altitude;
analysis.time_apogee = time_apogee;
analysis.max_velocity = max_velocity;
analysis.time_max_velocity = time_max_velocity;
analysis.max_acceleration = max_acceleration;
analysis.time_max_acceleration = time_max_acceleration;
analysis.max_mach = max_mach;
analysis.time_max_mach = time_max_mach;
analysis.flight_duration = flight_duration;

save( ...
    fullfile(project_root, 'data', 'openrocket_analysis.mat'), ...
    'analysis');

fprintf('\nAnalysis completed successfully.\n');
fprintf('Figures saved to:\n%s\n', results_dir);
fprintf('Analysis data saved successfully.\n');