%% Comments
% display OMR black and white


%% Initialisation physchtoolbox
close all;
clearvars;
sca;
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% Get the screen numbers
screens = Screen('Screens');
% Draw to the external screen if avaliable
screenNumber = 1;
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
red = [1 0 0];
% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% create the OMR

% parameters
cycle_mm = 10;
OMRangle = 180;
speed_mm_s = 20;

%Calibration projector
pix_per_mm = 400/120;
pixPerCycle = cycle_mm * pix_per_mm;

% Size of the chamber in pix 
xChamber = 1280;
yChamber = 1280; 

angle = mod(-OMRangle + 180, 360);
speed_pix_s = speed_mm_s * pix_per_mm;
cyclesPerSecond = speed_pix_s/pixPerCycle;


%size of the cycle: black+white
%number of cycles: black + white in the OMR
XpixPerCycleAngle = pixPerCycle*cosd(angle);
YpixPerCycleAngle = pixPerCycle*sind(angle);
nbCycle = round(xChamber/pixPerCycle);
nbCycleNeeded = nbCycle + 4;

%define the texture
cycleText = [0, 1];
OMRt = repmat(cycleText,1,nbCycleNeeded);
OMRText = Screen('MakeTexture', window, OMRt);
maxsize = round(sqrt(screenXpixels^2 + screenYpixels^2)+2);
dstRect0 = [0 0 pixPerCycle*nbCycleNeeded 2*maxsize];

%mask of the chamber
chamber = CenterRectOnPointd([0, 0, xChamber, yChamber],xCenter, yCenter);
f = find(chamber < 1);
if isempty(f) == 0
    chamber(f) = 1;
end
maskChamber = ones(screenYpixels, screenXpixels,1) * black;
maskChamber(:,:,2) = 1;
maskChamber(chamber(2)+1:chamber(4),chamber(1)+1:chamber(3),2) = 0;
maskChamberText = Screen('MakeTexture', window, maskChamber);

% OMR parameters 
waitframes = 1;
waitduration = waitframes*ifi;
XshiftPerFramePix = cyclesPerSecond * XpixPerCycleAngle * waitduration;
YshiftPerFramePix = cyclesPerSecond * YpixPerCycleAngle * waitduration;
frameCounter = 0;
vbl = Screen('Flip', window);

% Photoresistance indicator
baseRect = [0 0 200 200];
centeredRect = CenterRectOnPoint(baseRect, xCenter+600, 250);

% draw
while ~KbCheck
    frameCounter = frameCounter + 1;
    xoffset = mod(frameCounter * XshiftPerFramePix, XpixPerCycleAngle);
    yoffset = mod(frameCounter * YshiftPerFramePix, YpixPerCycleAngle);
    dstRect = CenterRectOnPointd(dstRect0, xCenter + xoffset, yCenter + yoffset);
    filterMode = 0;
    Screen('DrawTexture', window, OMRText, [], dstRect,angle,filterMode);
    Screen('DrawTexture',window, maskChamberText);
    Screen('FillRect', window, black, centeredRect);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end