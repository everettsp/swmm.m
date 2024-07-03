function cnps = ivs_cnps(nets)
%BUILDCNPSA Summary of this function goes here
%alpha is 75 in Duncan's EQR method -> higher will select fewer inputs
%%

% if nargin < 2
%     p = 95;
% end
num_ensemble = numel(nets);
for ii = 1:num_ensemble %get WIO for ensemble
    net = nets{ii};
    inW =net.IW{1,1}; lyrW=net.LW{2,1};
    wio(:,ii) = inW'*lyrW';
    
end
    q1q3 = prctile(wio',[25 75]);
    eqr = min(abs(q1q3)) ./ max(abs(q1q3)) .* sign(q1q3(1,:)) .* sign(q1q3(2,:));
    [eqr_ranked, eqr_ind] = sort(eqr, 'descend');
    
    alph = sum(wio > 0, 2) / num_ensemble;
    alph(alph < 0.5) = 1 - alph(alph < 0.5);
    
    [alph_ranked, alph_ind] = sort(alph, 'descend');
    
    top_n = sum(alph_ranked == 1);
    top_score = (min(wio(alph_ind(1:top_n),:),[],2) ./ max(wio(alph_ind(1:top_n),:),[],2));
    [~, top_ind] = sort(top_score, 'descend');
    
    alph_ind(1:top_n) = alph_ind(top_ind);
    
    cnps.score = alph;
    cnps.rank = alph_ind;
    cnps.score_ranked = alph_ranked;
    cnps.eqr_score = eqr;
    cnps.eqr_rank = eqr_ind';
    cnps.eqr_score_ranked = eqr_ranked';


end
