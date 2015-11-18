clear all
%function BRCalibrator
% Performs visual gamma calibration for B/W display
% with or without an attenuator, and in either case,
% the gray level for green is set at zero.
%
% ZL Lu wrote it
%
% 10/01	BT:	Cosmetic changes to make it user friendly
%           Improved frame switching rate
% 			Fixed a bug in Case 12
%			Put everything in BRCal and save it in .mat
%			Simplified log file
%           Use a better curve fitting function
%  9/06 BT: Update it to used the OpenGL version of psychotoolbox on OS X
%  10/3 BT: Update to limit the use of LoadNormalizedGammaTable, because it
%           crashes on certain graphics system.
%  9/08 BT: Minor changes: 1. leave the gamma table alone if running
%           without attenuator (BRrotio <= 1). 2. slow down key checks for
%           faster machines.
%  11/15 BT:B/R ratio calibration appears broken since the OpenGL version.
%  (grating too fine). Fixed.
%  11/15 BT:Changed 'screen' to 'Screen' to conform with Matlab 2013+

Screen('Preference', 'SkipSyncTests', 1);

bg = [30 30 30]; % changed from 10 to 30

filename=input('Enter the name for the log file (no quote): ', 's');
fid=fopen(filename,'a');
fprintf(fid, '\n%s\n',date);

% ask a few questions before the command window becomes inaccessible (the
% command would still be accessible in OS 9)
whichScreen=str2num(input('Which Screen Are You Going to Calibrate (0, 1, 2)? ','s'));
rect=CenterRect([0 0 192-1 192-1], Screen('Rect', whichScreen));		%frame size is 192*192
nframes=2;				%movie runs for 4*nframes, without repeats
pixelSizes=Screen('PixelSizes',whichScreen);
if max(pixelSizes)<24
    fprintf('Sorry, I need a screen that supports 24- or 32-bit pixelSize.\n');
    return;
end
ans=input('Do you know the B/R ratio (answer ''y'' and set to 0 if use without attenuator)? (y/n) ','s');
if  (ans=='y')
    BRratio=input('Please enter the B/R ratio: ');
else
    BRratio=[];
    rrr=input('Please enter an initial red value (0-255): ');
end

[window,screenRect]=Screen('OpenWindow',whichScreen,0,[],max(pixelSizes),2); % force 24/32 bit, double buffered

savedClut=Screen('ReadNormalizedGammaTable',window); % the values are between 0 and 1
if BRratio > 1 % use a identity gamma table with attenuator; use the built-in gamma table if no attenuator is used
    normalClut(:,:) = repmat(linspace(0,1,size(savedClut,1))',[1,3]); % linearize the gamma table
    Screen('LoadNormalizedGammaTable',window,normalClut);
end

Screen('textsize',window,18);
Screen('textcolor',window,127);
Screen('FillRect', window, bg); % changed from 10 to 30 (BT)
Screen('flip',window);
Screen('fillrect', window, bg);
Screen('flip',window);

lum = zeros([192 192 3]);

if isempty(BRratio)
    FlushEvents('keyDown');
    %Determine BRratio by matching [rrr 0 195] with [0 0 200].
    grating = zeros([12 12 3]);
    grating(1:2:end,:,1)=0;
    grating(1:2:end,:,2)=0;
    grating(1:2:end,:,3)=200;
    grating(2:2:end,:,1)=1; %rrr
    grating(2:2:end,:,2)=0;
    grating(2:2:end,:,3)=195;
    lum = imresize(grating, size(lum,1)/size(grating,1), 'nearest');
    idx = find(lum==1);

    Priority(MaxPriority(window,'KbCheck'));
    while (1)
        if ( rrr > 255 )
            rrr = 255;
        elseif ( rrr < 0 )
            rrr = 0;
        end
        BRratio = rrr/5.0;
        lum(idx)=rrr;
        Screen('fillrect',window,bg);
        msg = sprintf('"j" or "k" to null the grating, "q" when done.');
        Screen('drawtext',window,msg,0,0);
        Screen('putimage',window,lum);
        Screen('flip',window);
        [kd,s,kc] = KbCheck;
        if kd
            if kc(KbName('j'))
                rrr=rrr+1;
            elseif kc(KbName('k'))
                rrr=rrr-1;
            elseif kc(KbName('q'))
                break;
            elseif kc(KbName('escape'))
                clear Screen;
                return
            end		%end if
        end		%end while
    end
    Priority(0);
end		% end if

BRratio
fprintf(fid,'BRratio=%f\n', BRratio);

lum(:,:,:)=0;
rgbH=zeros(3);
rgbL=zeros(3);
M=zeros(15,3);

%keyboard;
%Fine luminance calibration:
for i=1:15,
    WaitSecs(0.2);
    FlushEvents('keyDown');
    switch i
        case 1
            rgbH(1)=0; rgbH(2)=0; rgbH(3)=255;
            rgbL(1)=0; rgb(2)=0; rgbL(3)=0;
        case 2
            rgbH(1)=0; rgbH(2)=0; rgbH(3)=255;
            rgbL(1) = M(1,1); rgbL(2)=M(1,2); rgbL(3)=M(1,3);
        case 3
            rgbH(1) = M(1,1); rgbH(2)=M(1,2); rgbH(3)=M(1,3);
            rgbL(1)=0; rgbL(2)=0; rgbL(3)=0;
        case 4
            rgbH(1)=0; rgbH(2)=0; rgbH(3)=255;
            rgbL(1) = M(2,1); rgbL(2)=M(2,2); rgbL(3)=M(2,3);
        case 5
            rgbH(1) = M(2,1); rgbH(2)=M(2,2); rgbH(3)=M(2,3);
            rgbL(1) = M(1,1); rgbL(2)=M(1,2); rgbL(3)=M(1,3);
        case 6
            rgbH(1) = M(1,1); rgbH(2)=M(1,2); rgbH(3)=M(1,3);
            rgbL(1)= M(3,1); rgbL(2)=M(3,2); rgbL(3)=M(3,3);
        case 7
            rgbH(1) = M(3,1); rgbH(2)=M(3,2); rgbH(3)=M(3,3);
            rgbL(1)=0; rgbL(2)=0; rgbL(3)=0;
        case 8
            rgbH(1)=0; rgbH(2)=0; rgbH(3)=255;
            rgbL(1) = M(4,1); rgbL(2)=M(4,2); rgbL(3)=M(4,3);
        case 9
            rgbH(1) = M(4,1); rgbH(2)=M(4,2); rgbH(3)=M(4,3);
            rgbL(1) = M(2,1); rgbL(2)=M(2,2); rgbL(3)=M(2,3);
        case 10
            rgbH(1)= M(2,1); rgbH(2)=M(2,2); rgbH(3)=M(2,3);
            rgbL(1) = M(5,1); rgbL(2)=M(5,2); rgbL(3)=M(5,3);
        case 11
            rgbH(1) = M(5,1); rgbH(2)=M(5,2); rgbH(3)=M(5,3);
            rgbL(1) = M(1,1); rgbL(2)=M(1,2); rgbL(3)=M(1,3);
        case 12
            rgbH(1) = M(1,1); rgbH(2)=M(1,2); rgbH(3)=M(1,3);
            rgbL(1) = M(6,1); rgbL(2)=M(6,2); rgbL(3)=M(6,3);
        case 13
            rgbH(1)= M(6,1); rgbH(2)=M(6,2); rgbH(3)=M(6,3);
            rgbL(1) = M(3,1); rgbL(2)=M(3,2); rgbL(3)=M(3,3);
        case 14
            rgbH(1) = M(3,1); rgbH(2)=M(3,2); rgbH(3)=M(3,3);
            rgbL(1) = M(7,1); rgbL(2)=M(7,2); rgbL(3)=M(7,3);
        case 15
            rgbH(1) = M(7,1); rgbH(2)=M(7,2); rgbH(3)=M(7,3);
            rgbL(1)=0; rgbL(2)=0; rgbL(3)=0;
    end		%end switch

    if ( BRratio <= 1 )
        rgbH(1)=rgbH(3);
        rgbH(2)=rgbH(3);
        rgbL(1)=rgbL(3);
        rgbL(2)=rgbL(3);
    end

    M(i,1)=round((rgbH(1)+rgbL(1))/2);
    M(i,2)=round((rgbH(2)+rgbL(2))/2);
    M(i,3)=round((rgbH(3)+rgbL(3))/2);

    %M(i,3)= input('Please type your initial guess for blue: ');
    if (BRratio <= 1)
        M(i, 1) = M(i, 3);
        M(i, 2) = M(i, 3);
    end

    n=0;
    kb=1;
    ntexture=0;
    slast = GetSecs;
    Priority(MaxPriority(window,'KbCheck'));
    while (1)
        msg2 = sprintf('"u" or "d" to null the grating; "j" or "k" to fine tune; "q" when done.\n');

        msg1 = sprintf('i= %d, rgbH= %4.1f %4.1f %4.1f, rgbL= %4.1f %4.1f %4.1f, M= %4.1f %4.1f %4.1f',...
            i, rgbH(1), rgbH(2), rgbH(3), rgbL(1), rgbL(2), rgbL(3), M(i,1), M(i,2), M(i,3));

        if kb || ntexture<2
            if kb
                ntexture=0;
            end
            lum((2-n):2:end,:,1) = rgbH(1);
            lum((2-n):2:end,:,2) = rgbH(2);
            lum((2-n):2:end,:,3) = rgbH(3);
            lum((1+n):2:end,:,1) = rgbL(1);
            lum((1+n):2:end,:,2) = rgbL(2);
            lum((1+n):2:end,:,3) = rgbL(3);
            lum(64:128,:,1) = M(i,1);
            lum(64:128,:,2) = M(i,2);
            lum(64:128,:,3) = M(i,3);
            tex(n+1)=Screen('maketexture',window,lum);
            ntexture = ntexture+1;
        end

        Screen('fillrect',window,bg);
        Screen('drawtext',window,msg1,0,0);
        Screen('drawtext',window,msg2,0,20);
        Screen('drawtexture',window,tex(n+1));
        Screen('flip',window);
        n = rem(n+1,2);
        [kb,s,kc] = KbCheck;
        if kb && (s-slast)<0.1
            kb = 0;
        elseif kb
            slast = s;
        end
        if kb
            if ( BRratio <= 1 )
                if kc(KbName('j')) || kc(KbName('u'))
                    M(i,3)=M(i,3)+1;
                elseif kc(KbName('k')) || kc(KbName('d'))
                    M(i,3)=M(i,3)-1;
                elseif kc(KbName('q'))
                    Screen('fillrect',window,bg);
                    Screen('flip',window);
                    break;
                end
                M(i, 1) = M(i, 3);
                M(i, 2) = M(i, 3);
            else
                if kc(KbName('j'))
                    M(i,1)=M(i,1)+1;
                elseif kc(KbName('u'))
                    M(i,3)=M(i,3)+1;
                elseif kc(KbName('k'))
                    M(i,1)=M(i,1)-1;
                elseif kc(KbName('d'))
                    M(i,3)=M(i,3)-1;
                elseif kc(KbName('q'))
                    Screen('fillrect',window,bg);
                    Screen('flip',window);
                    break;
                elseif kc(KbName('escape'))
                    clear Screen
                    return;
                end
            end
        end
        M(i,M(i,:)<0) = 0;
        M(i,M(i,:)>255) = 255;
    end		%end while.
    Priority(0);
    fprintf(fid,'%d %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f\n', i, rgbH(1), rgbH(2), rgbH(3), rgbL(1), rgbL(2), rgbL(3), M(i,1), M(i,2), M(i,3));
end		%end for i= 1 to 15.
Screen('loadnormalizedgammatable',window,savedClut);
Screen('CloseAll');

if ( BRratio <=1 )
    data=[
        %	0 0;
        0.0625 M(15, 3);
        0.1250 M(7, 3);
        0.1875 M(14, 3);
        0.2500 M(3, 3);
        0.3125 M(13, 3);
        0.3750 M(6, 3);
        0.4375 M(12, 3);
        0.50 M(1, 3);
        0.5625 M(11, 3);
        0.6250 M(5, 3);
        0.6875 M(10, 3);
        0.7500 M(2, 3);
        0.8125 M(9, 3);
        0.8750 M(4, 3);
        0.9375 M(8, 3);
        %	1.0 255
        ];
    data = [data, data(:,1)*0];
    BRratio = 0.5; % this value doesn't matter, but has to be < 1
else
    data=[
        %	0 0 0;
        0.0625 M(15, 3) M(15, 1);
        0.1250 M(7, 3) M(7, 1);
        0.1875 M(14, 3) M(14, 1);
        0.2500 M(3, 3) M(3, 1);
        0.3125 M(13, 3) M(13, 1);
        0.3750 M(6, 3) M(6, 1);
        0.4375 M(12, 3) M(12, 1);
        0.50 M(1, 3) M(1, 1);
        0.5625 M(11, 3) M(11, 1);
        0.6250 M(5, 3) M(5, 1);
        0.6875 M(10, 3) M(10, 1);
        0.7500 M(2, 3) M(2, 1);
        0.8125 M(9, 3) M(9, 1);
        0.8750 M(4, 3) M(4, 1);
        0.9375 M(8, 3) M(8, 1);
        %	1.0 255 0
        ];
end

p(1) = 25; 	% x0
p(2) = 2;	% gamma
opt = optimset('MaxFunEvals',10000, 'MaxIter', 10000, 'TolFun', 1e-13, 'TolX', 1e-13);
newp = fminsearch(@(x)BRMonitorGammaError(x,data(:,3), data(:,2), data(:,1), BRratio), p(1:2),opt);

Gamma = newp(2);
C = newp(1);
Beta = 255-newp(1);

x = data(:,1);
x2 = [0; x];
y2 = C+Beta*x2.^(1/Gamma);
% if BRratio > 1
% 	brr = (y2-data(:,2))\data(:,3);
% 	if brr < 0
% 		brr = Inf;
% 	elseif br <= 1
% 		brr = BRratio;
% 	end
% 	BRratio = brr;
% end

y1=data(:,2)+data(:,3)/BRratio;

figure;
plot(x, y1, 'xg');
hold on
plot(x2, y2, '-y');
hold off

y2 = y2(2:end);
y2=y2-mean(y2);
y3=y1-mean(y1);
cor1 = y2'*y3/sqrt(y3'*y3)/sqrt(y2'*y2);

equation=sprintf('Red/%.2f+Blue = %.2f+%.2f*Lum.**(1/%.2f), R=%f',BRratio,C,Beta,Gamma,cor1);
clear text
text(0.02*max(x),0.95*max(y1),equation,'FontSize',12);
drawnow

fprintf('Gamma=%f, BRratio=%f, C=%f, Beta=%f, correlation=%f\n', Gamma, BRratio, C, Beta, cor1);
fprintf(fid,'Gamma=%f, BRratio=%f, C=%f, Beta=%f, correlation=%f\n', Gamma, BRratio, C, Beta, cor1);

BRcal.scrnum = whichScreen;
BRcal.M = M;
BRcal.data = data;
BRcal.BRratio = BRratio;
BRcal.Gamma = Gamma;
BRcal.Beta = Beta; % max gray level
BRcal.C = C; %gray level at 0 lum
save BRcal.mat BRcal

fprintf('\nNow The Calibration Is Done!\n');
fclose(fid);
