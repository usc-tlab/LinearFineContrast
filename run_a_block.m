% run_a_block
% run a block of experiment

% prepare stimulus
for i=1:length(target)
   targ{i} = spreadout(target{i},pn(1));
   if pn(2) ~= 2 % inverted
      targ{i} = targ{i}(end:-1:1,:);
   end
end
targrect = [1 1 size(targ{1},2) size(targ{1},1)];
targrect = centerrect(targrect,winrect);

% initialize QUEST
q=QuestCreate(expr.q0.guess,expr.q0.priorSd,expr.q0.pCorrect,expr.q0.beta,expr.q0.delta,expr.q0.gamma);

waitsecs(0.2);
flushevents('keyDown');
% fixation
screen('fillrect',win,backgroundEntry);
screen('drawtexture',win,fixtex);
% provide instruction
screen(win,'drawtext','Press "r" or "t" depending on the displayed letter.',5,30,0);
screen(win,'drawtext','Press spacebar to continue.',5,60,0);
screen(win,'drawtext','Press "q" to quit.',5,90,0);
screen('flip',win);
[keydown, ignore, keycode] = kbcheck;
while ~keydown
    [keydown, ignore, keycode] = kbcheck;
end
if keycode(kbName('q'))
   screen(win,'close'); showcursor
   return % exit the program
end
flushevents('keydown');

for i=1:expr.ntrial
   % pick a target
   ti = floor(rand*length(target))+1;
   % get a test contrast from QUEST
   logc = QuestQuantile(q);
   c = 10^logc;
   if c>1 % cap contrast to a maximum of 1
      c=1;
   end
   % set the simulus contrast
   stim = targ{ti}*c;
   % convert from contrast to a calibrated RGB image
   stim = LookupFromContrast(stim,LBackground,transCLUT,BRcal);
   % convert this to a texture
   stmtex = screen('maketexture',win,stim);
   % present the stimulus and get the response
   play_a_trial;
   % determine if the response is correct
   iscorrect = (resp==expr.imkey(ti));
   % update QUEST
   logc = log10(c);
   q = QuestUpdate(q,logc,iscorrect);
   % get current threshold estimates
   logc_thd = QuestMean(q);
   % record the data
	% [block spread orient target duration log_contrast resp correct log_thd_contrast]
   data(i,:) = [block,pn,ti,act_duration,logc,resp,iscorrect,logc_thd];
end