%% ATFIDP Flight Computer - Simulation Initialization
% Initializes the MATLAB simulation environment.

clear;
clc;
close all;

%% Simulation parameters

sim.dt = 0.1;          % Simulation timestep [s]
sim.duration = 60.0;   % Simulation duration [s]

sim.time = 0:sim.dt:sim.duration;

%% Initial flight state

flight.temperature_c = 25.0;
flight.altitude_m = 1000.0;
flight.velocity_mps = 120.0;
flight.battery_v = 24.0;

flight.timestamp_s = 0;
flight.status = 0;     % 0 = OK

%% Display configuration

fprintf('ATFIDP Flight Computer MATLAB Simulation\n');
fprintf('----------------------------------------\n');
fprintf('Timestep : %.2f s\n', sim.dt);
fprintf('Duration : %.2f s\n', sim.duration);
fprintf('Samples  : %d\n', numel(sim.time));
fprintf('Initial temperature : %.1f C\n', flight.temperature_c);
fprintf('Initial altitude    : %.1f m\n', flight.altitude_m);
fprintf('Initial velocity    : %.1f m/s\n', flight.velocity_mps);
fprintf('Initial battery     : %.2f V\n', flight.battery_v);