function [h]= DrawDecisionBoundary(svm,scores,xyd,xGrid,title_string,inverted)
    if nargin<6 
        inverted=1; 
    end
    classes=xyd(:,3);
    
    if inverted==1
%         h(1:2) = gscatter(xyd(:,1),22-xyd(:,2),classes,'rb','.');
%         hold on
%         h(3) = plot(xyd(svm.IsSupportVector,1),22-xyd(svm.IsSupportVector,2),'ko');
        
%         h(1:2) = gscatter(xyd(:,1),22-xyd(:,2),classes,'rb','.');
        h(1)=scatter(xyd(classes==1,1),22-xyd(classes==1,2),400,'.','MarkerEdgeColor',[0.3 0.8 1]); hold on
        h(2)=scatter(xyd(classes==-1,1),22-xyd(classes==-1,2),400,'.','MarkerEdgeColor',[0.1 0.6 0.1]);

        hold on
        h(3) = plot(xyd(svm.IsSupportVector,1),22-xyd(svm.IsSupportVector,2),'ks','LineWidth',2);
        
        contour(xGrid{1},flip(xGrid{2},1),reshape(scores(:,2),size(xGrid{1})),[0 0],'k');
        y_val=[0.01 0.025:0.025:0.5];
        set(gca,'YTick',[1:2:21],'YTickLabel',num2str(flip(y_val(1:2:end))'))
    else
    %     figure('Position',[1392 348 522 601]);
        h(1:2) = gscatter(xyd(:,1),xyd(:,2),classes,'rb','.');
        hold on
        h(3) = plot(xyd(svm.IsSupportVector,1),xyd(svm.IsSupportVector,2),'ko');
        contour(xGrid{1},xGrid{2},reshape(scores(:,2),size(xGrid{1})),[0 0],'k');
    end
    
    ylim([0 22]); xlim([0 31]); 
    xlabel('Frequency \tau_{t}'); ylabel('Severity 1/n_{t}'); axis square; box on;
    set(gca,'XTick',[1 5:5:30],'XTickLabels',num2str([1 5:5:30]'))
    set(gca,'Position',[0.109534252873563,0.255497661459625,0.858699999999999,0.695278960576212])
    title(title_string);
    [LEG,icons]=legend(h,{'HVD >= \epsilon','HVD < \epsilon','Support Vectors'},'Location','SouthOutside','Orientation','Horizontal');
    icons(4).Children.MarkerSize=30; icons(5).Children.MarkerSize=30; icons(7).LineWidth=1.5; icons(7).MarkerSize=10;
    LEG.Position=[0.167624534146995,0.115862454940925,0.720306500335762,0.03910149656199];
    hold off
end