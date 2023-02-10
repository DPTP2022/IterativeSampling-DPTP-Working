% dh_config



set(0,'DefaultAxesFontSize',12)
set(0,'DefaultAxesFontWeight','bold')
set(0,'DefaultLineLineWidth',1.5)
set(0,'DefaultAxesOuterPosition',[-0.046,0.005,1.108,1.010])
set(0,'DefaultLegendBox','off')
set(0,'DefaultFigureColor',[1 1 1])
set(0,'DefaultAxesXColor',[0 0 0])
set(0,'DefaultAxesYColor',[0 0 0])
set(0,'DefaultAxesZColor',[0 0 0])

%%
ColourBank=[
        1.0000    0.1000    0.1000
    0.1000    0.1000    1.0000
    0.1000    1.0000    0.1000
    1.0000    1.0000    0.1000
         0    1.0000    1.0000
    1.0000    0.5000         0
    0.5000    1.0000    0.5000
    1.0000    0.5000    0.4000
    0.5000    0.5000    0.5000
    0.4000    0.7000    0.9000
    1.0000    0.8000    0.8000
    0.6000    0.2000    0.3000
    0.1000    0.4000    0.8000
    0.7000         0    0.6000
    0.3000    0.3000    0.2000
    0.4000    0.4000         0
         0         0         0
    0.5000    0.5000    1.0000
    0.7000    0.7000    0.3000
         0         0    0.5000
    0.2000    0.6000         0
    0.2000         0    0.6000
    0.8000    0.7000    0.5000
    1.0000         0    0.4000
    0.2000    0.2000         0
    0.1000    0.6000    0.1000
         0    0.2000    0.4000
    0.2000    1.0000    0.8000
    0.3000    0.8000    1.0000
    0.1000    0.3000    1.0000
    0.8000    0.8000         0
    0.4000    0.4000    0.4000
    0.6000    0.6000    0.6000
    0.7000    0.7000    0.7000
    0.7000    0.4000    0.7000
    1.0000    1.0000    0.5000];
rng(13)
ColourBank=ColourBank(randperm(size(ColourBank,1)),:);
rng('shuffle')
set(0,'DefaultAxesColorOrder',ColourBank)
set(0,'DefaultPolaraxesColorOrder',ColourBank)