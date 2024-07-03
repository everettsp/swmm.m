kill
x = 1:5;
y = randn(5, 3, 100);

% Plot boxplots

figure
h = boxplot2(y,x,'GroupColors',[0.2,1,1; 1,.2,.2; 1,0,1; 0.5,.2,1; .7,.2,.4]);

figure
h = boxplot2(y,x,'MemberColors',[0.2,1,1; 1,.2,.2; 1,0,1; 0.5,.2,1; .7,.2,.4]);