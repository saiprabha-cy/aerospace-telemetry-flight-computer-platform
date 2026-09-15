%% ATFIDP - OpenRocket Data Import

clear;
clc;

%% Project paths

matlab_project = fileparts(fileparts(mfilename('fullpath')));
atfidp_root = fileparts(fileparts(matlab_project));

csv_file = fullfile( ...
    atfidp_root, ...
    'openrocket', ...
    'simulations', ...
    'ATFIDP_reference_flight.csv');

data_dir = fullfile(matlab_project, 'data');

if ~exist(data_dir, 'dir')
    mkdir(data_dir);
end

%% Import OpenRocket CSV

fprintf('ATFIDP OpenRocket Data Import\n');
fprintf('-----------------------------\n');

fprintf('Reading:\n%s\n\n', csv_file);

opts = detectImportOptions(csv_file);
T = readtable(csv_file, opts);

fprintf('CSV imported successfully.\n');
fprintf('Rows    : %d\n', height(T));
fprintf('Columns : %d\n\n', width(T));

%% Display available variables

fprintf('Available OpenRocket variables:\n');
disp(T.Properties.VariableNames');

%% Save imported data

save_file = fullfile(data_dir, 'openrocket_flight.mat');

save(save_file, 'T');

fprintf('\nOpenRocket data saved successfully.\n');
fprintf('Saved to:\n%s\n', save_file);