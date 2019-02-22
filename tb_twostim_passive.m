%% Analyze passive two-stim data
% New beginnings
clear all; close all
%% Specify parameters

[f_file f_folder] = uigetfile('.txt','Select the fluorescence TXT file');
[b_file b_folder] = uigetfile('.mat','Select the protocol file');

options.f_folder_name = f_folder; %folder name for flourescence files
options.b_file_name = [b_folder '\' b_file]; %full behavior filename, including folder
options.neuropil = 0; %set to 1 if ROIs include neuropil (cells are odd ROIs, corresponding neuropil even ROI)
options.neuropil_subt = 0; %set true if want to subtract neuropil from cell flourescence
options.dt = [-1 5]; %time window for chunking trials [pre_stim_time post_stim_time]

%% verify that protocol is dual stim and get trials

load([b_folder '\' b_file]);
if ~data.params.simultaneous
    disp('Protocol is not dual stim, aborting ...')
    return
elseif exist('trials.mat');
    load('trials.mat');
else
    [trials_dff trials_z_dff] = getTrials_tb(options); 
    save('trials.mat','trials_dff','trials_z_dff');
end

%% Get trial identity

trials_ix = 1:size(trials_dff{1},1);
ncells = size(trials_dff,2);
loc = data.stimuli.loc(trials_ix)'; %1 is right stim, 2 is left stim
con = data.stimuli.contrast(trials_ix)'; % target stim contrast
opp_con = data.stimuli.opp_contrast(trials_ix)';

dum = zeros(numel(trials_ix),2);
dum(loc == 2,1) = con(loc == 2);
dum(loc == 1,2) = con(loc == 1);
dum(loc == 2,2) = opp_con(loc == 2);
dum(loc == 1,1) = opp_con(loc == 1);

comb_con = dum(:,1) - dum(:,2); %Right - left stimulus luminance
all_comb_con = unique(comb_con);

for i = 1:ncells
    for ii = 1:numel(all_comb_con)
        ix = comb_con == all_comb_con(ii);
        trials{i}{ii} = trials_z_dff{i}(ix,:);
        n_per_comb_con(ii) = sum(ix);
        pre = mean(trials_z_dff{i}(ix,1:10),2);
        post1 = mean(trials_z_dff{i}(ix,11:20),2);
        post2 = mean(trials_z_dff{i}(ix,21:30),2);
        sig(i,ii,1) = signrank(pre,post1);
        sig(i,ii,2) = signrank(pre,post2);
    end
end

sig_cells = sum(sig < 0.05,2) > 0;

%% Plot dirty

time_pts = -0.8:0.1:5.2;
% time_pts = -0.8:0.2:5.2;


for i = 1:ncells
    figure(i);
    for ii = 1:numel(all_comb_con)
        subplot(4,3,ii);
        plot_shadedaverage(trials{i}{ii},time_pts,'k','-');
        title(num2str(all_comb_con(ii)));
        ylim([-0.5 1]);
        xlim([-1 5]);
    end
end
        
    
  
