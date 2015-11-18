function im = LookupFromGray(im_gray,transCLUT)
% function im = LookupFromGray(im_gray,transCLUT)
%
% Translate from gray-level entries to rgb values to be pulled through
% the attenuator

% 6/02	BT wrote it

sz = size(im_gray);
im_gray = im_gray+1; % since entries are zero based
im = cat(3, ...
	uint8(reshape(transCLUT(im_gray,1),sz)), ...
	uint8(reshape(transCLUT(im_gray,2),sz)), ...
	uint8(reshape(transCLUT(im_gray,3),sz)));
