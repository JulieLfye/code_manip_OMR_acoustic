%% Protocol for testing OMR bias to acoustic stimulation

sca;
clear;
clc;

% ----- Setup DAQ -----
Dev = daq.createSession('ni');
addAnalogOutputChannel(Dev, 'Dev3', 'ao0', 'Voltage'); %camera
addAnalogOutputChannel(Dev, 'Dev3', 'ao1', 'Voltage'); %trig vibration
Dev.Rate = 1000;
outputData = [0 0];
trig = 500;
queueOutputData(Dev, outputData);
startBackground(Dev);

% ----- Create saving folder -----
g = input('fish age ? (dpf)');
fish_state = ['WT ' num2str(g) ' dpf'];
formatOut = 'yy-mm-dd';
day = datestr(now,formatOut);
directory='D:\embedded_fish\OKR_acoustic\whole_illumination\OKR_acoustic\';

% ----- Open psychtoolbox, OMR fixed parameters -----
[screenXpixels, screenYpixels, window, white, black, ifi, windowRect,...
    xCenter,yCenter,vbl] = open_psychtoolbox();
% --- OMR parameters
xChamber = 1000; %in pix
yChamber = 1000; %in pix
cycle_mm = 10; %size cycle (black +white) in mm
speed_mm_s = 20;
backgroundColor = white;

% ----- Ask for experiment parameters -----
time_b_OMR = 1000; %in ms
OMRduration = input('OKR duration in ms? ');
intCamVib = time_b_OMR + OMRduration;
nb_frames = round((time_b_OMR + OMRduration + 300)*150/1000);
fprintf('Number of frame to record: %d\n', nb_frames);
% disp('----- Set the number of frame to record on FlyCap !!! -----');
% --- TTL
trigCam = [ones(trig,1)*3; zeros(intCamVib + 3*trig, 1)];
trigVib = [zeros(intCamVib, 1); ones(trig,1)*3; zeros(3*trig,1)];
outputData = [trigCam trigVib];

% ----- Adaptation
ad = input('10 min adaptation? [y]:yes  [n]:no\n','s');
if strcmp(ad,'y') == 1
    waitbar_time(10*60,'Adaptation 10 min');
end

%% ----- Create saving folder
f = input('Run number?\n');
d = floor(f/10);
u = floor(f-d*10);
name  = sprintf('run_%d%d',d,u);
directory_run = fullfile(directory,day,name);
mkdir(directory_run);
mkdir(fullfile(directory_run,'movie'));


%% ----- Protocol -----

disp('----- Start the camera recording on FlyCap !!! -----');
in = input('Start? [y]:yes  [n]:no\n','s');
n = 'y';

while strcmp(n,'y') == 1
    if strcmp(in,'y') == 1
                OMRangle = round(rand)*180;
%         disp('Radial OMR for 10 sec')
%         [vbl]=OMR_radial_f(vbl,10*1000,screenXpixels,screenYpixels,...
%             window,ifi,black, white);
        
        disp('Wait for 1 min before starting a new experiment');
        waitbar_time(60,'Wait 1 min')
        
        queueOutputData(Dev, outputData);
        startBackground(Dev);
        
        pause(time_b_OMR/1000); % wait until OMR starts
        
        [vbl]=OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
            xCenter,yCenter,window,ifi,white,black,xChamber,yChamber,OMRangle,cycle_mm,...
            speed_mm_s,OMRduration,backgroundColor);
        Screen('FillRect', window, white);
        vbl = Screen('Flip', window);
        
        pause(4*trig/1000); % wait end of recording
        
        %% ----- Save information -----
        P.fish = fish_state;
        P.dateTime = date;
        % D.cameraFeatures.Gain = src.Gain;
        % D.cameraFeatures.Shutter = src.Shutter;
        % D.cameraFeatures.Exposure = src.Exposure;
        % D.cameraFeatures.ROIdish = ROIdish;
        P.OKR.Duration = OMRduration;
        P.OKR.speed = speed_mm_s;
        P.OKR.angle = OMRangle;
        P.OKR.cycle_mm = cycle_mm;
        P.OKR.time_b_OMR = time_b_OMR;
        
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