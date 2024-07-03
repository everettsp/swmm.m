function [nf,dnf] = make_normaliser(x)
% returns normaliser and denormaliser function handles
nf = @(z) (z - min(x))./(max(x)-min(x));
dnf = @(z) z .* (max(x)-min(x)) + min(x);
end