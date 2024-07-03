function [nnc,nnd,nnp,pr] = unpack_results(dir,dataset)
path_root = 'C:\Users\everett\Google Drive\MASc York University\0_research\flow_forecasting\';
path_results = [path_root 'results\'];

data = load([path_results dir '\results' '.mat']);
results = load([path_results dir '\performance_' dataset '-dataset' '.mat']);

nnc = data.nnc;
nnd = data.nnd;
nnp = results.nnp;
pr = results.pr;
end