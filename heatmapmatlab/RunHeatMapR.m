clear all; close all;
load('mastermask.mat')
filename = 'AEQBodydata.csv';
templatedata = readtable(filename)

plotdimx = round(size(templatedata,1)/2)

figure
for i = 1:size(templatedata,1)
    subplot(2, plotdimx, i);
    Bodymap = GenerateHeatMapTouchTestBody(templatedata(i,:), mask);
    title(sprintf('Cluster %d', i))
end
%generate subplot
set(gcf,'units','normalized','outerposition',[0 0 1 1])
saveas(gcf,sprintf('C:/Users/Administrator/OneDrive - Goldsmiths College/Studies/AEQ/Heatmap/heatmapmatlab/clusteroutput/%d-Cluster-BodyMap.png',size(templatedata,1)))