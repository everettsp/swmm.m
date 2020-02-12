function [xd,yd] = getPolyDist(x2,y2,x3,y3)

%     y2 = [3 3 4 20 62 85 100 120 123 145];
%     y3 = [5 14 66 63 67 70 90 100];
%     x2 = 1:numel(y2); 
%     x3 = 1:numel(y3);
    if numel(x2) == 1 || numel(x3) == 1
            xd = x2 - x3;
            yd = y2 - y3;
            if numel(x2) == 1 && numel(x3) == 1
                disp('both polyline only have one elemend, calculating distance between points')
            else
                disp('one polyline only has one elemend, calculating distance between polyline and point')
            end
    else
        nv = 1+lcm(numel(x2)-1,numel(x3)-1); %number of vertices
        x2v = linspace(x2(1),x2(end),nv); %both x2 and x3 are given the same number of vertices, nv
        x2i = linspace(1,numel(x2v),numel(x2)); %indexes of original x2 points within x2v linespace
        y2v = interp1(x2(1):x2(end),y2,x2v); %interpolate values at key points

        x3v = linspace(x3(1),x3(end),nv);
        x3i = linspace(1,numel(x3v),numel(x3));
        y3v = interp1(x3(1):x3(end),y3,x3v);

%         figure(501)
%         cols = parula(5);
%         lw = 2;
%         plot(x2,y2,'o','Color',cols(1,:),'LineWidth',lw,'DisplayName','poly A')
%         hold on
%         plot(x2v,y2v,'.-','Color',cols(1,:),'LineWidth',lw,'DisplayName','interp. vert. A')
%         plot(x3,y3,'o','Color',cols(2,:),'LineWidth',lw,'DisplayName','poly B')
%         plot(x3v,y3v,'.-','Color',cols(2,:),'LineWidth',lw,'DisplayName','interp. vert. B')
% 
%         ph = plot([x2v;x3v],[y2v;y3v],':','Color','black'); hold on
%         for jj = 1:numel(ph); ph(jj).Annotation.LegendInformation.IconDisplayStyle = 'off'; end; clear vars jj ph %REMOVE LEGEND ENTRIES
% 
%         ph = plot([x2v(x2i);x3v(x2i)],[y2v(x2i);y3v(x2i)],'--','Color',cols(1,:)); hold on
%         for jj = 1:numel(ph); ph(jj).Annotation.LegendInformation.IconDisplayStyle = 'off'; end; clear vars jj ph %REMOVE LEGEND ENTRIES
% 
%         ph = plot([x2v(x3i);x3v(x3i)],[y2v(x3i);y3v(x3i)],'--','Color',cols(2,:)); hold on
%         for jj = 1:numel(ph); ph(jj).Annotation.LegendInformation.IconDisplayStyle = 'off'; end; clear vars jj ph %REMOVE LEGEND ENTRIES
% 
%         legend()

        xd = x2v - x3v;
        yd = y2v - y3v;
    end
end

