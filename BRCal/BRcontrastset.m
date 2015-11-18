function [clut, clutrng] = BRcontrastset(contraststep,clutrng,clut,BRcal)
% function [clut, clutrng] = BRcontrastset(contraststep,clutrng,clut,BRcal)
% set contrast with calibration data from BRCalibrator.
% clutrng = [firstEntry, lastEntry, bgEntry, bgLum] specifies the clut range
% contraststep specifies weber contrast per clut step.
% All gray levels are in [0 255], and all luminance values are in [0 1]
% Entries are 0-based
%
% gray_level = C+Beta*lum^(1/Gamma)
%
% 10/01: BT wrote it

[lumMin lumMax incr] = BRSpecs(BRcal);
lumMax = V2L([255 0 255],BRcal);
if clutrng(4) < 0
	clutrng(4) = (lumMin+lumMax)/2;
end

crng = clutrng(1):sign(clutrng(2)-clutrng(1)):clutrng(2);
l = (crng-clutrng(3))*contraststep*clutrng(4)+clutrng(4);
%handle out-of-bounds that are within roundoff error
l(l<lumMin&l>lumMin-incr/2) = lumMin;
l(l>lumMax&l<lumMax+incr/2) = lumMax;
if min(l)<lumMin | max(l)>lumMax
	msg = sprintf('Requested luminance out of range.  Clipped to [0 1]\n');
	msg2 = sprintf('%f\n', l(l<lumMin|l>lumMax));
	warning([msg,msg2]);
	l(l<lumMin) = lumMin;
	l(l>lumMax) = lumMax;
end

clut(crng+1,1:3) = L2V(l',BRcal);

clut(clut<0) = 0;
clut(clut>255) = 255;
clutrng(4) = V2L(clut(clutrng(3)+1,:),BRcal);
