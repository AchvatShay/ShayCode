folderLocation ='E:\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\';

listExp = {
    '5.9OnlyLocationChange_1000ms_60_0.7_scaTuft_0.6_NoBackL_1',...
    '5.9OnlyLocationChange_1000ms_60_0.7_scaTuft_0.6_NoBackL_2',...
    '5.9OnlyLocationChange_1000ms_60_0.7_scaTuft_0.6_NoBackL_3',...
    '5.9OnlyLocationChange_1000ms_60_0.7_scaTuft_0.6_NoBackL_4'
    };

exp_count = 500;

k = 0;
outputPath = 'E:\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\5.9OnlyLocationChange_1000ms_60_0.7_scaTuft_0.6_NoBackL_all';
mkdir(outputPath);
for i = 1:length(listExp)     
    for in = 0:exp_count-1
        copyfile(fullfile(folderLocation, sprintf('%s\\matlab_SimulationResults_%05d.mat', listExp{i}, in)),fullfile(outputPath, sprintf('matlab_SimulationResults_%05d.mat', k)));
        k = k+1;
    end
end

% 
% k = 1;
% outputPath = 'E:\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3_sm\Cai_1508\15.8Control_1000ms_50log20syn_scaTuft_0.4_100Back_sub_SR50';
% mkdir(outputPath);
% for i = 1:length(listExp)     
%     for in = 1:exp_count
%         copyfile(fullfile(folderLocation, sprintf('%s\\TPA_SimulationResults_%05d.mat', listExp{i}, in)),fullfile(outputPath, sprintf('TPA_SimulationResults_%05d.mat', k)));
%         k = k+1;
%     end
% end