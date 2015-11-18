function [slope_intercept, rmsError]=calcheck(scrnum,bgentry,imsz,stimc,clut,BRcal)
% function [slope_intercept, rmsError]=calcheck(scrnum,bgentry,imsz,stimc,clut,BRcal)
% Display five gray levels within clutrng, ask for luminance measurements, 
% plots luminance vs entry, and compute rms error.
% Bgentry (background graylevel) and imsz (image size) should be as close
% to the experimental condition as possible.

% 11/15: BT changed 'screen' to 'Screen' to conform with Matlab 2013+

clutrng = stimc.clutRng;
cstep = stimc.step;
% plot the current clut setting
% adopted from VisualGammaDemo
figure
E = (clutrng(1):sign(clutrng(2)-clutrng(1)):clutrng(2))';
L = V2L(clut(E+1,:),BRcal);
lines=plot(E,L,'-');
axis([min(E) max(E) min(L) max(L)]);
for i=1:length(lines)
	set(lines(i),'LineWidth',2);
	set(lines(i),'MarkerSize',12);
end
set(gca,'LineWidth',1);
set(gca,'TickLength',2*get(gca,'TickLength'));
set(gca,'FontSize',14);
title(sprintf('Luminance measured on screen %d',scrnum),'FontSize',18);
xlabel('Gray Level','FontSize',24);
ylabel('Normalized luminance','FontSize',24);
drawnow

% plot the current clut setting in the range of +/- 3% 
figure
E = (clutrng(3)-round(.03/cstep)):(clutrng(3)+round(.03/cstep));
E = E(E>=clutrng(1)); 
E = E(E<=clutrng(2));
L = V2L(clut(E+1,:),BRcal);
lines=plot(E,L,'*-');
axis([min(E) max(E) min(L) max(L)]);
for i=1:length(lines)
	set(lines(i),'LineWidth',2);
	set(lines(i),'MarkerSize',12);
end
set(gca,'LineWidth',1);
set(gca,'TickLength',2*get(gca,'TickLength'));
set(gca,'FontSize',14);
title(sprintf('Normalized luminance for contrast in [%.2f %.2f]%%',(E(1)-clutrng(3))*cstep*100, (E(end)-clutrng(3))*cstep*100),'FontSize',18);
xlabel('Gray Level','FontSize',24);
ylabel('Normalize luminance','FontSize',24);
drawnow

% measure screen luminance
mnE = clutrng(1);
mxE = clutrng(2);
win = Screen(scrnum,'openwindow',bgentry);
Screen(win,'setclut',clut);
E = round(mnE:(mxE-mnE)/4:mxE);
L = [];
rect = Screen(scrnum,'rect');
rect(1:2) = rect(3:4)-[300, 120];
diag = Screen(scrnum,'openwindow',bgentry,rect);
Screen(diag,'setclut',clut);
for x = E,
	im = ones(imsz)*x;
	im(:,1) = mxE; im(:,end)=mxE; im(1,:)=mxE; im(end,:)=mxE;
	sysbeep;
	Screen(win,'putimage',im);
	L(end+1) = Screen(diag,'dialog','Luminance measured',9999);
end
Screen(diag,'close');
Screen(win,'close');
E1 = [E; ones(size(E))];
slope_intercept = L/E1;
Lest = slope_intercept*E1;
rmsError = (sum((Lest-L).^2)/length(L))^0.5;

% plot the measured results
figure
lines=plot(E,Lest,'-',E,L,'*');
axis([min(E) max(E) min(L) max(L)]);
for i=1:length(lines)
	set(lines(i),'LineWidth',2);
	set(lines(i),'MarkerSize',12);
end
set(gca,'LineWidth',1);
set(gca,'TickLength',2*get(gca,'TickLength'));
set(gca,'FontSize',14);
title(sprintf('Luminance measured on screen %d',scrnum),'FontSize',18);
xlabel('Gray Level','FontSize',24);
ylabel('Luminance (cd/m**2)','FontSize',24);
equation=sprintf('y=%.3f x + %.3f ± %.3f',slope_intercept,rmsError);
clear text
text(0.1*max(E),0.9*max(L),equation,'FontSize',20);
drawnow

