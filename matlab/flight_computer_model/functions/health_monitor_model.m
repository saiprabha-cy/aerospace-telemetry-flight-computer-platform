function status = health_monitor_model(temperature_c, battery_v)
%HEALTH_MONITOR_MODEL Replicates ATFIDP firmware health logic.
%
% Status:
%   0 = OK
%   1 = WARNING
%   2 = CRITICAL

    status = zeros(size(temperature_c));

    low_battery = battery_v < 20.0;
    high_temperature = temperature_c > 80.0;

    status(low_battery) = 1;
    status(high_temperature) = 2;
end