function delete_corrupt(filenames)

for i2 = 1:numel(filenames)
 

try
    lastwarn('')
    matfile(filenames{i2});
    [~,warningID] = lastwarn;
    if strcmp(warningID, 'MATLAB:whos:UnableToRead')
        delete(filenames{i2})
    end
catch
    delete(filenames{i2})
end

end
end
