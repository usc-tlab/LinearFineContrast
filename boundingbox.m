function bx = boundingbox(im,bg)
% x = imfeature(double(im~=bg),'BoundingBox');
% y = x.BoundingBox;
% bx = [ceil(y(1)) ceil(y(2))];
% bx = [bx bx+[y(3) y(4)]-1];

z = double(im~=bg);
x = find(sum(z));
y = find(sum(z,2));
bx = [x(1) y(1) x(end) y(end)];