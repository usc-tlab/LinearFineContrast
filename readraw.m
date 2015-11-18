function y = readraw(name, siz)
%function y = readraw(name, siz)
%Read raw images (raster files of uint8)

f = fopen(name, 'r');
b = fread(f,siz,'uint8');
y = double(b);
fclose(f);
