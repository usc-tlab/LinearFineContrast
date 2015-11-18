function grayvector = L2V(lum, cal)
% function grayvector = L2V(lum, cal)
%
% 10/01: BT wrote it

sz = size(lum);
dm = length(sz);
lum(lum<0) = 0;
g = cal.C+cal.Beta*lum.^(1/cal.Gamma);
if cal.BRratio < 1
	b = round(g);
	grayvector = cat(dm+1,b,b,b);
else
	b = min(255,floor(g));
	r = round((g-b)*cal.BRratio);
	grayvector = cat(dm+1,r,zeros(size(b)),b);
end
