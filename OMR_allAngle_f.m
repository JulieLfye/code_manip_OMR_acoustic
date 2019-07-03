function [vbl]=OMR_allAngle_f(vbl,screenXpixels,screenYpixels,...
    xCenter,yCenter,window,ifi,white,black,xChamber,yChamber,OMRangle,cycle_mm,...
    speed_mm_s,time_ms,backgroundColor)

%% Comments
% Visual pattern for the OMR radial
%Inputs -----
% screenXpixels, screenYpixels, window, vbl, waitframes, ifi,
% xChamber,yChamber,angle,backgroundColor

%% Code
% Calibration projector
pix_per_mm = 400/120;
pixPerCycle = cycle_mm * pix_per_mm;

% Calculs
angle = mod(-OMRangle + 180, 360);
speed_pix_s = speed_mm_s * pix_per_mm;
cyclesPerSecond = speed_pix_s/pixPerCycle;

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
maskChamber = ones(screenYpixels, screenXpixels,1) * backgroundColor;
maskChamber(:,:,2) = 1;
maskChamber(chamber(2)+1:chamber(4),chamber(1)+1:chamber(3),2) = 0;
maskChamberText = Screen('MakeTexture', window, maskChamber);

% Photoresistance indicator
baseRect = [0 0 200 200];
centeredRect = CenterRectOnPoint(baseRect, xCenter+600, 250);

% OMR parameters
waitframes = 1;
waitduration = waitframes*ifi;
XshiftPerFramePix = cyclesPerSecond * XpixPerCycleAngle * waitduration;
YshiftPerFramePix = cyclesPerSecond * YpixPerCycleAngle * waitduration;
frameCounter = 0;
Maxframecounter = round(time_ms/(ifi*1000));

% draw
while frameCounter < Maxframecounter
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