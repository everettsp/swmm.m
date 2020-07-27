% function hitbl = get_hydrotbl(f)
%%
hid = table();
descr = {'no event';'start';'rising';'peak';'falling';'valley';'end'};
sym = {'.';'<';'o-';'^';'o-';'v';'>'};
class = [-999;4;1;2;-1;-2;-4];

cols = cell2mat(f.Col);
lw = f.lw1;
ms = f.ms;


col = [[0 0 0];cols(2,:);cols(4,:);cols(5,:);brighten(cols(4,:));cols(5,:);cols(2,:)];

size = [ms;ms;ms;ms*2;ms;ms*2;ms];
linewidth = [lw;lw;lw;lw;lw;lw;lw];

hitbl = table(descr,sym,col,size,linewidth,'RowNames',class);
hitbl('rising (obs.)',:) = hitbl('rising',:);
hitbl('rising (pred.)',:) = hitbl('rising',:);
hitbl('rising (pred.)','col') = table(cols(3,:));


hitbl('falling (obs.)',:) = hitbl('falling',:);
hitbl('falling (pred.)',:) = hitbl('falling',:);
hitbl('falling (pred.)','col') = table(brighten(cols(3,:)));

function col_brighter = brighten(col)
    col_brighter = col * 2;
    col_brighter(col > 1) = 1;
end


% end