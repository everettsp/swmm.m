function y = alphabet(x,font_case)

if nargin < 2
    font_case = 'upper';
end

letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
y = letters(x);


switch lower(font_case)
    case 'lower'
        y = lower(y);
    case 'upper'
    otherwise
        disp("font case should be either 'upper' or 'lower'")
end
end

