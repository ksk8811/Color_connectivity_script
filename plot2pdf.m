%%% simple function that save current figure as a pdf preserving size and margins
%%% Benjamin Garcia, 2016

%%% Example:
%%% plot ([1 2 3 4])
%%% plot2pdf('testplot')
%%% a pdf file named testplot.pdf should appear in the current path

function plot2pdf(NAME)
fig = gcf;
fig.Units=fig.PaperUnits;
fig.PaperSize= [fig.Position(3) fig.Position(4)];
print(fig, NAME, '-dpdf' );
end
