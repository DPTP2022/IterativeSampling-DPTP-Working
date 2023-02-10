function [scores,xGrid] = PredictScoresOverGrid(svm,d)
if nargin==1
    d=0.02;
end
x=1:30;
y=1:21; y_val=[0.01 0.025:0.025:0.5];
[xx,yy]=meshgrid(x,y);
xyd=[linvc(xx),linvc(yy),zeros(length(linvc(yy)),1)];



[x1Grid,x2Grid] = meshgrid(min(xyd(:,1)):d:max(xyd(:,1)),min(xyd(:,2)):d:max(xyd(:,2)));
xGrid = [x1Grid(:),x2Grid(:)]; [~,scores] = predict(svm,xGrid);


xGrid = {x1Grid,x2Grid};
end