%play_a_trial

% command strings for rush

Priority(1);

flushevents('keydown');
screen('fillrect',win,backgroundEntry);
screen('drawtexture',win,fixtex);
screen('flip',win);
screen('fillrect',win,backgroundEntry)
screen('drawtexture',win,stmtex);
waitsecs(expr.soa/1000-framedur+0.001); %discount 1 frame since flip will be at the beginning of the next frame
screen('flip',win);
t0 = getsecs;
screen('fillrect',win,backgroundEntry);
screen('drawtexture',win,fixtex);
waitsecs(expr.duration/1000-framedur+0.001); 
screen('flip',win);
t1 = getsecs;

Priority(0);

[keydown,s,keycode] = kbcheck;
while ~keydown & getsecs-t0<10 % 10 sec max. response time
   [keydown,s,keycode] = kbcheck;
end;
flushevents('keydown');

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
