function datesNum = convert_german_dates(datesStr)
    % Define German and English month names
    germanMonths = {'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'};
    englishMonths = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

    % Replace German months with English
    for i = 1:length(datesStr)
        for m = 1:length(germanMonths)
            datesStr{i} = strrep(datesStr{i}, germanMonths{m}, englishMonths{m});
        end
    end

    % Convert to numeric dates
    datesNum = datenum(datesStr, 'dd-mmm-yyyy HH:MM:SS');
end
