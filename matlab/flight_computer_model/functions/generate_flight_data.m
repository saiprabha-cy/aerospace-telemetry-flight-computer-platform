function flight_data = generate_flight_data(time)
%GENERATE_FLIGHT_DATA Generate a deterministic ATFIDP flight-data scenario.
%
% Output fields correspond to the FlightData structure used by
% the STM32 flight-computer firmware.

    n = numel(time);

    flight_data.timestamp_s = time(:);

    % Altitude profile
    flight_data.altitude_m = ...
        1000.0 + 50.0 .* time(:) + 5.0 .* sin(0.2 .* time(:));

    % Velocity profile
    flight_data.velocity_mps = ...
        120.0 + 2.0 .* sin(0.15 .* time(:));

    % Temperature slowly increases
    flight_data.temperature_c = ...
        25.0 + 0.15 .* time(:);

    % Battery voltage slowly decreases
    flight_data.battery_v = ...
        24.0 - 0.03 .* time(:);

    % Status initially OK
    flight_data.status = zeros(n, 1);
end