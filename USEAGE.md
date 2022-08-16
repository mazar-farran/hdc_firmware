# Utilites

For all thse programs, full options can be found with --help.
The most likely to be changed options are listed here.

## imu-logger

--live Output samples to stdout, does not disable logging to file.
--logInterval Interval duration, in milliseconds, data collection.
--logDuration Duration of each log file in seconds.

## gnss-logger

--snr Ouptut snr to log
--minMode Minimum fix mode to log

## lorawan-logger

--live Output message responses to stdout.
--verbose 0 quiet, 1 error (default), 2 warn, 3 info, 4 debug (outputs things like rssi and radio configurations) These messages are logged to stderr.

