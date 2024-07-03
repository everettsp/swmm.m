function [obj] = check_second_axes(obj,varargin)

obj.y2ax = nan(obj.nahs,2);
obj.x2ax = nan(2,obj.nahs);

for i2 = 1:numel(obj.ahs)
    x = [];
    
    if numel(obj.ahs(i2).YAxis) == 1
        ind = double(ismember({'left','right'},obj.ahs(i2).YAxisLocation));
        ind(ind==0) = nan;
        obj.y2ax(i2,:) = ind;
    else
    
    for i4 = 1:numel(obj.ahs(i2).YAxis)
        x = [x,obj.ahs(i2).YAxis(i4).Label.Position(1)];
    end
    [~,ind] = sort(x,'ascend');
    obj.y2ax(i2,:) = ind;
    end
    
    if numel(obj.ahs(i2).XAxis) == 1
        ind = double(ismember({'top','bottom'},obj.ahs(i2).XAxisLocation));
        ind(ind==0) = nan;
        obj.x2ax(:,i2) = ind;
    else
    x = [];
    for i4 = 1:numel(obj.ahs(i2).XAxis)
        x = [x,obj.ahs(i2).XAxis(i4).Label.Position(2)];
    end
    [~,ind] = sort(x,'ascend');
    obj.x2ax(:,i2) = ind';
    end
    
end


end