clear;
close all;
clc;

[screenXpixels, screenYpixels, window, white, black, ifi, windowRect,...
    xCenter,yCenter,vbl] = open_psychtoolbox();


% --- Open serial connection
s = serial('COM3'); 		% Replace with your actual serial port
set(s,'BaudRate', 115200);
% set(s,'Timeout',5);
fopen(s);
fprintf('The serial connection is established.\n');

% --- Display client commands
fprintf('%s\n', repmat('-', [1 50]));
fprintf('Possible commands:\n');
fprintf('\t- t: send a trig\n');
fprintf('\t- wait: time between start camera and vib stimulus\n');
fprintf('\t- level: pwm level (0-255)\n');
fprintf('%s\n\n', repmat('-', [1 50]));
fprintf('Enter the serial commands below ([Enter] to exit):\n');
t = 't';

% --- OMR parameters
xChamber = 1000; %in pix
yChamber = 1000; %in pix
OMRangle = 0;
pixPerCycle = 100;
speed_mm_s = 20;
time_ms = 150;
backgroundColor = white;

while true
    %     Screen('FillRect', window, white);
    %     Screen('Flip', window);
    in = input('?> ', 's');
    % Break condition
    if isempty(in), break; end
    % Send command
    fprintf(s, in);
    
        if strcmp(in,t)==1
            pause(0.960);
            [vbl]=OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
    xCenter,yCenter,window,ifi,white,xChamber,yChamber,OMRangle,pixPerCycle,...
    speed_mm_s,time_ms,backgroundColor);
%     Screen('FillRect', window, black);
%     Screen('Flip',window);
        end
    
    
    % Receive message
    while true
        fprintf('%s\n', (fscanf(s)));
        if ~s.BytesAvailable, break; end
    end
    pause(1) % time for recording
end

% --- Close the serial connection
fclose(s);
%delete(s);
%clear s;
sca;
fprintf('The serial connection is closed.\n');