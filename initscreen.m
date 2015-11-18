% initscreen
% Only works on GL version of psychtoolbox

% Load screen calibration file

addpath([pwd filesep 'BRCal'],'-begin');
load BRcal
[LMin LMax minLuminanceIncrement] = BRSpecs(BRcal);
identityCLUT = repmat([0:255]',1,3);
subdivisions = useBRcal;
entryN=round(256*subdivisions);
LBackgroundCal=0.5;
backgroundEntry=round((LBackgroundCal-LMin)/(LMax-LMin)*(entryN-1));
transCLUT=BRcontrastset((LMax-LMin)/LBackgroundCal/(entryN-1),[0 entryN-1 backgroundEntry LBackgroundCal],[],BRcal);
LBackground = V2L(transCLUT(backgroundEntry+1,:),BRcal);
LMin = V2L(transCLUT(1,:),BRcal);
LMax = V2L(transCLUT(entryN,:),BRcal);
stepsPerContrast=(entryN-1)/((LMax-LMin)/LBackground);
if LMin+(entryN-1)*minLuminanceIncrement>LMax
	error('Duplicate entries in CLUT. Reduce "useBRCal" variable and try again.');
end

backgroundEntry = transCLUT(backgroundEntry+1,:);
expr.CMin = minLuminanceIncrement/LBackground; % minimum non-zero contrast

% initialize screen
[win winrect] = Screen(scr,'OpenWindow',[],[],32);
framedur = Screen('getflipinterval',win)
if useBRcal >= 1
    Screen('LoadNormalizedGammaTable', win, repmat(linspace(0,1,256)',[1,3]));
end
HideCursor;
Screen('FillRect',win,backgroundEntry);
Screen(win,'TextSize',24);
Screen('flip',win);

% define a 'texture' for fixation
fiximg = ones(3)*expr.fixcontrast; % contrast for fixation
fiximg = LookupFromContrast(fiximg,LBackground,transCLUT,BRcal);
fixtex = Screen('maketexture',win,fiximg);

maxpriority = MaxPriority(win);
