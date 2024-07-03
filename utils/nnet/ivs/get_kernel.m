function Kh = get_kernel(X,sf)
    %default scaling factor
    if nargin < 3
    sf = 1.0;
    end

    sigma = cov(X);
    [n,d] = size(X);

    hr = (4 / (d + 2)) ^ (1 / (d + 4)) * n ^ (-1 / (d + 4)); %gaussian reference bandwidth
    h = sf * hr; %kernel bandwidth

    Kh = zeros(n,n);
    for rp = 1:n %for regression point X = x
        x = X(rp,:); %set regression point
        for i = 1:n %for i in i=1:n
            xi = X(i,:);
            xmxi = (x - xi)';
            
            Kh(rp,i) = (1/ ((h*sqrt(2*pi))^d * sqrt(det(sigma))) ) * ...
                exp( - (xmxi' * inv(sigma) * xmxi)/(2 * h^2) ); %calculate the kernel density function
        end
    end
end