function input_distr = get_normaldistr(input_samples,input_mu,input_sigma,input_range)
% input_mu = 5;
% input_sigma = 10;
% input_samples = 100;
% input_range = [0 100];

input_distr = NaN(input_samples,1);
for i1 = 1:input_samples
    input_distr(i1) = normrnd(input_mu,input_sigma);
    
    input_min = input_range(1);
    input_max = input_range(2);
    
    % reflect probability density function against the limits
    if input_distr(i1) > input_max
        
        input_distr(i1) = input_max - (input_distr(i1) - input_max);
        
    elseif input_distr(i1) < input_min
        
        input_distr(i1) =  input_min + abs(input_distr(i1) - input_min);
        
    end
    
end


% input_distr = round(input_distr);
clear i1

end