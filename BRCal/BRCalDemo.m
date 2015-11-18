% A demo code for using the "BRCal" gamma linearization routines with
% much-larger-than-256-grey-level-per-image support
%
% Credits: The visual calibration routine "BRCalibrator.m" is from Dr. Zhong-Lin Lu
%          For the rest, blame Dr. Bosco Tjan (btjan@usc.edu), 10/2001

clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add path if the this m-file is at the same level as the BRCal folder
% addpath([pwd 'BRCal'],'-begin');

% load the calibration file "BRCal.mat" in the "BRCal" folder
load BRCal

% get limits from the calibration file
% (All luminance values are in 0-1 range of normalized units)
[LMin LMax minLuminanceIncrement] = BRSpecs(BRcal);

% We will create two CLUTs, one is a simple "straight through", with 256 entries,
% which we will attach to a window (using the "SetClut" command).  The other 
% one will have thousands of entries, which we will use to translate a floating
% point image to rgb values for the attenuator.  The second table is the one that
% linearize the screen gamma.  The number of entries in this second table depends on 
% minLuminanceIncrement and the gamma of the display.  Once the two tables
% have been generated, no more changes in either is need regardless of what
% contrast range we want to display.

% Just before the very last CLUT translation step, the image we want to display 
% is stored as a 2-D array of floating point numbers as luminance values in
% normalized units between 0 and 1, or as Weber contrast.

% First, the "straight through" table:
identityCLUT = repmat([0:255]',1,3);

% Now the translation color lookup table:
subdivisions = 0.5; % 0.5 is for using without an attenuator
%subdivisions = 12; % number of subdivisions between each full greylevel step
                   % increase this number until you get an "Duplicate entry"
				   % error -- to maximize luminance resolution (11 is the max
				   % for my monitor)
entryN=round(256*subdivisions);  % number of entries in the translation CLUT

% specify the mean luminance (all luminance in relative units from 0-1)
LBackgroundCal=0.5; % this doesn't have to be 0.5
% find the entry that correspond to LBackgroundCal
% ["entry" starts at 0, but matrix index in matlab starts at 1]
backgroundEntry=round((LBackgroundCal-LMin)/(LMax-LMin)*(entryN-1));
% now form the translation CLUT of 256*subdivisions entries
transCLUT=BRcontrastset((LMax-LMin)/LBackgroundCal/(entryN-1), ...
			[0 entryN-1 backgroundEntry LBackgroundCal],[],BRcal);

% get the post-calibration luminances -- min, max, and background 
LBackground = V2L(transCLUT(backgroundEntry+1,:),BRcal);
LMin = V2L(transCLUT(1,:),BRcal);
LMax = V2L(transCLUT(entryN,:),BRcal);

% figure out the number of resolvable luminance steps per unit Weber contrast
stepsPerContrast=(entryN-1)/((LMax-LMin)/LBackground);

% check if any entry in transCLUT may be duplicated (happens with subdivisionN is too for the display)
if LMin+(entryN-1)*minLuminanceIncrement>LMax
	error('Duplicate entries in CLUT. Reduce "subdivision" and try again');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we are done with the calibration.  The variables that may be
% of interest to your code are:
%       BRCal        -- the calibration
% 		transCLUT    -- the all important translation CLUT
%       identityCLUT -- dummy "straight through" CLUT
%       LBackground  -- background luminance in normailzed (0-1) units
%       backgroundEntry  -- the "entry" in transCLUT that corresponds to LBackground
%                           note that the an "entry" is 0-based, while matlab array index
%                           is 1-based.  So, the convertion between entry and index is 
%                           index = entry+1
%       stepsPerContrast -- number of distinct gray-level steop per unit contrast
%       LMin         -- minimum post-calibration luminance
%       LMax         -- maximum post-calibration luminance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% Now do something useful %%%%%%%%%%%%%%%%%%%
% All screen calls uses PsychoToolbox for OS X V1.0.6 (or above)

%%%% Initialize a window
win = screen('OpenWindow',0,[],[],32,2); % open a window with 32-bits
screen('loadnormalizedgammatable',win,identityCLUT/255);		% straight-through clut
screen('FillRect',win,transCLUT(backgroundEntry+1,:)); % fill the screen in mid-gray
screen('Flip',win);
screen('FillRect',win,transCLUT(backgroundEntry+1,:)); % fill the screen in mid-gray the other buffer
screen('Flip',win);
screen('TextSize',win,24);

%%%% Prepare the stimuli, all done in contrast units
c=0.5; % max. contrast for the gratings
[x y] = meshgrid(-1:0.01:1,1:200);
gratingOdd = sin(2*pi*x).*c.*(mod(y,2));     % a grating on odd scan lines, 0 contrast on even lines
gratingEven = -sin(2*pi*x).*c.*(mod(y+1,2)); % counter-phased grating on even lines, 0 contrast on odd lines
gratingCombined = gratingOdd+gratingEven;

%%%% Translate the stimuli to RGB values
imgOdd = LookupFromContrast(gratingOdd,LBackground,transCLUT,BRcal);
imgEven = LookupFromContrast(gratingEven,LBackground,transCLUT,BRcal);
imgCombined = LookupFromContrast(gratingCombined,LBackground,transCLUT,BRcal);

%%%% Present the stimuli
imgOddx = screen('MakeTexture',win,imgOdd); % this replace the usage of OffScreenWindows
screen('DrawTexture',win,imgOddx);
% here is how text may be displayed at a specific luminance
screen('DrawText',win,'A low-frequency sinewave grating.  Press any key to continue.',0,26,squeeze(L2V(0.9,BRcal))');
screen('Flip',win);
waitsecs(0.2);
kbWait;

screen('FillRect',win,transCLUT(backgroundEntry+1,:)); % erase the screen
screen('PutImage',win,imgEven); % you can also use PutImage, but it's slower
screen('DrawText',win,'Same grate but shifted 180 deg.  Press any key to continue.',0,26,squeeze(L2V(0.9,BRcal))');
screen('Flip',win);
waitsecs(0.2);
kbWait;

screen('FillRect',win,transCLUT(backgroundEntry+1,:)); % erase the screen
screen('PutImage',win,imgCombined);
screen('DrawText',win,'Counter-phased gratings on alternate scan line.',0,26,squeeze(L2V(0.9,BRcal))');
screen('DrawText',win,'Should see NOTHING if calibration is perfect & inter-pixel dependence is absent.',0,52,squeeze(L2V(0.9,BRcal))');
screen('DrawText',win,'Press any key to rotate the grating.',0,78,squeeze(L2V(0.9,BRcal))');
screen('Flip',win);
waitsecs(0.2);
kbWait

screen('FillRect',win,transCLUT(backgroundEntry+1,:)); % erase the screen
screen('PutImage',win, cat(3,imgCombined(:,:,1)',imgCombined(:,:,2)',imgCombined(:,:,3)'));
screen('DrawText',win,'Counter-phased gratings on alternate scan line.',0,26,squeeze(L2V(0.9,BRcal))');
screen('DrawText',win,'Should see NOTHING if calibration is perfect & inter-pixel dependence is absent.',0,52,squeeze(L2V(0.9,BRcal))');
screen('DrawText',win,'Press any key to quit.',0,78,squeeze(L2V(0.9,BRcal))');
screen('Flip',win);
waitsecs(0.2);
kbWait

%%%% Done
screen('CloseAll');
