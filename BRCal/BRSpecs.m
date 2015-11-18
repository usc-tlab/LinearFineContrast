function [LMin,LMax,minLIncrement] = BRSpecs(cal)
%function [LMin,LMax,LIncrement] = BRSpecs(cal)
%Returns various limits for a given calibration data structure

LMin = V2L([0 0 0],cal);
LMax = V2L([floor(cal.BRratio) 0 255],cal);
if cal.BRratio<=1
	k = 1;
else
	k = cal.BRratio;
end

minLIncrement = (V2L([0 0 255],cal)-V2L([0 0 254],cal))/k;
