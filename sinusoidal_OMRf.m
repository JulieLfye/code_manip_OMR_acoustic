function [vbl]=sinusoidal_OMRf(vbl,screenXpixels,screenYpixels,...
    xCenter,yCenter,window,ifi,white,black,bandsizemm,speed_mm_s,...
    freq,time_ms,FirstOmrDirection)


% OKR parameters ...
pixmmRatio = 100/32;
okrp = 1/freq; % half-period of stim in s
Ampmm = speed_mm_s * okrp;
Amp = Ampmm*pixmmRatio;
w = 2*pi/okrp;

% Size of the mask
xo = xCenter;
yo = yCenter+100;
%mask of the chamber
chamber = CenterRectOnPointd([0, 0, 2*Amp, 2*Amp],xo , yo);
chamber = round(chamber);
f = find(chamber < 1);
if isempty(f) == 0
    chamber(f) = 1;
end
maskChamber = ones(screenYpixels, screenXpixels,1) * black;
maskChamber(:,:,2) = 1;
maskChamber(chamber(2)+1:min(chamber(4), screenYpixels),chamber(1)+1:min(chamber(3),screenXpixels),2) = 0;
maskChamberText = Screen('MakeTexture', window, maskChamber);

%% === TIMING & COORDINATION PARAMETERS ===
bandsizepix = bandsizemm*pixmmRatio;
bwsegments = round(screenXpixels/bandsizepix);
okr_pattern = createLinPatternVert(bwsegments, white, black,...
    screenXpixels, screenYpixels);

% prepare okr stimulus
okrimage = Screen('MakeTexture', window, okr_pattern);

%% === EXPERIMENT START ===
frameCounter = 0;
waitframes = 1;
Maxframecounter = round(time_ms/(ifi*1000));

while frameCounter < Maxframecounter
    frameCounter = frameCounter + 1;
    xoffset = FirstOmrDirection*Amp*sin(frameCounter*ifi*w);
    srcRect = [xoffset 0 screenXpixels+xoffset screenYpixels];
    Screen('DrawTexture', window, okrimage, srcRect, [], [], [], [], [255 255 255]);
    Screen('DrawTexture',window, maskChamberText);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end


% rectend = [0 0 0];
% Screen('FillRect', window, rectend, centeredRect);
% Screen('Flip', window);
