%% ATFIDP Flight Computer - Results Visualization

figure;
plot(flight_data.timestamp_s, flight_data.altitude_m, 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Altitude [m]');
title('ATFIDP Flight Profile - Altitude');

figure;
plot(flight_data.timestamp_s, flight_data.velocity_mps, 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Velocity [m/s]');
title('ATFIDP Flight Profile - Velocity');

figure;
plot(flight_data.timestamp_s, flight_data.temperature_c, 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Temperature [°C]');
title('ATFIDP Flight Computer - Temperature');

figure;
plot(flight_data.timestamp_s, flight_data.battery_v, 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Battery Voltage [V]');
title('ATFIDP Flight Computer - Battery');

figure;
stairs(flight_data.timestamp_s, flight_data.status, 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Health Status');
yticks([0 1 2]);
yticklabels({'OK','WARNING','CRITICAL'});
title('ATFIDP Flight Computer - Health Status');