%% Protocol for testing response to OMR stimulation

sca;
clear;
clc

% ----- Setup DAQ -----
Dev = daq.createSession('ni');
addAnalogOutputChannel(Dev, 'Dev3', 'ao0', 'Voltage');
Dev.Rate = 1000;
outputData0 = 0;
queueOutputData(Dev, outputData0);
startBackground(Dev);

% ----- Create saving folder -----
g = input('fish age ? (dpf)');
fish_state = ['WT ' num2str(g) ' dpf'];
formatOut = 'yy-mm-dd';
day = datestr(now,formatOut);
directory='D:\embedded_fish\OKR_acoustic\OKR_fixed\OKR\';

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

% --- OMR parameters
xChamber = 1000; %in pix
yChamber = 1000; %in pix
cycle_mm = 10; %size cycle (black +white) in mm
speed_mm_s = 20;
backgroundColor = white;
time_ms = 11*1000;

% --- Daq parameters
time_b_OMR = 250; % in ms
trig = 500;
trigCam = [ones(trig,1)*3; zeros(5*trig, 1)];
outputData = trigCam;

% ----- Adaptation
ad = input('10 min adaptation? [y]:yes  [n]:no\n','s');
OMRangle = round(rand)*180;
OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
    xCenter,yCenter,window,ifi,white,black,xChamber,yChamber,OMRangle,cycle_mm,...
    speed_mm_s,ifi*1000,backgroundColor);
if strcmp(ad,'y') == 1
    waitbar_time(10*60,'Adaptation 10 min');
end

%% Protocol

disp('----- Start the camera recording on FlyCap !!! -----');
in = input('Start? [y]:yes  [n]:no\n','s');
n = 'y';

while strcmp(n,'y') == 1
    if strcmp(in,'y') == 1
        
        if OMRangle == 0
            disp('OMR to the right, O')
        else
            disp('OMR to the left, 180')
        end
        disp('Wait for 1 min before starting a new experiment');
        waitbar_time(60,'Wait 1 min')
        
        queueOutputData(Dev, outputData);
        startBackground(Dev);
        
        pause(time_b_OMR/1000); % wait until OMR starts
        
        OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
            xCenter,yCenter,window,ifi,white,black,xChamber,yChamber,OMRangle,cycle_mm,...
            speed_mm_s,time_ms,backgroundColor);
        Screen('FillRect', window, white);
        vbl = Screen('Flip', window);
        
        pause(4*trig/1000); % wait end of recording
        
        %% ----- Save information -----
        P.fish = fish_state;
        P.dateTime = date;
        P.fps = 200;
        P.time_recording = time_ms - 1000;
        % D.cameraFeatures.Gain = src.Gain;
        % D.cameraFeatures.Shutter = src.Shutter;
        % D.cameraFeatures.Exposure = src.Exposure;
        % D.cameraFeatures.ROIdish = ROIdish;
        P.OKR.speed = speed_mm_s;
        P.OKR.angle = OMRangle;
        P.OKR.cycle_mm = cycle_mm;
        
        data = 'parameters';
        save(fullfile(directory_run, [data name]),'P');
        
        OMRangle = round(rand)*180;
        % here display OMR background !
        OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
            xCenter,yCenter,window,ifi,white,black,xChamber,yChamber,OMRangle,cycle_mm,...
            speed_mm_s,ifi*1000,backgroundColor);
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
        pause(5)
    end
end

if strcmp(n,'n') == 1
    disp('Run the script whith new parameters')
    clear all;
    close all;
    sca;
    clc;
end