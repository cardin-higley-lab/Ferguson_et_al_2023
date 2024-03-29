% RUNMAINFIGURES script generates the main Figures of Ferguson et al. 2023.
%
% Loads the data and plots the main figures of Ferguson et al., 2023, including state modulation, size tuning, and 
% behavioral data plots. 
%
% Outputs:
%   - Generates the main figures:
%       1) Histograms and box/whisker plots for the SST and PN population's state modulation data.
%       2) Size tuning, surround suppression, and box/whisker plots for the SST and PN populations.
%       3) Behavioral data box/whisker plots for the optogenetic data. 
%
% Dependencies:
%   - Requires data files located in each of the respective "Figure" folders.
%

% written by Katie A. Ferguson, Yale University, 2023

%% define dirs and add to path 

% Assumes you're running from the main directory. Otherwise change cfg.dir.baseDir to hard path e.g., '~/Desktop/Ferguson_et_al_2023').  
cfg.dir.baseDir = pwd; % your path to Ferguson_et_al_2023 folder.  
p = genpath(cfg.dir.baseDir);
addpath(p); 

%% Figure 1

plotStateModulation(cfg)

%% Figure 2

plotSizeTuning(cfg)

%% Figure 3

plotBehavior(cfg)


