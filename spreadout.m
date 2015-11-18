function imout = spreadout(im,a,bg)
% function imout = spreadout(im,a,bg)
% Spread out im by a factor of a, which must be an integer

if ~exist('bg','var')
   bg = 0;
end

imout = ones(size(im)*a)*bg;
imout(1:a:end,1:a:end) = im;
