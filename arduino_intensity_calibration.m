clear;
close all;
clc;

[screenXpixels, screenYpixels, window, white, black, ifi, windowRect,...
    xCenter,yCenter,vbl] = open_psychtoolbox();
grey = white/2;
data = [];

% --- Open serial connection
s = serial('COM3'); 		% Replace with your actual serial port
set(s,'BaudRate', 115200);
%set(s,'Timeout',5);
fopen(s);
fprintf('The serial connection is established.\n');

% --- Display client commands
fprintf('%s\n', repmat('-', [1 50]));
fprintf('Possible commands:\n');
fprintf('\t- w: white screen\n');
fprintf('\t- g: grey screen\n');
fprintf('\t- b: black screen\n');
fprintf('\t- m: measure\n');
fprintf('%s\n\n', repmat('-', [1 50]));
fprintf('Enter the serial commands below ([Enter] to exit):\n');
w = 'w';
g = 'g';
b = 'b';
m = 'm';
time = [];
intensity = [];
i = 0;

[vbl]=OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
    xCenter,yCenter,window,ifi,white,1000,1000,0,100,...
    30,60*1000,black);

while true
    
    in = input('?> ', 's');
    % Break condition
    if isempty(in), break; end
    % Send command
    if strcmp(in,m)==1
        fprintf(s, in);
    end
    
    if strcmp(in,w)==1
        Screen('FillRect', window, white);
        Screen('Flip', window);
    elseif strcmp(in,g)==1
        Screen('FillRect', window, grey);
        Screen('Flip', window);
    elseif strcmp(in,b)==1
        Screen('FillRect', window, black);
        Screen('Flip', window);
    end
    
    
    % Receive message
    while true
        data = fscanf(s);
        iL = strfind(data,'L');
        %time = [time sscanf(data(2:iL-1),'%f')];
%         intensity = [intensity sscanf(data(iL+1:end),'%f')];
%         i = i+1;
%         hold on
%         plot(i,intensity(end),'-k*');
        if ~s.BytesAvailable, break; end
    end
end

% --- Close the serial connection
fclose(s);
delete(s);
clear s;
sca;
fprintf('The serial connection is closed.\n');