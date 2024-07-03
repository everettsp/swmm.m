function fh = plot_example()
kill %close all figures, not my script - super useful


n = 100;
x = linspace(0,6*pi,n)';

fn1 = @(x) sin(x);
fn2 = @(x) cos(x)+rand;

fh = figure;
fh.Name = 'sin wave transofmrations';
colrs = colors('lassonde');
colmat = [colrs.red;colrs.blue];
for ii = 1:4

    subplot(2,2,ii)
    for iii = 1:2
        y = nan(n,4);
        descriptions = {'Random Dampening','High Freq','Positive Trend','Exp Decay'};

        if iii == 1
            fn = fn1;
        elseif iii == 2
            fn = fn2;
        end
        
        y(:,1) = fn(x)*rand;
        y(:,2) = fn(x/0.5);
        y(:,3) = fn(x) + x/10;
        y(:,4) = exp(1+fn(x)./(x+2));
        
        plot(x(:,1),y(:,ii),'-','Color',colmat(iii,:),'LineWidth',2)
        ylabel('almplitude')
        xlabel('hz')
        hold on
        
    end
    
    title(descriptions{ii})
end
end

