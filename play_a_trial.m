%play_a_trial

% command strings for rush

Priority(1);

FlushEvents('keydown');
Screen('fillrect',win,backgroundEntry);
Screen('drawtexture',win,fixtex);
Screen('flip',win);
Screen('fillrect',win,backgroundEntry)
Screen('drawtexture',win,stmtex);
WaitSecs(expr.soa/1000-framedur+0.001); %discount 1 frame since flip will be at the beginning of the next frame
Screen('flip',win);
t0 = GetSecs;
Screen('fillrect',win,backgroundEntry);
Screen('drawtexture',win,fixtex);
WaitSecs(expr.duration/1000-framedur+0.001); 
Screen('flip',win);
t1 = GetSecs;

Priority(0);

[keydown,s,keycode] = KbCheck;
while ~keydown & GetSecs-t0<10 % 10 sec max. response time
   [keydown,s,keycode] = KbCheck;
end;
FlushEvents('keydown');

% now do all the elevations
% reaction time
rt=s-t0;
% actual display duration
act_duration=t1-t0
% determine which key is pressed
resp = find(keycode);
if isempty(resp)
    resp = 0; % time out
else
    resp = resp(1); % in case more than one key is pressed
end
