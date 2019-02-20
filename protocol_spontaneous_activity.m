%% Protocol for recording spontaneous activity


sca;
clear;
clc

% ----- Setup DAQ -----
Dev = daq.createSession('ni');
addAnalogOutputChannel(Dev, 'Dev3', 'ao0', 'Voltage');
Dev.Rate = 1000;

% ----- Create saving folder -----
g = input('fish age ? (dpf)');
fish_state = ['WT ' num2str(g) ' dpf'];
formatOut = 'yy-mm-dd';
day = datestr(now,formatOut);
directory='F:\Project\Julie\spontaneous\';

f = input('Run number?\n');
d = floor(f/10);
u = floor(f-d*10);
name  = sprintf('run_%d%d',d,u);
directory_run = fullfile(directory,day,name);
mkdir(directory_run);
mkdir(fullfile(directory_run,'movie'));

% ----- Open psychtoolbox, OMR fixed parameters -----
[screenXpixels, screenYpixels, window, white, black, ifi, windowRect,...
    xCenter,yCenter,vbl] = open_psychtoolbox();

time_recording = 10*1000; % in ms

trig = 500;
trigCam = [ones(trig,1)*2; zeros(3*trig, 1)];
outputData = trigCam;

disp('----- Start the camera recording on FlyCap !!! -----');
in = input('Start? [y]:yes  [n]:no\n','s');
n = 'y';

while strcmp(n,'y') == 1
    if strcmp(in,'y') == 1
        disp('Wait for 1 min before starting a new experiment');
        
        waitbar_time(60,'Wait 1 min')
        
        queueOutputData(Dev, outputData);
        startBackground(Dev);
        
        waitbar_time(10,'Recording spontaneous activity')
        
        
        %% ----- Save information -----
        P.fish = fish_state;
        P.dateTime = date;
        P.fps = 150;
        P.time_recording = time_recording;
        % D.cameraFeatures.Gain = src.Gain;
        % D.cameraFeatures.Shutter = src.Shutter;
        % D.cameraFeatures.Exposure = src.Exposure;
        % D.cameraFeatures.ROIdish = ROIdish;
        
        data = 'parameters';
        save(fullfile(directory_run, [data name]),'P');
    end
    
    disp('----- Stop the camera recording on FlyCap !!! -----');
    n = input('Start with the same parameters? [y]:yes  [n]:no\n','s');
    if strcmp(n,'y') == 1
        f = f + 1;
        d = floor(f/10);
        u = floor(f-d*10);
        name  = sprintf('run_%d%d',d,u);
        directory_run = fullfile(directory,day,name);
        mkdir(directory_run);
        mkdir(fullfile(directory_run,'movie'));
        disp('----- Start the camera recording on FlyCap !!! -----');
        pause(10)
    end
end

if strcmp(n,'n') == 1
    disp('Run the script whith new parameters')
    clear all;
    close all;
    sca;
    clc;
end