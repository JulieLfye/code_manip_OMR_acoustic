clear
close all
sca
clc

%launch stimulation on trig count
[screenXpixels, screenYpixels, window, white, black, ifi, windowRect,...
    xCenter,yCenter,vbl] = open_psychtoolbox();

% OKR parameters ...
bandsizemm = 6;
pixmmRatio = 100/32;
Ampmm =  30; % amplitude of OKR stimulus in mm
Amp = Ampmm*pixmmRatio; % amplitude of OKR stimulus in pix
freq = 0.5; % in Hertz
okrp = 1/freq; % half-period of stim in s

w = 2*pi/okrp;

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
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end


% rectend = [0 0 0];
% Screen('FillRect', window, rectend, centeredRect);
% Screen('Flip', window);
