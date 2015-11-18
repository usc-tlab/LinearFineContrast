% script: readstims

% read in the images, and convert them to contrast units (bg=0, max=1)
sumall = zeros(expr.imsize);
for i = 1:length(expr.imagefile)
   imfile = expr.imagefile{i};
   im = readraw(imfile,expr.imsize)';
   target{i} = double(im==255);
   sumall = sumall+target{i};
end

% find a common bounding box across all inputs
bx = boundingbox(sumall,0);

% clop the input to the common bounding box
for  i = 1:length(target)
   x = target{i};
   target{i} = x(bx(2):bx(4),bx(1):bx(3));
end
