sca;
clear;
clc;

% ----- Setup DAQ -----
Dev = daq.createSession('ni');
addAnalogOutputChannel(Dev, 'Dev3', 'ao0', 'Voltage');
Dev.Rate = 1000;
outputData0 = 0;
queueOutputData(Dev, outputData0);
startBackground(Dev);


pause(5)

trig = 500;
trigCam = [ones(trig,1)*3; zeros(4*trig, 1)];
outputData = trigCam;

queueOutputData(Dev, outputData);
startBackground(Dev);

pause(5)

queueOutputData(Dev, outputData0);
startBackground(Dev);