function plotGrabAndSave(output,experimentName, grabNum, data, is_norm, by_SF)

% Create figure
figure1 = figure('Renderer', 'painters', 'Position', [248 248 1353 514]);

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

xlim(axes1,[data{1, 1} data{end, 1}]);

if is_norm
    ylim(axes1,[300 500]);
else
    ylim(axes1,[500 700]);
end

pelletIndex = find(strcmp(data(:, 5), 'Ok'));

for i = 1:size(pelletIndex,1)
    X1 = data{pelletIndex(i), 4};
    Y1 = data{pelletIndex(i), 1};
    scatter(Y1,X1,46,X1,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],...
        'Marker','>', 'HandleVisibility','off');
end

for i = 1:size(pelletIndex,1)
    Y1 = data{pelletIndex(i), 1}; 
    line([Y1 Y1], get(gca, 'YLim'), 'Color','k','LineWidth',2, 'LineStyle', ':', 'HandleVisibility','off');
end

nanIndexCheck = cellfun(@isnan,data(:,3),'uni',false);
nanIndexCheck=cellfun(@any,nanIndexCheck);
data(nanIndexCheck, :) = [];

arrayPos = cell2mat(data(:, 3));
arrayTrails = cell2mat(data(:, 1));

% calc avarage for trails
avgIndex = find([data{:,6}] == 1);
meanCalcValue = mean(arrayPos(avgIndex));
stdValue = std(arrayPos(avgIndex));

line(get(gca, 'XLim'),[meanCalcValue meanCalcValue], 'Color','k','LineWidth',2, 'LineStyle', '--', 'HandleVisibility','off');
% line(get(gca, 'XLim'), [(meanCalcValue + stdValue*4) (meanCalcValue + stdValue*4)], 'Color','k','LineWidth',2, 'LineStyle', '--', 'HandleVisibility','off');

if (by_SF)
    % success
    sucIndex = strcmp(data(:, 2), 'S');

    % fails
    failIndex = strcmp(data(:, 2), 'F');

    scatter(arrayTrails(sucIndex), arrayPos(sucIndex),'DisplayName','Success', 'MarkerFaceColor', [0 0 1]);    
    scatter(arrayTrails(failIndex), arrayPos(failIndex), 'DisplayName','failure', 'MarkerFaceColor', [1 0 0]);
    
    % Create legend
    legend(axes1, 'show');
else
    scatter(arrayTrails(:), arrayPos(:),'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'HandleVisibility','off');    
end

% Create ylabel
ylabel({'Hand Position'});

% Create xlabel
xlabel('Trails #');

% Create title
figName = strcat(experimentName, ' grab try number : ',grabNum);
title(figName);

% save fig
experimentName = strrep(experimentName,' ','_');
experimentName = strrep(experimentName,'/','-');
experimentName = strrep(experimentName,'\','-');
savefig(figure1, strcat(output, '\', experimentName, '_grab_', grabNum));
saveas(figure1, strcat(output, '\', experimentName, '_grab_', grabNum, '.tif'));

end