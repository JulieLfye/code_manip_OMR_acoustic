
f = 150;

if ~exist('Dev', 'var')
    Dev = daq.createSession('ni');
    
    %     addDigitalChannel(Dev, 'Dev3', 'port0/line0', 'Bidirectional');
    addAnalogOutputChannel(Dev, 'Dev3', 'ao0', 'Voltage');
    addAnalogOutputChannel(Dev, 'Dev3', 'ao1', 'Voltage');
    Dev.Rate = 1000;
    
    %     outputData = 0;
    outputData = [0 0];
    queueOutputData(Dev, outputData);
    startBackground(Dev);
end

% return
trig = 500;
% outputData = 0;
intCamVib = 1000; % time between cam trig and vibration trig, in ms
% trig = round(Dev.Rate/2);
% trigCam = [ones(5,1)*3; zeros(5,1)];
% trigCam = repmat(trigCam,150,1);
% trigVib = zeros(size(trigCam));
trigCam = [ones(trig,1)*2; zeros(intCamVib + 3*trig, 1)];
trigVib = [zeros(intCamVib, 1); ones(trig,1)*3; zeros(3*trig,1)];
outputData = [trigCam trigVib];
% outputData = [0 0];
% outputData = ones(10000,2)*1;
% outputData(8000:end,1) = 0;
% outputData(2000:end,2) = 0;
%  outputData = (linspace(-1, 1, 5000)');
%plot(outputData)

% t = 0:1/Dev.Rate:(1-1/Dev.Rate);
% outputData = sin(t*2*pi*f)';

% figure(1)
% plot(t, outputData, '.-')

queueOutputData(Dev, outputData);

startBackground(Dev);
