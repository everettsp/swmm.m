kill
x = 5:9;
y = randn(5, 3, 100);

% Plot boxplots

figure
h = plot_bp(y,'GroupColors',[0.2,1,1; 1,.2,.2; 1,0,1; 0.5,.2,1; .7,.2,.4]);

figure
h = plot_bp(x,y,'MemberColors',[0.2,1,1; 1,.2,.2; 1,0,1; 0.5,.2,1; .7,.2,.4]);