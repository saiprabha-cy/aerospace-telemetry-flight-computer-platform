%% ATFIDP - Prepare OpenRocket Data for Simulink

clear;
clc;

%% Project paths

project_root = fileparts(fileparts(mfilename('fullpath')));

data_file = fullfile( ...
    project_root, ...
    'data', ...
    'openrocket_flight.mat');

%% Load OpenRocket data

load(data_file, 'T');

fprintf('ATFIDP OpenRocket -> Simulink Preparation\n');
fprintf('------------------------------------------\n');

%% Extract OpenRocket signals

time = T.x_Time_s_;
altitude = T.Altitude_m_;
vertical_velocity = T.VerticalVelocity_m_s_;
vertical_acceleration = T.VerticalAcceleration_m_s__;
total_velocity = T.TotalVelocity_m_s_;
mach = T.MachNumber___;

%% Convert to column vectors

time = time(:);
altitude = altitude(:);
vertical_velocity = vertical_velocity(:);
vertical_acceleration = vertical_acceleration(:);
total_velocity = total_velocity(:);
mach = mach(:);

%% Check original data

fprintf('Original samples : %d\n', numel(time));

valid_rows = ...
    isfinite(time) & ...
    isfinite(altitude) & ...
    isfinite(vertical_velocity) & ...
    isfinite(vertical_acceleration) & ...
    isfinite(total_velocity) & ...
    isfinite(mach);

fprintf('Invalid rows     : %d\n', sum(~valid_rows));

%% Remove invalid rows

time = time(valid_rows);
altitude = altitude(valid_rows);
vertical_velocity = vertical_velocity(valid_rows);
vertical_acceleration = vertical_acceleration(valid_rows);
total_velocity = total_velocity(valid_rows);
mach = mach(valid_rows);

%% Check time ordering

[time, sort_index] = sort(time);

altitude = altitude(sort_index);
vertical_velocity = vertical_velocity(sort_index);
vertical_acceleration = vertical_acceleration(sort_index);
total_velocity = total_velocity(sort_index);
mach = mach(sort_index);

%% Remove duplicate timestamps

[time, unique_index] = unique(time, 'stable');

altitude = altitude(unique_index);
vertical_velocity = vertical_velocity(unique_index);
vertical_acceleration = vertical_acceleration(unique_index);
total_velocity = total_velocity(unique_index);
mach = mach(unique_index);

fprintf('Valid samples    : %d\n', numel(time));

%% Create Simulink-compatible timeseries

openrocket_altitude = timeseries( ...
    altitude, ...
    time);

openrocket_velocity = timeseries( ...
    total_velocity, ...
    time);

openrocket_vertical_velocity = timeseries( ...
    vertical_velocity, ...
    time);

openrocket_acceleration = timeseries( ...
    vertical_acceleration, ...
    time);

openrocket_mach = timeseries( ...
    mach, ...
    time);

%% Display information

fprintf('\nSimulink timeseries created:\n');
fprintf('  openrocket_altitude\n');
fprintf('  openrocket_velocity\n');
fprintf('  openrocket_vertical_velocity\n');
fprintf('  openrocket_acceleration\n');
fprintf('  openrocket_mach\n');

fprintf('\nPrepared flight data:\n');
fprintf('Start time         : %.2f s\n', time(1));
fprintf('End time           : %.2f s\n', time(end));
fprintf('Maximum altitude   : %.2f m\n', max(altitude));
fprintf('Maximum velocity   : %.2f m/s\n', max(total_velocity));
fprintf('Maximum accel.     : %.2f m/s^2\n', max(vertical_acceleration));
fprintf('Maximum Mach       : %.3f\n', max(mach));

%% Save prepared data

save_file = fullfile( ...
    project_root, ...
    'data', ...
    'openrocket_simulink_data.mat');

save(save_file, ...
    'openrocket_altitude', ...
    'openrocket_velocity', ...
    'openrocket_vertical_velocity', ...
    'openrocket_acceleration', ...
    'openrocket_mach');

fprintf('\nPrepared Simulink data saved successfully.\n');
fprintf('Saved to:\n%s\n', save_file);