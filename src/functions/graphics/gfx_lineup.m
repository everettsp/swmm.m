% function gfx_lineup(fh1,fh2)


for i2 = 1:numel(fh1.Children)
    fh1.Children(i2).Units = 'centimeters';
end

for i2 = 1:numel(fh2.Children)
    fh2.Children(i2).Units = 'centimeters';
end

for i2 = 2:2:6
fh1.Children(i2).Position([1,3]) = fh2.Children(2).Position([1,3]);
end

for i2 = 1:2:5
   fh1.Children(i2).Position([1,3]) = fh2.Children(1).Position([1,3]);
end 