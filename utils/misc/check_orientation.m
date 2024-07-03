function fix_orientation(x,y,dim)


sx = size(x);
sy = size(y);

if sx(dim) ~= sy(dim)
    x = x';
    y = y';
end

end