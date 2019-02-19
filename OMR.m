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
% Size of the chamber in pix
xChamber = 1000;
yChamber = 300;

%size of the cycle: black+white
%number of cycles: black + white in the OMR
pixPerCycle = 100;
nbCycle = round(xChamber/pixPerCycle);
nbCycleNeeded = nbCycle + 2;
sizeOnelayer = round(pixPerCycle/2);
%mmPerCycle_exp = pixPerCycle*mm_pix;

%define the texture
cycleText = [0, 1];
OMRt = repmat(cycleText,1,nbCycleNeeded);
OMRText = Screen('MakeTexture', window, OMRt);
dstRect0 = [0 0 pixPerCycle*nbCycleNeeded yChamber];

%mask of the chamber
chamber = CenterRectOnPointd([0, 0, xChamber, yChamber],xCenter, yCenter);
f = find(chamber < 1);
if isempty(f) == 0
    chamber(f) = 1;
end
maskChamber = ones(screenYpixels, screenXpixels,1) * grey;
maskChamber(:,:,2) = 1;
maskChamber(chamber(2)+1:chamber(4),chamber(1)+1:chamber(3),2) = 0;
maskChamberText = Screen('MakeTexture', window, maskChamber);

% OMR parameters 
waitframes = 1;
waitduration = waitframes*ifi;
cyclesPerSecond = 1;
shiftPerFramePix = cyclesPerSecond * pixPerCycle * waitduration;
frameCounter = 0;
vbl = Screen('Flip', window);

% draw
while ~KbCheck
    frameCounter = frameCounter + 1;
    xoffset  = mod(frameCounter * shiftPerFramePix, pixPerCycle);
    dstRect = CenterRectOnPointd(dstRect0, xCenter + xoffset, yCenter);
    filterMode = 0;
    Screen('DrawTexture', window, OMRText, [], dstRect,[],filterMode);
    Screen('DrawTexture',window, maskChamberText);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end