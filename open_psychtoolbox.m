function [screenXpixels, screenYpixels, window, white, black, ifi, windowRect,...
    xCenter,yCenter,vbl] = open_psychtoolbox()
%% Comments
% Open the psychtoolbox window
%Outputs -----
% screenXpixels: size x of the screen
% screenYpixels: size y of the screen
% window: number of the opened window
% white: color white
% black: color black
% ifi: frame duration (1/ifi: framerate)

%% Code
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% skip syncing (problems with internal psychtoolbox timing)
Screen('Preference', 'SkipSyncTests', 1);
% Get the screen numbers
screens = Screen('Screens');
% Select external screen
screenNumber = 1;
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);
% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% Get the size of the on screen window (resolution)
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
% Set up alpha-blending for smooth (anti-aliased) lines
% IMPORTANT FOR WORKING WITH THE OPACITY !!
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% vbl
Screen('FillRect', window, white);
vbl = Screen('Flip', window);