function curr_se = plot_shadedaverage(input,time_pts,color,lineprop);

toPlot = nanmean(input);
input_nan = sum(~isnan(input));
toPlot_err = nanstd(input)./sqrt(input_nan);

curr_se = shadedErrorBar(time_pts, toPlot,toPlot_err,'k',1,1,-0.1); hold on
curr_se.mainLine.Color = color;
curr_se.mainLine.LineStyle = lineprop;
curr_se.patch.FaceColor = color;
curr_se.edge(1).LineStyle = 'none';
curr_se.edge(2).LineStyle = 'none';
curr_se.patch.FaceAlpha = 0.3; shg

set(gca,'TickDir','out','TickLength',[0.04 0]);

end