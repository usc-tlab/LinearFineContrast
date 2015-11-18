function lum = V2L(grayvector, cal)
% function lum = V2L(grayvectors, cal)
% grayvector can be rows or an array of triples of graylevels
%
% 10/01: BT wrote it

sz = size(grayvector);
szv = prod(sz(1:end-1));
grayvector = reshape(grayvector,[szv,3]);
if cal.BRratio <= 1
	lum = ((grayvector(:,3)-cal.C)/cal.Beta);
	lum(lum<0) = 0;
	lum = lum.^cal.Gamma;
else
	lum = ((grayvector(:,1)/cal.BRratio+grayvector(:,3)-cal.C)/cal.Beta);
	lum(lum<0) = 0;
	lum = lum.^cal.Gamma;
end
lum = reshape(lum,[sz(1:end-1),1]);
