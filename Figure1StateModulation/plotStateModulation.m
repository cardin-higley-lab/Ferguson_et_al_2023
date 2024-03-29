function plotStateModulation(varargin)

% PLOTSTATEMODULATION Plots distribution plots and box plots for state modulation data in Figure 1 of Ferguson et al. 2023.
%
% Loads and plots the state modulation index data for two cell populations, SST and PN.  For each population, it loads the 
% experiment information and state data (MI struct), sets experiment-specific figure properties, creates histograms 
% and box/whisker plots for the modulation index data, and performs a linear mixed-effects analysis on the data.
%
% Usage:
%   plotStateModulation(cfg) or plotStateModulation()
%
% Input: 
%   - cfg (optional): a struct that contains a path to your main Ferguson_et_al_2023
%   directory in cfg.dir.baseDir.  If not given, will set cfg.dir.baseDir to current
%   directory, which assumes you're in the main Ferguson_et_al_2023 folder.
%
% Outputs:
%   - Generates figures with histograms and box/whisker plots for each cell population's state modulation index data.
%   - Stores the linear mixed-effects model results in 'lme' variable.
%
% Dependencies:
%   - Requires data files 'VIP-SST_MI.mat' and 'VIP-PN_MI.mat', located in the Figure1StateModulation folder.
%
% Data structure:
%   - The loaded data files contain a struct "MI" with fields:
%       - MI.MI: vector of state modulation index data
%       - MI.expType: vector of 0 or 1s for control or caspase recording (respectively)
%       - MI.cellID: matrix containing details about the recordings
%       - MI.cellIDLabel: the label for each column of cellID
%       - MI.signif: logical vector indicating significance of modulation index
%   and a struct "infoSummary" containing additional figure configuration details

% written by Katie A. Ferguson, Yale University, 2023

% define directory paths
if nargin ~= 0 
   cfg = varargin{1}; 
else
   cfg.dir.baseDir = pwd; 
end
 cfg.dir.folder = fullfile(cfg.dir.baseDir, 'Figure1StateModulation');

% run for SST and PN cell types
popTypes =  {'SST', 'PN'}; 
nExps = length(popTypes);

% iterate through cell types and plot
for iPop = 1:nExps

    % load state modulation index data
    cfg.dir.MIFileName{iPop} = sprintf('VIP-%s_MI.mat', popTypes{iPop});
    load(fullfile(cfg.dir.folder, cfg.dir.MIFileName{iPop}));

    % set figure properties
    cfg = setFig1Properties(cfg, infoSummary); 

    f(iPop) = figure;
    set(f(iPop), 'Position', [500 250 725 700])
    
    % make histogram
    makeMIhistogram(cfg, MI, f(iPop)); 

    % make box/whisker plot
    makeMIboxplot(cfg, MI, f(iPop)); 

    % linear mixed effects model
    [lme{iPop}, tbl{iPop}] = MIlme(MI);

end
end

%%%%

function makeMIhistogram(cfg, MI, f) 
% MAKEMIHISTOGRAM makes a histogram of the modulation indices, with
% significantly modulated cells filled in

set(0,'CurrentFigure',f);

unExpType = unique(MI.expType);

% iterate through control vs caspase and plot histograms
for iExp = 1:length(unExpType)

    s(iExp) = subplot(cfg.plt.subplotSz(1), cfg.plt.subplotSz(2), cfg.plt.subplotIdx{iExp});
    hold on;

    % set some experiment specific plot details
    col = cfg.plt.colors{iExp};
    expIdx = MI.expType == unExpType(iExp);
    titleStr = cfg.plt.expTypeStr{iExp}; 

    % plot all MI as outline
    h = histogram(s(iExp), MI.MI(expIdx), ...
        cfg.plt.histrange, 'FaceColor', 'none', 'EdgeColor', col, 'FaceAlpha', 1);
    hold on;

    % plot significant MI as solid
    h2 = histogram(s(iExp), MI.MI(expIdx & MI.MIsignif) , ...
        cfg.plt.histrange, 'FaceColor', col, 'FaceAlpha', 1);

    mx = max(h.Values) + round(0.2*max(h.Values));
    ylim([0,mx])

    title(titleStr, 'fontsize', 12)

    if iExp == 1
        set(gca,'xtick',[])
        set(gca,'xticklabel',[])
    end

    xlim(cfg.plt.xlimrange)
    xlabel(cfg.plt.xlabel, 'fontsize', 12)
    ylabel(cfg.plt.ylabel, 'fontsize', 12)
    hold on;

end

suptitle(strrep(cfg.plt.fullTitle, '_', ' '));

end


function makeMIboxplot(cfg, MI, f)
% MAKEMIBOXPLOT makes box and whisker plots for the state modulation
% indices

set(0,'CurrentFigure',f);
s = subplot(cfg.plt.subplotSz(1), cfg.plt.subplotSz(2), cfg.plt.subplotIdx{end});
hold on;

% set colors
bxColor = vertcat(cfg.plt.colors{:});
bxLabel = cfg.plt.expType;  

% box plot 
plbx = makeBoxPlot(MI.MI, MI.expType, bxLabel, bxColor);

ylabel(cfg.plt.bxylabel);
ylim(cfg.plt.boxrange); 

end


function [lme, tbl] = MIlme(MI)
% MILME organizes modulation indices and recording info into a table and
% performs linear mixed effect analysis
%
% Outputs:
%   'lme': linear mixed effect analysis output
%   'tbl': table containing the data for analysis


[~, ~, unMouse] = unique(MI.cellID(:, strcmp(MI.cellIDLabel, 'Mouse')));
[~, ~, unFoV] = unique(MI.cellID(:, strcmp(MI.cellIDLabel, 'FoV')));
[~, ~, unExp] = unique(MI.cellID(:, strcmp(MI.cellIDLabel, 'ExpType')));


tbl = table(MI.MI, unMouse, ...
    unFoV, unExp,...
    'VariableNames',{'ModInd','Mouse','FoV','Exp'});

tbl.Mouse = categorical(tbl.Mouse);
tbl.FoV = categorical(tbl.FoV);
tbl.Exp = categorical(tbl.Exp);

lme = fitlme(tbl, 'ModInd ~ Exp + (1 | Mouse:FoV)');

end