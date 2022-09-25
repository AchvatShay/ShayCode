folderLocation ='E:\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\';
% folderLocation = 'E:\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3_sm\';

listExp = {'4.8Bias1_100ms_log80_20_scaTuft_0.4_100Back', '4.8Bias0_100ms_log80_20_scaTuft_0.4_100Back'};

% listExp = {'13.7_Control_100ms_60_30', '13.7_Control_100ms_50_20', '13.7_Control_100ms_30_10', '13.7_Control_100ms_20_15', '13.7_Control_100ms_20_20_1', '13.7_Control_100ms_20_20_2', '13.7_Control_100ms_20_20_3'};

% listExp = {'29.7Control_100ms_80log20syn_scaTuft_0.4_100Back_1', '29.7Control_100ms_80log20syn_scaTuft_0.4_100Back_2', ...
%     '29.7Control_100ms_80log20syn_scaTuft_0.4_100Back_3','29.7Control_100ms_80log20syn_scaTuft_0.4_100Back_4',...
%     '29.7Control_100ms_80log20syn_scaTuft_0.4_100Back_5','29.7Control_100ms_80log20syn_scaTuft_0.4_100Back_6',...
%     '29.7Control_100ms_80log20syn_scaTuft_0.4_100Back_7'};

% listExp = {'27.7_Control_1000ms_50log20syn_scaTuft_0.4_100Back_1', '27.7_Control_1000ms_50log20syn_scaTuft_0.4_100Back_2', ...
%     '27.7_Control_1000ms_50log20syn_scaTuft_0.4_100Back_3', '27.7_Control_1000ms_50log20syn_scaTuft_0.4_100Back_4', ...
%     '27.7_Control_1000ms_50log20syn_scaTuft_0.4_100Back_5', '27.7_Control_1000ms_50log20syn_scaTuft_0.4_100Back_6'};

% listExp = {'8.7_Control_60_30','8.7_Control_50_20',...
%     '8.7_Control_new_30_10', '8.7_Control_new_20_15', ...
%     '8.7_Control_new_20_20_1', '8.7_Control_new_20_20_2',...
%     '8.7_Control_new2_20_20_3'};

% listExp = {'13.5Control60_30', '11.5_ControlRun_log50_20', '21.4_ControlDepth1_30_10', '21.4_ControlDepth1_20_15', ...
%     '18.4_ControlDepth1', '18.4_ControlDepth1_Other', '13.4.21_control_DepthTo1'};

% listExp = {'11.7_Control_80_20', '11.7_Control_70_20', '8.7_Control_60_30', '8.7_Control_50_20', '8.7_Control_30_10', '8.7_Control_new_20_20_2', '8.7_Control_new_20_20_1'};

% listExp = {'11.7_Control_50_20', '11.7_Control_60_20', '11.7_Control_70_20', '11.7_Control_80_20'};

% listExp = {'4.7_NOVGCC_Tuft_By_13.5Control60_30', '4.7_NOVGCC_Tuft_By_11.5_ControlRun_log50_20', ...
%     '4.7_NOVGCC_Tuft_By_21.4_ControlDepth1_30_10', '4.7_NOVGCC_Tuft_By_21.4_ControlDepth1_20_15', ...
%     '4.7_NOVGCC_Tuft_By_18.4_ControlDepth1','4.7_NOVGCC_Tuft_By_18.4_ControlDepth1_Other', ...
%     '4.7_NOVGCC_Tuft_By_13.4.21_control_DepthTo1'};

% listExp = {'17.6GNMDATestControl_60_30', '17.6GNMDATestControl_50_20',...
%     '17.6GNMDATestControl_30_10', '17.6GNMDATestControl_20_15', ...
%     '17.6GNMDATestControl_20_20_18.4_ControlDepth1', '17.6GNMDATestControl_20_20_18.4_ControlDepth1_Other',...
%     '17.6GNMDATestControl_20_20_13.4'};

% listExp = {'17.6Syn50_0.7_GNMDATest3', '17.6Syn50_0.7_GNMDATest2', '12.6Syn50Size0.7'};

% listExp = {'24.6_AmpaOnlyByControl_60_30', '24.6_AmpaOnlyByControl_50_20','24.6_AmpaOnlyByControl_30_10',...
%     '24.6_AmpaOnlyByControl_20_15', '24.6_AmpaOnlyByControl_18.4_ControlDepth1', '24.6_AmpaOnlyByControl_18.4_ControlDepth1_Other'...
%     '24.6_AmpaOnlyByControl_13.4.21_control_DepthTo1'};

% listExp = {'22.6_Control_60_30', '22.6_Control_50_20', '22.6_Control_30_10',...
%         '22.6_Control_20_15','22.6_Control_20_20_1','22.6_Control_20_20_2', '22.6_Control_20_20_3'};

% listExp = {'4.7_NOVGCC_HZ_By_2.7_Control_new_60_30', '4.7_NOVGCC_HZ_By_2.7_Control_new_50_20', '4.7_NOVGCC_HZ_By_2.7_Control_new_30_10',...
%     '4.7_NOVGCC_HZ_By_2.7_Control_new_20_15', '4.7_NOVGCC_HZ_By_2.7_Control_new_20_20_1', ...
%     '4.7_NOVGCC_HZ_By_2.7_Control_new_20_20_2', '4.7_NOVGCC_HZ_By_2.7_Control_new_20_20_3'};

% listExp = {'2.7_Control_new_60_30', '2.7_Control_new_50_20', '2.7_Control_new_30_10', '2.7_Control_new_20_15', ...
%     '2.7_Control_new_20_20_1', '2.7_Control_new_20_20_2', '2.7_Control_new_20_20_3'};

% listExp = {'27.6_NoVGCCHZ_ByControl_22.6_Control_60_30', '27.6_NoVGCCHZ_ByControl_22.6_Control_50_20', '27.6_NoVGCCHZ_ByControl_18.6_Control_30_10',...
%     '27.6_NoVGCCHZ_ByControl_18.6_Control_20_15', '27.6_NoVGCCHZ_ByControl_18.6_Control_20_20_1', '27.6_NoVGCCHZ_ByControl_18.6_Control_20_20_2',...
%     '27.6_NoVGCCHZ_ByControl_18.6_Control_20_20_3'};

% listExp = {'22.6_Control_60_30', '22.6_Control_50_20',...
%     '18.6_Control_30_10', '18.6_Control_20_15', ...
%     '18.6_Control_20_20_3', '18.6_Control_20_20_1',...
%     '18.6_Control_20_20_2'};

% listExp = {'3.6NOVGCC_HZ_logN60_30_13.5Control60_30', '3.6NOVGCC_HZ_logN50_20', '6.6NOVGCC_HZ_ByControl_21.4_ControlDepth1_30_10',...
%     '6.6NOVGCC_HZ_ByControl_21.4_ControlDepth1_20_15', ...
%     '3.6NOVGCC_HZ_logN20_20_18.4_ControlDepth1', '6.6NOVGCC_HZ_ByControl_18.4_ControlDepth1_Other',...
%     '3.6NOVGCC_HZ_logN20_20'};

% listExp = {'20.5Control_log20_20', '20.5Control_log40_20', '20.5Control_log50_20', ...
%     '20.5Control_log60_20'};

% listExp = {'11.5_ControlRun_log50_20', '21.4_ControlDepth1_30_10', '21.4_ControlDepth1_20_15', ...
%     '18.4_ControlDepth1', '18.4_ControlDepth1_Other', '13.4.21_control_DepthTo1'};

% listExp = {'13.5Control60_30', '11.5_ControlRun_log50_20', '11.5_ControlRun_log20_20'};

k = 1;
outputPath = 'E:\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\7.8Comb_Bias1_0_80_20log_100ms';
mkdir(outputPath);
for i = 1:length(listExp)        
    for in = 1:1000
        copyfile(fullfile(folderLocation, sprintf('%s\\matlab_SimulationResults_%03d.mat', listExp{i}, in-1)),fullfile(outputPath, sprintf('matlab_SimulationResults_%05d.mat', k-1)));
        k = k+1;
    end
end

% k = 1;
% outputPath = 'E:\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\29.7Comb_Control_80_20log_100ms_Test';
% mkdir(outputPath);
% for i = 1:length(listExp)
%     listFiles = dir(fullfile(folderLocation, sprintf('%s\\matlab_SimulationResults_*.mat', listExp{i})));
%     for j = 1:length(listFiles)
%         copyfile(fullfile(listFiles(j).folder, listFiles(j).name),fullfile(outputPath, sprintf('matlab_SimulationResults_%05d.mat', k-1)));
%         k = k+1;
%     end
% end

% for i = 1:length(listExp)
%     listFiles = dir(fullfile(folderLocation, sprintf('%s_SR50\\TPA*.mat', listExp{i})));
%     for j = 1:length(listFiles)
%         copyfile(fullfile(listFiles(j).folder, listFiles(j).name),fullfile(outputPath, sprintf('TPA_%05d.mat', k-1)));
%         k = k+1;
%     end
% end