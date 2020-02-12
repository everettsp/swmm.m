function char_size = get_charwidth(units)
%gets the width of axes label, not a good function...
        ah = gca;
        units_old = ah.YLabel.Units;
        ah.YLabel.Units = units;
        ylabel_extent = get(ah.YLabel,'Extent');
        char_size = ylabel_extent(4)/length(ah.YLabel.String);
        ah.YLabel.Units = units_old;
end