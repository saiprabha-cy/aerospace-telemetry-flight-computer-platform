function run_health_test()

    fprintf('\nATFIDP Health Monitor Verification\n');
    fprintf('---------------------------------\n');

    %% Test 1: Nominal

    temperature = 25.0;
    battery = 24.0;

    status = health_monitor_model(temperature, battery);

    fprintf('Test 1 - Nominal       : Status = %d\n', status);

    %% Test 2: Low battery

    temperature = 25.0;
    battery = 19.0;

    status = health_monitor_model(temperature, battery);

    fprintf('Test 2 - Low Battery   : Status = %d\n', status);

    %% Test 3: High temperature

    temperature = 85.0;
    battery = 24.0;

    status = health_monitor_model(temperature, battery);

    fprintf('Test 3 - High Temp     : Status = %d\n', status);

    %% Test 4: Both critical conditions

    temperature = 85.0;
    battery = 19.0;

    status = health_monitor_model(temperature, battery);

    fprintf('Test 4 - Both Faults   : Status = %d\n', status);

end