%% Protocol for testing OMR bias to acoustic stimulation

sca;
clear;
clc;

% ----- Create saving folder -----
g = input('fish age ? (dpf)');
fish_state = ['WT ' num2str(g) ' dpf'];
formatOut = 'yy-mm-dd';
day = datestr(now,formatOut);
directory='F:\Project\Julie\OMR_dark_flash\';

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
time_b_OMR = 1000; % in ms
darkflash_duration = 500; % in ms
OMRduration = input('OMR duration in ms? ');
intCamStim = time_b_OMR + OMRduration + darkflash_duration;
nb_frames = round((intCamStim + 300)*150/1000);
fprintf('Number of frame to record: %d\n', nb_frames);
% disp('----- Set the number of frame to record on FlyCap !!! -----');

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
        OMRangle = rand*360;
        % here display OMR background !
        OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
            xCenter,yCenter,window,ifi,white,black,xChamber,yChamber,OMRangle,cycle_mm,...
            speed_mm_s,ifi*1000,backgroundColor);
        
        disp('Wait for 1 min before starting a new experiment');
        waitbar_time(60,'Wait 1 min')
        
        pause(time_b_OMR/1000); % wait until OMR starts
        
        [vbl]=OMR_allAngle_darkflash_f(vbl,screenXpixels,screenYpixels,...
            xCenter,yCenter,window,ifi,white,black,xChamber,yChamber,OMRangle,cycle_mm,...
            speed_mm_s,OMRduration,backgroundColor,darkflash_duration);
        
        
        pause(2); % wait end of recording
        
        %% ----- Save information -----
        P.fish = fish_state;
        P.dateTime = date;
        % D.cameraFeatures.Gain = src.Gain;
        % D.cameraFeatures.Shutter = src.Shutter;
        % D.cameraFeatures.Exposure = src.Exposure;
        % D.cameraFeatures.ROIdish = ROIdish;
        P.OMR.Duration = OMRduration;
        P.OMR.speed = speed_mm_s;
        P.OMR.angle = OMRangle;
        P.OMR.cycle_mm = cycle_mm;
        P.OMR.time_b_OMR = time_b_OMR;
        
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