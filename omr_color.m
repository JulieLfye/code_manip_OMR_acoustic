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
screenNumber = max(screens);
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
red = [1 0 0];
green = [0 1 0];
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

%% great the OMR
%Calibration projector
pix_per_mm = 5.18;

% Size of the chamber in pix 
xChamber = 1920;
yChamber = 1080; 

OMRangle = 0;
angle = mod(-OMRangle + 180,360);

speed_mm_s = 30;
speed_pix_s = speed_mm_s * pix_per_mm;
pixPerCycle = 100;
cyclesPerSecond = speed_pix_s/pixPerCycle;


%size of the cycle: black+white
%number of cycles: black + white in the OMR
XpixPerCycleAngle_r = pixPerCycle*cosd(angle);
YpixPerCycleAngle_r = pixPerCycle*sind(angle);
XpixPerCycleAngle_g = pixPerCycle*cosd(angle+180);
YpixPerCycleAngle_g = pixPerCycle*sind(angle+180);
nbCycle = round(xChamber/pixPerCycle);
nbCycleNeeded = nbCycle + 4;

%define the texture
cycleText = [0, 1];
OMRt_r = repmat(cycleText,1,nbCycleNeeded);
OMRt_r(:,:,2) = 0.5;
OMRText_r = Screen('MakeTexture', window, OMRt_r);
OMRt_g = repmat(cycleText,1,nbCycleNeeded);
OMRt_g(:,:,2) = 1;
OMRText_g = Screen('MakeTexture', window, OMRt_g);
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
XshiftPerFramePix_r = cyclesPerSecond * XpixPerCycleAngle_r * waitduration;
YshiftPerFramePix_r = cyclesPerSecond * YpixPerCycleAngle_r * waitduration;
XshiftPerFramePix_g = cyclesPerSecond * XpixPerCycleAngle_g * waitduration;
YshiftPerFramePix_g = cyclesPerSecond * YpixPerCycleAngle_g * waitduration;
frameCounter = 0;
vbl = Screen('Flip', window);

% Photoresistance indicator
baseRect = [0 0 200 200];
centeredRect = CenterRectOnPoint(baseRect, xCenter+600, 250);

filterMode = 0;
% draw
while ~KbCheck
    frameCounter = frameCounter + 1;
    xoffset_r = mod(frameCounter * XshiftPerFramePix_r, XpixPerCycleAngle_r);
    yoffset_r = mod(frameCounter * YshiftPerFramePix_r, YpixPerCycleAngle_r);
    dstRect_r = CenterRectOnPointd(dstRect0, xCenter + xoffset_r, yCenter + yoffset_r);
    xoffset_g = mod(frameCounter * XshiftPerFramePix_g, XpixPerCycleAngle_g);
    yoffset_g = mod(frameCounter * YshiftPerFramePix_g, YpixPerCycleAngle_g);
    dstRect_g = CenterRectOnPointd(dstRect0, xCenter + xoffset_g, yCenter + yoffset_g);
    Screen('DrawTexture', window, OMRText_g, [], dstRect_g,angle+180,filterMode,[],[0 1 0]);
    Screen('DrawTexture', window, OMRText_r, [], dstRect_r,angle,filterMode,[],[1 0 0]);
    
    Screen('DrawTexture',window, maskChamberText);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end