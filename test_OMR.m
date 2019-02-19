sca;
clear;
clc


Dev = daq.createSession('ni');
addAnalogOutputChannel(Dev, 'Dev3', 'ao0', 'Voltage');
Dev.Rate = 1000;
% outputData = 0;
% queueOutputData(Dev, outputData);
% startBackground(Dev);


[screenXpixels, screenYpixels, window, white, black, ifi, windowRect,...
    xCenter,yCenter,vbl] = open_psychtoolbox();

xChamber = 1000; %in pix
yChamber = 1000; %in pix
OMRangle = 0;
cycle_mm = 20; %size cycle (black +white) in mm
speed_mm_s = 20;
backgroundColor = white;
time_ms = 11*1000;

trig = 500;
trigCam = [ones(trig,1)*2; zeros(3*trig, 1)];
outputData = trigCam;
queueOutputData(Dev, outputData);
startBackground(Dev);

OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
    xCenter,yCenter,window,ifi,white,black,xChamber,yChamber,OMRangle,cycle_mm,...
    speed_mm_s,time_ms,backgroundColor);