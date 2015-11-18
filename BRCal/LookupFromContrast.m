function [im,pcoutofrng] = LookupFromContrast(im_contrast, bgLum, transCLUT, cal)
% function im = LookupFromContrast(im, bgLum, transCLUT, cal)
% 
% Translate from an gray scale image specifed in Weber contrast
% to an rgb image for the attenuator by table lookup 
% (and hence much faster running L2V on each pixel) 

% 6/02 BT wrote it
% 10/13 BT: calculated the percentage of the out of range pixels

im_lum = im_contrast*bgLum+bgLum;
[im,pcoutofrng] = LookupFromLuminance(im_lum,transCLUT,cal);
