function plotAllGrabsAndSave(output, experimentName, data, is_norm, with_number, bySF)
    
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

pelletIndex = find(strcmp(data(:, 10), 'Ok'));

for i = 1:size(pelletIndex,1)
    X1 = data{pelletIndex(i), 9};
    Y1 = data{pelletIndex(i), 1};
    scatter(Y1,X1,46,X1,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],...
        'Marker','>', 'HandleVisibility','off');
end

for i = 1:size(pelletIndex,1)
    Y1 = data{pelletIndex(i), 1}; 
    line([Y1 Y1], get(gca, 'YLim'), 'Color','k','LineWidth',2, 'LineStyle', ':', 'HandleVisibility','off');
end

grabCount = 1;
ResultsMatrix = [];

for index = 6:8
    ResultsMatrix = [ResultsMatrix ; runMatrixCreationForGrab(grabCount, data, index)];
    grabCount = grabCount + 1;
end


for rIndex = 1:length(data(:,1))
    grabsForIndex = find(ResultsMatrix(:,1) == data{rIndex,1});
    ResultsMatrix(grabsForIndex(1:(end-1)), 4) = 0;
end

if (bySF)
    scatter(ResultsMatrix(ResultsMatrix(:, 4) == 1, 1), ResultsMatrix(ResultsMatrix(:, 4) == 1, 2),'DisplayName','Success', 'MarkerFaceColor',[0 0 1]);
    scatter(ResultsMatrix(ResultsMatrix(:, 4) == 0, 1), ResultsMatrix(ResultsMatrix(:, 4) == 0, 2), 'DisplayName','failure', 'MarkerFaceColor',[1 0 0]);

    % Create legend
    legend(axes1, 'show');
else
    scatter(ResultsMatrix(:, 1), ResultsMatrix(:, 2),'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor',[0 0 0], 'HandleVisibility','off');
end


if (with_number)
    text(ResultsMatrix(:, 1), ResultsMatrix(:, 2), num2str(ResultsMatrix(:, 3)), 'DisplayName','grab number','HorizontalAlignment','center',...
        'FontWeight','bold',...
        'FontSize',7,...
        'Color',[1 1 1]);
end

% Create ylabel
ylabel({'Hand Position'});

% Create xlabel
xlabel('Trails #');

% Create title
figName = strcat(experimentName, ' All Grabs ');
title(figName);

% save fig
experimentName = strrep(experimentName,' ','_');
experimentName = strrep(experimentName,'/','-');
experimentName = strrep(experimentName,'\','-');
savefig(figure1, strcat(output, '\', experimentName, '_grab_All_', num2str(with_number)));
saveas(figure1, strcat(output, '\', experimentName, '_grab_All_', num2str(with_number), '.tif'));

end