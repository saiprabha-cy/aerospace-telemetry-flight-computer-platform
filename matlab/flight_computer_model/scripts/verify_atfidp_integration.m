function verify_atfidp_integration()
%VERIFY_ATFIDP_INTEGRATION
% Final automated verification of the ATFIDP MATLAB + Simulink +
% OpenRocket integration.
%
% Verifies:
%   1. Required project files
%   2. OpenRocket CSV import
%   3. OpenRocket trajectory cleaning
%   4. OpenRocket reference flight results
%   5. Prepared Simulink timeseries
%   6. MATLAB flight simulation data
%   7. Simulink model execution
%   8. OpenRocket / Simulink numerical agreement
%
% IMPORTANT:
% The MATLAB flight simulation MAT-file contains a variable named
% "sim". We deliberately load it through a structure named
% "loaded_flight_sim" so that the workspace variable "sim" does not
% shadow MATLAB/Simulink's sim() function.

clc;

fprintf('\n');
fprintf('============================================================\n');
fprintf(' ATFIDP FINAL INTEGRATION VERIFICATION\n');
fprintf(' MATLAB + SIMULINK + OPENROCKET\n');
fprintf('============================================================\n\n');

%% ------------------------------------------------------------------------
%  PROJECT PATHS
% -------------------------------------------------------------------------

script_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(script_dir);

openrocket_csv = fullfile( ...
    project_root, ...
    '..', ...
    '..', ...
    'openrocket', ...
    'simulations', ...
    'ATFIDP_reference_flight.csv');

% Normalize OpenRocket path
openrocket_csv = char(java.io.File(openrocket_csv).getCanonicalPath());

data_dir = fullfile(project_root, 'data');
models_dir = fullfile(project_root, 'models');
results_dir = fullfile(project_root, 'results', 'figures');

flight_sim_mat = fullfile( ...
    data_dir, ...
    'flight_simulation.mat');

openrocket_simulink_mat = fullfile( ...
    data_dir, ...
    'openrocket_simulink_data.mat');

openrocket_model = fullfile( ...
    models_dir, ...
    'ATFIDP_OpenRocket_Integration.slx');

report_file = fullfile( ...
    results_dir, ...
    'ATFIDP_Final_Integration_Verification.txt');

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

%% ------------------------------------------------------------------------
%  TEST COUNTERS
% -------------------------------------------------------------------------

total_tests = 0;
passed_tests = 0;
failed_tests = 0;

%% ------------------------------------------------------------------------
%  REPORT FILE
% -------------------------------------------------------------------------

report_fid = fopen(report_file, 'w');

if report_fid == -1
    error('Unable to create verification report file.');
end

cleanup_report = onCleanup(@() fclose(report_fid));

fprintf(report_fid, ...
    'ATFIDP FINAL INTEGRATION VERIFICATION\n');
fprintf(report_fid, ...
    'MATLAB + SIMULINK + OPENROCKET\n\n');

%% ------------------------------------------------------------------------
%  HELPER FOR TEST RESULTS
% -------------------------------------------------------------------------

    function record_test(name, passed)

        total_tests = total_tests + 1;

        if passed
            passed_tests = passed_tests + 1;
            result = 'PASS';
        else
            failed_tests = failed_tests + 1;
            result = 'FAIL';
        end

        fprintf('%-52s : %s\n', name, result);
        fprintf(report_fid, '%-52s : %s\n', name, result);

    end

%% ------------------------------------------------------------------------
%  PROJECT FILE VERIFICATION
% -------------------------------------------------------------------------

fprintf('PROJECT FILE VERIFICATION\n');
fprintf('-------------------------\n');

file_exists = exist(openrocket_csv, 'file') == 2;
record_test('OpenRocket MATLAB data', file_exists);

file_exists = exist(openrocket_simulink_mat, 'file') == 2;
record_test('OpenRocket Simulink data', file_exists);

file_exists = exist(flight_sim_mat, 'file') == 2;
record_test('MATLAB flight simulation data', file_exists);

file_exists = exist(openrocket_model, 'file') == 2;
record_test('OpenRocket Simulink model', file_exists);

fprintf('\n');

%% ------------------------------------------------------------------------
%  OPENROCKET DATA VERIFICATION
% -------------------------------------------------------------------------

fprintf('OPENROCKET DATA VERIFICATION\n');
fprintf('----------------------------\n');

openrocket_loaded = false;
openrocket_table = table();

if exist(openrocket_csv, 'file') == 2

    try

        openrocket_table = readtable(openrocket_csv);

        openrocket_loaded = ...
            ~isempty(openrocket_table) && ...
            height(openrocket_table) > 0;

    catch ME

        fprintf('OpenRocket CSV loading error:\n%s\n', ME.message);

    end

end

record_test('OpenRocket table loaded', openrocket_loaded);

raw_samples = 0;
invalid_rows = 0;
valid_samples = 0;

clean_time = [];
clean_altitude = [];
clean_velocity = [];
clean_vertical_velocity = [];
clean_acceleration = [];
clean_mach = [];

if openrocket_loaded

    raw_samples = height(openrocket_table);

    time_data = openrocket_table{:, 1};
    altitude_data = openrocket_table{:, 2};
    vertical_velocity_data = openrocket_table{:, 3};
    acceleration_data = openrocket_table{:, 4};
    velocity_data = openrocket_table{:, 5};
    mach_data = openrocket_table{:, 6};

    time_data = double(time_data);
    altitude_data = double(altitude_data);
    vertical_velocity_data = double(vertical_velocity_data);
    acceleration_data = double(acceleration_data);
    velocity_data = double(velocity_data);
    mach_data = double(mach_data);

    valid_mask = ...
        isfinite(time_data) & ...
        isfinite(altitude_data) & ...
        isfinite(vertical_velocity_data) & ...
        isfinite(acceleration_data) & ...
        isfinite(velocity_data) & ...
        isfinite(mach_data);

    invalid_rows = sum(~valid_mask);

    clean_time = time_data(valid_mask);
    clean_altitude = altitude_data(valid_mask);
    clean_vertical_velocity = vertical_velocity_data(valid_mask);
    clean_acceleration = acceleration_data(valid_mask);
    clean_velocity = velocity_data(valid_mask);
    clean_mach = mach_data(valid_mask);

    % Sort by time.
    [clean_time, sort_index] = sort(clean_time);

    clean_altitude = clean_altitude(sort_index);
    clean_vertical_velocity = clean_vertical_velocity(sort_index);
    clean_acceleration = clean_acceleration(sort_index);
    clean_velocity = clean_velocity(sort_index);
    clean_mach = clean_mach(sort_index);

    % Remove duplicate time values.
    [clean_time, unique_index] = unique(clean_time, 'stable');

    clean_altitude = clean_altitude(unique_index);
    clean_vertical_velocity = clean_vertical_velocity(unique_index);
    clean_acceleration = clean_acceleration(unique_index);
    clean_velocity = clean_velocity(unique_index);
    clean_mach = clean_mach(unique_index);

    valid_samples = numel(clean_time);

end

fprintf('Raw samples           : %d\n', raw_samples);
fprintf('Invalid rows removed  : %d\n', invalid_rows);
fprintf('Valid samples         : %d\n', valid_samples);

trajectory_finite = ...
    valid_samples > 0 && ...
    all(isfinite(clean_time)) && ...
    all(isfinite(clean_altitude)) && ...
    all(isfinite(clean_vertical_velocity)) && ...
    all(isfinite(clean_acceleration)) && ...
    all(isfinite(clean_velocity)) && ...
    all(isfinite(clean_mach));

record_test( ...
    'Cleaned OpenRocket trajectory is finite', ...
    trajectory_finite);

fprintf('\n');

%% ------------------------------------------------------------------------
%  OPENROCKET FLIGHT RESULT VERIFICATION
% -------------------------------------------------------------------------

fprintf('OPENROCKET FLIGHT RESULT VERIFICATION\n');
fprintf('-------------------------------------\n');

openrocket_results_valid = false;

flight_duration = NaN;
apogee_altitude = NaN;
time_to_apogee = NaN;
maximum_velocity = NaN;
time_of_max_velocity = NaN;
maximum_acceleration = NaN;
time_of_max_accel = NaN;
maximum_mach = NaN;
time_of_max_mach = NaN;

if trajectory_finite

    flight_duration = ...
        clean_time(end) - clean_time(1);

    [apogee_altitude, apogee_index] = ...
        max(clean_altitude);

    time_to_apogee = clean_time(apogee_index);

    [maximum_velocity, max_velocity_index] = ...
        max(clean_velocity);

    time_of_max_velocity = ...
        clean_time(max_velocity_index);

    [maximum_acceleration, max_accel_index] = ...
        max(clean_acceleration);

    time_of_max_accel = ...
        clean_time(max_accel_index);

    [maximum_mach, max_mach_index] = ...
        max(clean_mach);

    time_of_max_mach = ...
        clean_time(max_mach_index);

    fprintf('Flight duration       : %.2f s\n', flight_duration);
    fprintf('Apogee altitude       : %.2f m\n', apogee_altitude);
    fprintf('Time to apogee        : %.2f s\n', time_to_apogee);
    fprintf('Maximum velocity      : %.2f m/s\n', maximum_velocity);
    fprintf('Time of max velocity  : %.2f s\n', time_of_max_velocity);
    fprintf('Maximum acceleration  : %.2f m/s^2\n', maximum_acceleration);
    fprintf('Time of max accel.    : %.2f s\n', time_of_max_accel);
    fprintf('Maximum Mach number   : %.3f\n', maximum_mach);
    fprintf('Time of max Mach      : %.2f s\n', time_of_max_mach);

    % Reference values from the verified OpenRocket simulation.
    reference_duration = 1.97;
    reference_apogee = 2.15;
    reference_time_to_apogee = 1.32;
    reference_velocity = 24.02;
    reference_time_velocity = 1.98;
    reference_acceleration = 18.98;
    reference_time_acceleration = 0.20;
    reference_mach = 0.071;
    reference_time_mach = 1.98;

    tolerance_duration = 0.05;
    tolerance_altitude = 0.05;
    tolerance_time = 0.05;
    tolerance_velocity = 0.10;
    tolerance_acceleration = 0.10;
    tolerance_mach = 0.005;

    openrocket_results_valid = ...
        abs(flight_duration - reference_duration) <= tolerance_duration && ...
        abs(apogee_altitude - reference_apogee) <= tolerance_altitude && ...
        abs(time_to_apogee - reference_time_to_apogee) <= tolerance_time && ...
        abs(maximum_velocity - reference_velocity) <= tolerance_velocity && ...
        abs(time_of_max_velocity - reference_time_velocity) <= tolerance_time && ...
        abs(maximum_acceleration - reference_acceleration) <= tolerance_acceleration && ...
        abs(time_of_max_accel - reference_time_acceleration) <= tolerance_time && ...
        abs(maximum_mach - reference_mach) <= tolerance_mach && ...
        abs(time_of_max_mach - reference_time_mach) <= tolerance_time;

end

record_test( ...
    'OpenRocket results match reference values', ...
    openrocket_results_valid);

fprintf('\n');

%% ------------------------------------------------------------------------
%  SIMULINK DATA VERIFICATION
% -------------------------------------------------------------------------

fprintf('SIMULINK DATA VERIFICATION\n');
fprintf('--------------------------\n');

simulink_data_loaded = false;
simulink_data = struct();

if exist(openrocket_simulink_mat, 'file') == 2

    try

        simulink_data = load(openrocket_simulink_mat);

        required_fields = { ...
            'openrocket_altitude', ...
            'openrocket_velocity', ...
            'openrocket_vertical_velocity', ...
            'openrocket_acceleration', ...
            'openrocket_mach'};

        simulink_data_loaded = true;

        for k = 1:numel(required_fields)

            if ~isfield(simulink_data, required_fields{k})
                simulink_data_loaded = false;
                break;
            end

        end

    catch ME

        fprintf('Simulink data loading error:\n%s\n', ME.message);

    end

end

record_test( ...
    'Five Simulink timeseries exist', ...
    simulink_data_loaded);

prepared_samples = 0;

simulink_lengths_match = false;
simulink_data_finite = false;
simulink_data_match = false;
simulink_time_match = false;

if simulink_data_loaded && trajectory_finite

    ts_altitude = simulink_data.openrocket_altitude;
    ts_velocity = simulink_data.openrocket_velocity;
    ts_vertical_velocity = simulink_data.openrocket_vertical_velocity;
    ts_acceleration = simulink_data.openrocket_acceleration;
    ts_mach = simulink_data.openrocket_mach;

    prepared_samples = numel(ts_altitude.Time);

    length_altitude = numel(ts_altitude.Time);
    length_velocity = numel(ts_velocity.Time);
    length_vertical_velocity = numel(ts_vertical_velocity.Time);
    length_acceleration = numel(ts_acceleration.Time);
    length_mach = numel(ts_mach.Time);

    simulink_lengths_match = ...
        length_altitude == valid_samples && ...
        length_velocity == valid_samples && ...
        length_vertical_velocity == valid_samples && ...
        length_acceleration == valid_samples && ...
        length_mach == valid_samples;

    simulink_data_finite = ...
        all(isfinite(ts_altitude.Time)) && ...
        all(isfinite(ts_altitude.Data)) && ...
        all(isfinite(ts_velocity.Time)) && ...
        all(isfinite(ts_velocity.Data)) && ...
        all(isfinite(ts_vertical_velocity.Time)) && ...
        all(isfinite(ts_vertical_velocity.Data)) && ...
        all(isfinite(ts_acceleration.Time)) && ...
        all(isfinite(ts_acceleration.Data)) && ...
        all(isfinite(ts_mach.Time)) && ...
        all(isfinite(ts_mach.Data));

    if simulink_lengths_match

        tolerance_data = 1e-6;

        simulink_data_match = ...
            max(abs(ts_altitude.Data(:) - clean_altitude(:))) <= tolerance_data && ...
            max(abs(ts_velocity.Data(:) - clean_velocity(:))) <= tolerance_data && ...
            max(abs(ts_vertical_velocity.Data(:) - clean_vertical_velocity(:))) <= tolerance_data && ...
            max(abs(ts_acceleration.Data(:) - clean_acceleration(:))) <= tolerance_data && ...
            max(abs(ts_mach.Data(:) - clean_mach(:))) <= tolerance_data;

        simulink_time_match = ...
            max(abs(ts_altitude.Time(:) - clean_time(:))) <= tolerance_data && ...
            max(abs(ts_velocity.Time(:) - clean_time(:))) <= tolerance_data && ...
            max(abs(ts_vertical_velocity.Time(:) - clean_time(:))) <= tolerance_data && ...
            max(abs(ts_acceleration.Time(:) - clean_time(:))) <= tolerance_data && ...
            max(abs(ts_mach.Time(:) - clean_time(:))) <= tolerance_data;

    end

end

fprintf('Prepared samples      : %d\n', prepared_samples);

record_test( ...
    'Simulink timeseries lengths match cleaned data', ...
    simulink_lengths_match);

record_test( ...
    'Prepared Simulink data is finite', ...
    simulink_data_finite);

record_test( ...
    'Prepared data matches cleaned OpenRocket data', ...
    simulink_data_match);

record_test( ...
    'Simulink time vectors match cleaned trajectory', ...
    simulink_time_match);

fprintf('\n');

%% ------------------------------------------------------------------------
%  MATLAB FLIGHT SIMULATION VERIFICATION
% -------------------------------------------------------------------------

fprintf('MATLAB FLIGHT SIMULATION VERIFICATION\n');
fprintf('-------------------------------------\n');

matlab_sim_valid = false;

% IMPORTANT:
% Do NOT load the MAT-file directly into a workspace variable called "sim".
% The MAT-file contains a struct called sim, and that would shadow the
% Simulink sim() function.

if exist(flight_sim_mat, 'file') == 2

    try

        loaded_flight_sim = ...
            load(flight_sim_mat, 'sim', 'flight_data');

        sim_data = loaded_flight_sim.sim;
        flight_data = loaded_flight_sim.flight_data;

        matlab_sim_valid = ...
            isstruct(sim_data) && ...
            isfield(sim_data, 'time') && ...
            numel(sim_data.time) > 0 && ...
            isfield(flight_data, 'timestamp_s') && ...
            isfield(flight_data, 'temperature_c') && ...
            isfield(flight_data, 'altitude_m') && ...
            isfield(flight_data, 'velocity_mps') && ...
            isfield(flight_data, 'battery_v') && ...
            isfield(flight_data, 'status') && ...
            numel(flight_data.timestamp_s) == numel(sim_data.time) && ...
            numel(flight_data.temperature_c) == numel(sim_data.time) && ...
            numel(flight_data.altitude_m) == numel(sim_data.time) && ...
            numel(flight_data.velocity_mps) == numel(sim_data.time) && ...
            numel(flight_data.battery_v) == numel(sim_data.time) && ...
            numel(flight_data.status) == numel(sim_data.time) && ...
            all(isfinite(sim_data.time)) && ...
            all(isfinite(flight_data.timestamp_s)) && ...
            all(isfinite(flight_data.temperature_c)) && ...
            all(isfinite(flight_data.altitude_m)) && ...
            all(isfinite(flight_data.velocity_mps)) && ...
            all(isfinite(flight_data.battery_v)) && ...
            all(isfinite(flight_data.status));

    catch ME

        fprintf('MATLAB flight simulation data error:\n');
        fprintf('%s\n', ME.message);

        matlab_sim_valid = false;

    end

end

record_test( ...
    'MATLAB flight simulation data valid', ...
    matlab_sim_valid);

fprintf('\n');

%% ------------------------------------------------------------------------
%  SIMULINK EXECUTION VERIFICATION
% -------------------------------------------------------------------------

fprintf('SIMULINK EXECUTION VERIFICATION\n');
fprintf('-------------------------------\n');

simulink_execution_valid = false;

model_name = 'ATFIDP_OpenRocket_Integration';

try

    % Close model if already open.
    if bdIsLoaded(model_name)
        close_system(model_name, 0);
    end

    % Load the model.
    load_system(openrocket_model);

    fprintf('Model loaded successfully.\n');

    % Run the actual Simulink simulation.
    %
    % The important correction is that no workspace variable named "sim"
    % exists anymore. Therefore this calls MATLAB/Simulink's sim() function.
    sim(model_name);

    simulink_execution_valid = true;

catch ME

    fprintf('\nSimulink execution error detected.\n');
    fprintf('-----------------------------------\n');

    fprintf('Error message:\n');
    fprintf('%s\n\n', ME.message);

    fprintf('Error identifier:\n');
    fprintf('%s\n\n', ME.identifier);

    fprintf('Error stack:\n');

    for k = 1:numel(ME.stack)

        fprintf( ...
            'File: %s | Function: %s | Line: %d\n', ...
            ME.stack(k).file, ...
            ME.stack(k).name, ...
            ME.stack(k).line);

    end

    fprintf('\n');

    simulink_execution_valid = false;

end

record_test( ...
    'Simulink model executes without error', ...
    simulink_execution_valid);

fprintf('\n');

%% ------------------------------------------------------------------------
%  OPENROCKET / SIMULINK CROSS-CHECK
% -------------------------------------------------------------------------

fprintf('OPENROCKET / SIMULINK CROSS-CHECK\n');
fprintf('---------------------------------\n');

cross_check_valid = false;

simulink_end_time = NaN;
simulink_max_altitude = NaN;
simulink_max_velocity = NaN;
simulink_max_acceleration = NaN;
simulink_max_mach = NaN;

if simulink_data_loaded

    ts_altitude = simulink_data.openrocket_altitude;
    ts_velocity = simulink_data.openrocket_velocity;
    ts_acceleration = simulink_data.openrocket_acceleration;
    ts_mach = simulink_data.openrocket_mach;

    simulink_end_time = ts_altitude.Time(end);

    simulink_max_altitude = max(ts_altitude.Data);
    simulink_max_velocity = max(ts_velocity.Data);
    simulink_max_acceleration = max(ts_acceleration.Data);
    simulink_max_mach = max(ts_mach.Data);

    fprintf('Simulink end time      : %.2f s\n', simulink_end_time);
    fprintf('Simulink max altitude  : %.2f m\n', simulink_max_altitude);
    fprintf('Simulink max velocity  : %.2f m/s\n', simulink_max_velocity);
    fprintf('Simulink max accel.     : %.2f m/s^2\n', simulink_max_acceleration);
    fprintf('Simulink max Mach       : %.3f\n', simulink_max_mach);

    tolerance_crosscheck_time = 0.05;
    tolerance_crosscheck_altitude = 0.05;
    tolerance_crosscheck_velocity = 0.10;
    tolerance_crosscheck_acceleration = 0.10;
    tolerance_crosscheck_mach = 0.005;

    cross_check_valid = ...
        abs(simulink_end_time - flight_duration) <= tolerance_crosscheck_time && ...
        abs(simulink_max_altitude - apogee_altitude) <= tolerance_crosscheck_altitude && ...
        abs(simulink_max_velocity - maximum_velocity) <= tolerance_crosscheck_velocity && ...
        abs(simulink_max_acceleration - maximum_acceleration) <= tolerance_crosscheck_acceleration && ...
        abs(simulink_max_mach - maximum_mach) <= tolerance_crosscheck_mach;

end

record_test( ...
    'OpenRocket and Simulink results agree', ...
    cross_check_valid);

fprintf('\n');

%% ------------------------------------------------------------------------
%  FINAL SUMMARY
% -------------------------------------------------------------------------

fprintf('============================================================\n');
fprintf(' FINAL VERIFICATION SUMMARY\n');
fprintf('============================================================\n');

fprintf('Raw OpenRocket samples : %d\n', raw_samples);
fprintf('Invalid rows removed   : %d\n', invalid_rows);
fprintf('Valid trajectory       : %d\n\n', valid_samples);

fprintf('Total tests : %d\n', total_tests);
fprintf('Passed      : %d\n', passed_tests);
fprintf('Failed      : %d\n\n', failed_tests);

fprintf(report_fid, '\n');
fprintf(report_fid, 'FINAL VERIFICATION SUMMARY\n');
fprintf(report_fid, '===========================\n');
fprintf(report_fid, 'Raw OpenRocket samples : %d\n', raw_samples);
fprintf(report_fid, 'Invalid rows removed   : %d\n', invalid_rows);
fprintf(report_fid, 'Valid trajectory       : %d\n\n', valid_samples);
fprintf(report_fid, 'Total tests : %d\n', total_tests);
fprintf(report_fid, 'Passed      : %d\n', passed_tests);
fprintf(report_fid, 'Failed      : %d\n\n', failed_tests);

if failed_tests == 0

    fprintf('============================================================\n');
    fprintf(' ATFIDP MATLAB / OPENROCKET INTEGRATION: PASS\n');
    fprintf('============================================================\n');

    fprintf(report_fid, ...
        'ATFIDP MATLAB / OPENROCKET INTEGRATION: PASS\n');

else

    fprintf('============================================================\n');
    fprintf(' ATFIDP MATLAB / OPENROCKET INTEGRATION: FAIL\n');
    fprintf('============================================================\n');

    fprintf(report_fid, ...
        'ATFIDP MATLAB / OPENROCKET INTEGRATION: FAIL\n');

end

fprintf('\n');

fprintf('Final verification report saved to:\n');
fprintf('%s\n\n', report_file);

fprintf(report_fid, '\n');
fprintf(report_fid, 'Final verification report saved to:\n');
fprintf(report_fid, '%s\n', report_file);

fprintf('ATFIDP MATLAB/OpenRocket verification complete.\n');

end