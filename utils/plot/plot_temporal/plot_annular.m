function plot_annular(times,bs,varargin)


% sp.Title.String = ['(',alphabet(i2),')'];
% sp.Title.HorizontalAlignment = 'left';
% sp.Title.Position(1) = 0;

rho = datetime2rho(times);
[h,be] = histcounts(rho,linspace(0,2*pi,bs)); %bimonthly bins

be2 = reshape([be;be],[1,numel(be)*2]);
be2 = be2(2:(end-1));
h2 = reshape([h;h],[1,numel(h)*2]);
polarplot([be2,be2(1)],[h2,h2(1)],varargin{:});
% rlim([min(tt.Variables),max(tt.Variables)])
ah = gca;
ah.ThetaTickLabel = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
ah.ThetaDir = 'clockwise';
ah.ThetaZeroLocation = 'top';
ah.RAxis.Label.String = ''; %count