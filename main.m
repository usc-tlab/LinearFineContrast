% main
% Bosco Tjan wrote it in 2003 for a matlab crash course
% 9/2007 BT change it to run on the version of psychtoolbox that uses OpenGL
%        This code has been tested on OS X.  Good luck with Windows!
% 11/2015 BT made the code conforming to case-sensitive Matlab!

%% BEGIN experimental parameters

%test conditions
expr.spread = [1 4 16];
expr.orientation = {'upright','inverted'};

%number of measurements
expr.nrepeat = 4;
expr.ntrial = 40;
expr.thisblock = 1;
expr.state = sum(100*clock);

%info about stimuli
expr.imagefile = {'s25-r','s25-t'};
expr.imkey = [KbName('r') KbName('t')]; % these key codes are machine dependent
expr.imsize = [128 128];
expr.duration = 250; % stimulus presentation time in ms
expr.soa = 500; % time between response and onset of next trial ms
expr.fixcontrast = 0.5; % contrast of fixation point

%init parameters for QUEST
expr.q0.guess=log10(0.3);
expr.q0.priorSd=5;
expr.q0.beta=3.5;
expr.q0.delta=0.01;
expr.q0.gamma=1/length(expr.imkey);
expr.q0.pCorrect = .75;
%q=QuestCreate(guess,priorSd,pCorrect,beta,delta,gamma); -- this is how you would initalize QUEST

expr.data = []; %place holder
% END experimental parameters

%% make plans
rand('state',expr.state);
expr.subj = input('Enter subj ID: ','s');
if exist([expr.subj '.mat'],'file')
   load('-MAT',[expr.subj '.mat']);
else
   % make new plans
   plan = []; % each row of 'plan' describes the testing condition for a block
   for i = 1:expr.nrepeat
      % make a cross product of all conditions
      [s o] = ndgrid(1:length(expr.spread),1:length(expr.orientation));
      pp = [s(:) o(:)];
      % randomize the order
      [ignore idx] = sort(rand([size(pp,1) 1]));
      pp = pp(idx,:);
      plan = [plan; pp];
   end
   expr.plan = plan; % store the new plan in expr data structure
end 

%% load stimuli
readstims;  % the loaded stims are in 'target', in contrast units

%prepare screen
scr = 0;
%useBRcal = 10; % use with video attenuator
useBRcal = 0.3; % testing without attenuator
initscreen; % screen will go blank at this point (bad if you are debugging)

% data format (a reminder)
% [block spread orient target duration log_contrast resp correct log_thd_contrast]

%% run the experiment
nblock = size(expr.plan,1); % total number of block
for block = expr.thisblock:nblock
   pn = expr.plan(block,:); % pull out the current plan
   data=[];
   run_a_block;
   if isempty(data)
      return
   end
   expr.data = [expr.data; data];
   expr.thisblock = expr.thisblock+1;
   save([expr.subj '.mat'],'expr');
end
fprintf(1, 'All done!\n');

   