%launch stimulation on trig count

clear all

%% Saving parameters
date = datestr(datetime, 'yyyy-mm-dd');
directory=['E:\Projects\NeuroStim\Data\' date '\'];
x = input('run number?');
filename = ['Run' num2str(x, '%02x')];
if exist(filename, 'file') == 2
    disp( [filename ' already exists'])
end
mkdir(directory);
fish=input('Fish specs : ', 's');

%% configure boards = daq.createSession('ni')
configureDAQboard

%% microscopy & stim parameters
%--------------------------------------------------------------------------

% ... Set timing ...
exposure = 90; %ms
delay = 10;
delay_long = 10;
nboflayers = 10;
expdel = (exposure+delay)/1000;
 
stimlengthMINUTES = 0;
wanted_stim_period = 7; % secs
wanted_exp_length = 20; % min

disp({'Exposure', 'Delay', 'Long delay', 'Nb of layers', 'Stim period', 'Experiment length'})
disp({exposure, delay, delay_long, nboflayers, wanted_stim_period, wanted_exp_length})

% ... OKR parameters ...
bandsizemm = 6;
pixmmRatio = 3;  
Amp = 100 ; %amplitude of OKR stimulus in px
okrp = 12; % half-period of stim

% --- Timing & coordination calculation ---
if stimlengthMINUTES
    % LONG STIM
    [new_exp_length, stimPeriodDuration, nb_stim_periods, proposed_nb_of_cycles, cycle_length] = ...
        calcNbOfuFrames(wanted_stim_period, wanted_exp_length, exposure, delay, delay_long, nboflayers)
    disp('LONG stim')
else
    % SHORT STIM
    [new_exp_length, stimPeriodDuration, nb_stim_periods, proposed_nb_of_cycles, cycle_length] = ...
        calcNbOfuFramesShortStim(wanted_stim_period, wanted_exp_length, exposure, delay, delay_long, nboflayers)
    disp('SHORT stim')
end
totNbframes = round(proposed_nb_of_cycles*nboflayers);
disp(totNbframes)
minInitialStimDurationInFrames = (5*60)/expdel;
if totNbframes/nb_stim_periods < minInitialStimDurationInFrames
    mult = minInitialStimDurationInFrames/(totNbframes/nb_stim_periods);
    initial_stim_length_in_frames = round(mult)*totNbframes/nb_stim_periods;
end

% --- stim waveform ---
%[Opacity] = exp_params_trig(nb_stim_periods, stimPeriod, cycle_length, nboflayers);
bluefilter = 1;
OD = 1;
[Opacity, Isim, dIIsim] = GenerateIntensityRandomdII(nb_stim_periods, stimPeriodDuration, cycle_length, nboflayers, bluefilter, OD);
%***
f = figure;
plot(Opacity);
waitfor(f);

%% configure PTB
configurePTB

baseRect = [0 0 800 800];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);

%% loop on checking voltage input, if non-null, trigger stim
disp('...')
while ~in
    in = inputSingleScan(s1);
end

disp('launching')

% --- initialize variables ---
vbl = NaN(totNbframes,1);
triggertstamp = NaN(totNbframes,1);
trigcount = NaN(totNbframes,1);

% === OKR STIM ===
%..........................................................................                                
bandsizepix = bandsizemm*pixmmRatio;              
bwsegments = round(screenYpixels/bandsizepix);
texturematrix = createLinPatternVert(bwsegments, white, black,...
    screenXpixels, screenYpixels);
finalimage = Screen('MakeTexture', window, texturematrix);
xoffset = NaN(1,initial_stim_length_in_frames);
w = 2*pi/okrp;

while in <= initial_stim_length_in_frames
    [in, tstamp] = inputSingleScan(s1);
    xoffset(in) = Amp*sin(in*expdel*w); 
    srcRect = [xoffset(in) 0 screenXpixels+xoffset(in) screenYpixels];
    Screen('DrawTexture', window, finalimage, srcRect, [], [], [], [], [255 0 0]);
    trigcount(in) = in;
    vbl(in) = Screen('Flip', window);
    triggertstamp(in) = tstamp;
end

% --- close filter ---
outputSingleScan(s2,0)
outputSingleScan(s2,1)

% === PHOTOT STIM ===
%..........................................................................
while in > initial_stim_length_in_frames && in < totNbframes
    [in, tstamp] = inputSingleScan(s1);
    rectColor = [1 0 1 Opacity(in)];
    Screen('FillRect', window, rectColor, centeredRect);   
    trigcount(in) = in;
    vbl(in) = Screen('Flip', window);
    triggertstamp(in) = tstamp;
end
disp('ending...')
pause(2);

stimWaveForm = Opacity;
stimWaveform(1 : length(xoffset)) = xoffset;

%% Save : store in S

S.type = 'stim 2P';
S.dateTime = datetime;
S.fish = fish;
S.NumberStimPeriods = nb_stim_periods;
S.w = w;
S.okrperiod = okrp;
S.okramp = Amp;
S.OKRsignal = xoffset;
S.OKRcomment = 'flow to the left = increasing';
S.StimPeriod = stimPeriodDuration;
S.Opacity = Opacity;
S.StimWaveform = stimWaveform;
S.StimColor = rectColor(1:3);
S.vbl = vbl;
S.TriggerTimeStamp = triggertstamp;

save([directory filename], 'S');

disp('done');

%% standby screen projection

rectend = [0 0 0];
Screen('FillRect', window, rectend, centeredRect);   
Screen('Flip', window);

outputSingleScan(s2,0)
outputSingleScan(s2,1)

disp('end of script')

%sca;