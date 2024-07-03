function plot_annularhist(times,bs,varargin)


% sp.Title.String = ['(',alphabet(i2),')'];
% sp.Title.HorizontalAlignment = 'left';
% sp.Title.Position(1) = 0;

rho = datetime2rho(times);

polarhistogram(rho,bs,varargin{:})
% rlim([min(tt.Variables),max(tt.Variables)])
ah = gca;
ah.ThetaTickLabel = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
ah.ThetaDir = 'clockwise';
ah.ThetaZeroLocation = 'top';
ah.RAxis.Label.String = ''; %count