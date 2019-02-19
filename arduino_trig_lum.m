clear;
close all;
clc;
sca;

%% Create saving folder
f = input('Run number?');
g = input('fish age ? (dpf)');
fish_state = ['WT ' num2str(g) ' dpf'];
disp('Saving')
formatOut = 'yy-mm-dd';
day = datestr(now,formatOut);
name  = sprintf('Run%d',f);
directory='F:\Project\Julie\data_prelim_OMR_vib\';
directory = fullfile(directory,day,name);
mkdir(directory);

%%

[screenXpixels, screenYpixels, window, white, black, ifi, windowRect,...
    xCenter,yCenter,vbl] = open_psychtoolbox();

% --- Open serial connection
s = serial('COM3'); 		% Replace with your actual serial port
set(s,'BaudRate', 115200);
set(s,'Timeout',10);
fopen(s);
fprintf('The serial connection is established.\n');

% --- Display client commands
fprintf('%s\n', repmat('-', [1 50]));
fprintf('Possible commands:\n');
fprintf('\t- t: send a trig\n');
fprintf('\t- OMR: set OMR duration\n');
% SET OMR BOTH IN ARDUINO AND MATLAB
fprintf('\t- level: vibration pwm level (0-255)\n');
fprintf('%s\n\n', repmat('-', [1 50]));
fprintf('Enter the serial commands below ([Enter] to exit):\n');
t = 't';

% --- OMR parameters
xChamber = 1000; %in pix
yChamber = 1000; %in pix
OMRangle = 0;
pixPerCycle = 100;
speed_mm_s = 20;
OMR = 0;
backgroundColor = white;
% --- Other parameters
int = [];

while true
    Screen('FillRect', window, white);
    Screen('Flip', window);
    in = input('?> ', 's');
    % Break condition
    if isempty(in), break; end
    % Send command
    fprintf(s, in);
    
        if strcmp(in,t)==1
           % pause(0.960);
%             [vbl]=OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
%      xCenter,yCenter,window,ifi,white,black,xChamber,yChamber,OMRangle,pixPerCycle,...
%      speed_mm_s,OMR,backgroundColor);
        end
    
    
    % Receive message
    while true
        %fprintf('%s\n', strtrim(fscanf(s)));
        int = fscanf(s);
        %iL = strfind(data,'L');
        if ~s.BytesAvailable, break; end
    end
    pause(1) % time for recording
end

% --- Close the serial connection
fclose(s);
delete(s);
clear s;
fprintf('The serial connection is closed.\n');
[time,intensity] = plotIntensity(int(1:end-5));

%%Save information
D.fish = fish_state;
D.dateTime = date;
% D.cameraFeatures.Gain = src.Gain;
% D.cameraFeatures.Shutter = src.Shutter;
% D.cameraFeatures.Exposure = src.Exposure;
% D.cameraFeatures.ROIdish = ROIdish;
D.OMR.Duration = OMR;
D.OMR.speed = speed_mm_s;
D.OMR.angle = OMRangle;
D.OMR.pixPerCycle = pixPerCycle;
D.OMR.intensity = intensity;
D.OMR.time = time;
D.Vib.level = 255;
D.Vib.duration = 100;


data = 'data';
save(fullfile(directory, [data name]),'D');