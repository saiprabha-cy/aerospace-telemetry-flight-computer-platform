%% ATFIDP Flight Computer Simulation

run("init_simulation.m");

%% Generate flight scenario

flight_data = generate_flight_data(sim.time);

%% Run health monitoring

flight_data.status = health_monitor_model( ...
    flight_data.temperature_c, ...
    flight_data.battery_v);

%% Display final state

fprintf('\nFinal Flight State\n');
fprintf('------------------\n');
fprintf('Timestamp    : %.1f s\n', flight_data.timestamp_s(end));
fprintf('Temperature  : %.2f C\n', flight_data.temperature_c(end));
fprintf('Altitude     : %.2f m\n', flight_data.altitude_m(end));
fprintf('Velocity     : %.2f m/s\n', flight_data.velocity_mps(end));
fprintf('Battery      : %.2f V\n', flight_data.battery_v(end));
fprintf('Status       : %d\n', flight_data.status(end));

%% Save simulation data

project_root = fileparts(fileparts(mfilename('fullpath')));
data_dir = fullfile(project_root, 'data');

if ~exist(data_dir, 'dir')
    mkdir(data_dir);
end

save(fullfile(data_dir, 'flight_simulation.mat'), ...
    'sim', 'flight_data');

fprintf('\nSimulation data saved successfully.\n');
fprintf('Saved to: %s\n', fullfile(data_dir, 'flight_simulation.mat'));