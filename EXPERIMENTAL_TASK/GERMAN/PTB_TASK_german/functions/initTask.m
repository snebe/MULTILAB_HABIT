function [var,data]= initTask(var)

% last modified in June 2017

AssertOpenGL; % Check for Opengl compatibility, abort otherwise:
KbName('UnifyKeyNames');% Make sure keyboard mapping is the same on all supported operating systems (% Apple MacOS/X, MS-Windows and GNU/Linux)
KbCheck; WaitSecs(0.1); GetSecs; FlushEvents; % clean the keyboard memory Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure they are loaded and ready when we need them - without delays
% rand('state',sum(100.*clock));% reset randperm to avoid the same seq

Screen('Preference','SyncTestSettings' , 0.01, [], [], []); % Increasing the amount of tolerable noisiness in the synch test from 1 to 10ms, because Windows often has more noisy synch timing.
whichScreen = max(Screen('Screens'));
maxPriorityLevel = MaxPriority(whichScreen);
Priority(maxPriorityLevel);

%**************************************************************************
% CREATE RESULT FILE FOR THE SESSION
var.date=char(datetime('now','Format','yyyy-MM-dd'));
var.hour=char(datetime('now','Format','HH-mm'));

var.resultFile = (strcat('Pool_', var.sub_ID, '_', var.date, '_', var.hour, '.mat'));

if var.real==0 
    var.save_path='N:\client_write\Stephan\data\';
else
    var.save_path='data\';
end

% Check that the file does not already exist to avoid overwriting
% if exist(var.resultFile,'file')
%     resp=questdlg({['The file ' var.resultFile ' already exists.']; 'Do you want to overwrite it?'},...
%         'File exists warning','Cancel','Ok','Ok');
%     
%     if strcmp(resp,'Cancel') % Abort experiment if overwriting was not confirmed
%         error('Overwriting was not confirmed: experiment aborted!');
%     end
%     
% end

%**************************************************************************
% OPEN PST
PsychDefaultSetup(1);% Here we call some default settings for setting up PTB
screenNumber = max(Screen('Screens'));  % check if there are one or two screens and use the second screen when if there is one
imagingmode = kPsychNeedFastBackingStore;	% flip takes ages without this

if var.real == 1
     Screen('Preference', 'SkipSyncTests', 0); % we are not interested in precise timing
    [var.w, var.rect] = Screen('OpenWindow',screenNumber, [180 180 180],[20 20 1500 1000]);
else
    [var.w, var.rect] = Screen('OpenWindow',screenNumber, [180 180 180],[],[],2,[],[],imagingmode);
end


% Set blend function for alpha blending (for the png images)
Screen('BlendFunction', var.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%**************************************************************************
% SET TASK PARAMETERS
%**************************************************************************

% button code

% for behavior
var.leftKey        = [ KbName('d'), KbName('d') ];
var.centerLeftKey  = [ KbName('f'), KbName('f') ];
var.centerRightKey = [ KbName('j'), KbName('J') ];
var.rightKey       = [ KbName('k'), KbName('k') ];
var.mycontrol      = KbName('space');
var.pulseKeyCode   = KbName('space'); % to start each run

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE POSITIONS

[var.screenXpixels, var.screenYpixels] = Screen('WindowSize', var.w);% Ge
[var.xCenter, var.yCenter] = RectCenter(var.rect);% Get the centre coordinate of the windo

ROIlt = 0.35;  %from the left and from the top co-ordinates for left and top ROI
space = 0.10;

var.yUpper = 0.25*var.screenYpixels;
var.yLower = 0.75*var.screenYpixels;
var.yUpperHigh = 0.10*var.screenYpixels;
var.yLowerLow  = 0.85*var.screenYpixels;

var.squareXpos = [var.screenXpixels * ROIlt var.screenXpixels * (ROIlt+1*space) var.screenXpixels * (ROIlt+2*space) var.screenXpixels * (ROIlt+3*space)]; % Define horizontal ROIs position (0.25 0.75 were the original settings)

var.square1 = var.screenXpixels * ROIlt;
var.square2 = var.screenXpixels * (ROIlt+1*space);
var.square3 = var.screenXpixels * (ROIlt+2*space);
var.square4 = var.screenXpixels * (ROIlt+3*space);

var.CUEdim      = RectHeight(var.rect)/16; % the pixel of the ROI are defined based on the screeen
var.FRACTALdim  = RectHeight(var.rect)/3;  % the pixel of the ROI are defined based on the screeen
var.REWARDdim   = RectHeight(var.rect)/8;  % pixels of reward display
var.ACTIONdim   = RectHeight(var.rect)/16; % pixels of instrumental action feedback display
var.allColors   = [250 250 250 250; 250 250 250 250; 0 0 0 0];% Set the colors of the ROI frames

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTERBALANCE STIMULUS-RESPONSE-OUTCOME
[var, data] = counterbalance(var);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NUMBER OF RUNS 

if var.training == 1 % instrumental action training
    var.runs = 2;
elseif var.training == 3 % habitual training
    var.runs = 4;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULT TEXT STYLE
% scale text size to the screen used
textref = 30;
windowref_y = 1560; % we want some thing that correpond to a size of 30 on a screen with a y of 1560
var.scaledSize = round((textref * var.rect(4)) / windowref_y);

% set screen setting

Screen('TextFont', var.w, 'Arial');
Screen('TextSize', var.w, var.scaledSize);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD IMAGES OF SNACKS USED AS SWEET AND SALTY
[var] = uploadImages (var);
% data.sweetID = var.sweetLabel;
% data.saltyID = var.saltyLabel;

data.screen = var.rect;
% data.SubDate= datestr(now, 24); % Use datestr to get the date in the format dd/mm/yyyy
% data.SubHour= datestr(now, 13); % Use datestr to get the time in the format hh:mm:ss

end