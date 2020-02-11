clear
close all
sca
clc

%launch stimulation on trig count
[screenXpixels, screenYpixels, window, white, black, ifi, windowRect,...
    xCenter,yCenter,vbl] = open_psychtoolbox();

% % OKR parameters ...
% bandsizemm = 6;
% pixmmRatio = 100/32;
% Ampmm =  300; % amplitude of OKR stimulus in mm
% Amp = Ampmm*pixmmRatio; % amplitude of OKR stimulus in pix
% freq = 0.5; % in Hertz
% okrp = 1/freq; % half-period of stim in s
% w = 2*pi/okrp;

% OKR parameters ...
bandsizemm = 10;
pixmmRatio = 100/32;
speed_mm_s = 20;
freq = 0.5; % in Hertz
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
in = 0;
waitframes = 1;

while ~KbCheck
    in = in + 1;
    xoffset = Amp*sin(in*ifi*w);
    srcRect = [xoffset 0 screenXpixels+xoffset screenYpixels];
    Screen('DrawTexture', window, okrimage, srcRect, [], [], [], [], [255 255 255]);
    Screen('DrawTexture',window, maskChamberText);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end


% rectend = [0 0 0];
% Screen('FillRect', window, rectend, centeredRect);
% Screen('Flip', window);
