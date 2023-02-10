% Data grid points
x=1:30;
y=1:21; y_val=[0.01 0.025:0.025:0.5];
showplots=1; showepsilonthresholds=0; saveplots=1;
[xx,yy]=meshgrid(x,y);
try; dhconfig; end
savelocation=[cd '\'];

file_tag='NSGAII_SDP2_DR0';
% file_tag='NSGAII_JY1_DR0';
% file_tag='NSGAII_JY2_DR0';
% file_tag='MOEAD_SDP2_DR0';
% file_tag='MOEAD_JY1_DR0';
% file_tag='MOEAD_JY2_DR0';
sampledata=[file_tag '_datagrid_1.mat'];
load(sampledata);

performance_data_raw=eval([file_tag '_allmag_allfreq;']);
clearvars -except performance_data_raw xx yy sampledata y_val showplots file_tag ...
                  savelocation saveplots showepsilonthresholds
x=1:30; y=1:21;


performance_data=zeros(size(performance_data_raw));
for i=1:length(x)
    for j=1:length(y)
        performance_data(j,i)=mean(mean(performance_data_raw{j,i}(2:end,:)));
    end
end

xyd=[linvc(xx),linvc(yy),linvc(performance_data)];

EpsilonThreshold=0.075;
if contains(file_tag,'SDP2')==1; EpsilonThreshold=0.1; end
if showepsilonthresholds==1
    figure('Position',[680   458   428   520]); scatter(linvc(xx),linvc(yy),'k.') %linvc(xx) == reshape(xx,1,numel(xx))
    ylim([y(1)-1 y(end)+1]); xlim([x(1)-1 x(end)+1]); hold on; xlabel('Frequency Index'); ylabel('Severity Index'); title('dMOP2 SPEA2 example HVD perf. threshold')
    scatter(xyd((xyd(:,3)<0.1),1),xyd((xyd(:,3)<0.1),2),'g^','Linewidth',2)
    scatter(xyd((xyd(:,3)<0.075),1),xyd((xyd(:,3)<0.075),2),'ro','Linewidth',2)
    scatter(xyd((xyd(:,3)<0.05),1),xyd((xyd(:,3)<0.05),2),'bx','Linewidth',2)
    legend({'data point','epsilon = 0.1','epsilon = 0.075','epsilon = 0.05'},'Location','SouthOutside','Orientation','Horizontal','NumColumns',2); axis square;
end
classes=xyd(:,3); classes(classes<=EpsilonThreshold)=-1; classes(classes>EpsilonThreshold)=1;
xyd_classes=[xyd(:,1:2) classes];



%Train the SVM Classifier
svm = fitcsvm(xyd_classes(:,1:2),xyd_classes(:,3),'KernelFunction','rbf','ClassNames',[-1,1],'Standardize',true);

% Predict scores over the grid
d = 0.02; 
[x1Grid,x2Grid] = meshgrid(min(xyd(:,1)):d:max(xyd(:,1)),min(xyd(:,2)):d:max(xyd(:,2)));
xGrid = [x1Grid(:),x2Grid(:)]; [~,scores] = predict(svm,xGrid);
xGrid = {x1Grid,x2Grid};

if showplots==1;
    title_string_base=file_tag; title_string_base(title_string_base=='_')=' '; %title(title_string_base);
    figure('Position',[1415 394 522 601]);
    [~]=DrawDecisionBoundary(svm,scores,xyd_classes,xGrid,[title_string_base ' (\epsilon = ' num2str(EpsilonThreshold) ')']);
    
    if saveplots==1;
       print(gcf,[savelocation file_tag '_CompleteGrid.png'],'-dpng','-r1200')
       print(gcf,[savelocation file_tag '_CompleteGrid.eps'],'-depsc')
       print(gcf,[savelocation file_tag '_CompleteGrid.svg'],'-dsvg')
       savefig(gcf,[savelocation file_tag '_CompleteGrid.fig'])
    end
%     % Plot the data and the decision boundary
%     figure('Position',[680   372   522   606]);
%     h(1:2) = gscatter(xyd(:,1),xyd(:,2),classes,'rb','.');
%     hold on
%     h(3) = plot(xyd(svm.IsSupportVector,1),xyd(svm.IsSupportVector,2),'ko');
%     contour(x1Grid,x2Grid,reshape(scores(:,2),size(x1Grid)),[0 0],'k');
%     title_string=file_tag; title_string(title_string=='_')='-'; title(title_string);
%     legend(h,{'-1','+1','Support Vectors'},'Location','SouthOutside','Orientation','Horizontal');
%     ylim([y(1)-1 y(end)+1]); xlim([x(1)-1 x(end)+1]); hold on; xlabel('Frequency Index'); ylabel('Severity Index'); axis square;
%     hold off
    
end

%%
% Above confirms separability by HV attainment:
% -> Now construct the small sample and iterative selection of new
% parameter combinations to test (use already gathered data but clearly
% mark where the DPTP call would come in)


%Sampling: strategy: iterative based on SVM nature


%Specified Initial Sampling
specified_points=[5,1;  10, 1;  20,  1; ...
                  5 11; 10, 11; 20, 11; ...
                  5 21; 10, 21; 20, 21];
              
              
if contains(file_tag,'SDP2')==1
specified_points=[5,2;  10, 2;  20,  2; ...
                  5 11; 10, 11; 20, 11; ...
                  5 21; 10, 21; 20, 21];
end
if contains(file_tag,'HE')==1
specified_points=[5,5;  10,5;  20,5;    30,5;     
                  5,11; 10,11; 20,11;   30,11;
                  5,21; 10,21; 20,21;   30,21];
              
end
              
specified_sample_xyd_classes=[]; sample_inds=[];
for i_row=1:size(specified_points,1)
    specified_sample_xyd_classes=[specified_sample_xyd_classes; ...
    [specified_points(i_row,:) xyd_classes(find(xyd_classes(:,1)==specified_points(i_row,1) & xyd_classes(:,2)==specified_points(i_row,2)),3)]];
    sample_inds=[sample_inds; find(xyd_classes(:,1)==specified_points(i_row,1) & xyd_classes(:,2)==specified_points(i_row,2))];
end
initial_sample_xyd_classes=specified_sample_xyd_classes;
initial_sample_inds=sample_inds;

% %Random Initial Sampling:
% initial_sample_size=6; 
% sample_inds=randsample(length(xyd),initial_sample_size);
% r_sample_xyd_classes=xyd_classes(sample_inds,:);
% r_sample_svm = fitcsvm(r_sample_xyd_classes(:,1:2),r_sample_xyd_classes(:,3),'KernelFunction','rbf','ClassNames',[-1,1],'Standardize',true);
% [scores,xGrid] = PredictScoresOverGrid(r_sample_svm);


initial_sample_svm = fitcsvm(initial_sample_xyd_classes(:,1:2),initial_sample_xyd_classes(:,3),'KernelFunction','rbf','ClassNames',[-1,1],'Standardize',true);
[initial_scores,xGrid] = PredictScoresOverGrid(initial_sample_svm);
if showplots==1
    figure('Position',[1428 7 522 601]);
    [h]= DrawDecisionBoundary(initial_sample_svm,initial_scores,initial_sample_xyd_classes,xGrid,title_string_base);
end

%%

ISVM_accuracies_and_samples=[]; silent_flag=0; title_string=[title_string_base ' (Iterative-SVM)'];
for run_j=1:20;
    if showplots==1
        [h]= DrawDecisionBoundary(initial_sample_svm,initial_scores,initial_sample_xyd_classes,xGrid,title_string);
        
    end
    current_SVs=initial_sample_xyd_classes(initial_sample_svm.IsSupportVector,:);
    sample_inds=initial_sample_inds;

    rep_i=1;
    no_improvement_counter=0; random_additions_attempts=0;
    required_samples=3;
    
    while rep_i<=300 && no_improvement_counter<5

        %Function for deciding next point:
        %Triangulate 
        if rep_i==1
            %nothing
        else
            current_SVs=iterative_sample_xyd_classes(iterative_svm.IsSupportVector,:); 
        end
        mid_point=round(sum(current_SVs(:,1:2),1)/size(current_SVs,1));
        mid_point_class_1_SVs=round(sum(current_SVs((current_SVs(:,3)==1),1:2),1)/sum((current_SVs(:,3)==1)));
        mid_point_class_2_SVs=round(sum(current_SVs((current_SVs(:,3)==-1),1:2),1)/sum((current_SVs(:,3)==-1)));

        %%%%%%%%%%%%%%%%%% Sample evenly but sparsely along score==0 contour %%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                epsilon=0.00001;
                a=[];
                while length(a)<required_samples
                    [a,b]=ind2sub(size(x1Grid),find(scores(:,2)<epsilon & scores(:,2)>-epsilon));
                    epsilon=epsilon*10;
                    
                    if length(a)>required_samples
                        if length(a)>500 %Too many samples realistically to be distinct along the boundary
                            disp('WARNING: Boundary sampling is difficuly, near-centroid sampling in effect this round.')
                            samples=[mid_point_class_2_SVs+[1 1];
                                     mid_point_class_2_SVs+[-1 -1];
                                     mid_point_class_1_SVs+[1 1];
                                     mid_point_class_1_SVs+[-1 -1]];
                            samples(samples(:,1)<1,1)=1; samples(samples(:,2)<1,2)=1; 
                            samples(samples(:,2)>max(y),2)=max(y); samples(samples(:,1)>max(x),1)=max(x);
                        else
                            samples=[];
                            for i=1:length(a) 
                                samples=[samples; x1Grid(a(i),b(i)) x2Grid(a(i),b(i))]; 
                            end
                            if size(unique(round(samples),'rows'),1)<required_samples
                                a=[];
                            else
                                samples=unique(round(samples),'rows');
                            end
                        end
                    elseif length(a)==required_samples
                        samples=[];
                        for i=1:length(a) 
                            samples=[samples; x1Grid(a(i),b(i)) x2Grid(a(i),b(i))]; 
                        end
                    end
                end

                points_to_add=samples(round(linspace(1,size(samples,1),required_samples)),:);

                if sum(current_SVs(:,3)==1)==0 || sum(current_SVs(:,3)==-1)==0
                    if silent_flag==0; disp('No observations for one of the classes, introducing random samples:'); end 
                    points_to_add=[randi(floor(length(x)/2)) randi(floor(length(y)/2));
                                   (floor(length(x)/2))+randi((ceil(length(x)/2))) (floor(length(y)/2))+randi(ceil(length(y)/2))];
                end
                if no_improvement_counter==4 && random_additions_attempts<3
                    if silent_flag==0; disp('No improvements, attempting final random pass by introducing random samples:'); end
                    points_to_add=[randi(floor(length(x)/2)) randi(floor(length(y)/2));
                                   (floor(length(x)/2))+randi((ceil(length(x)/2))) (floor(length(y)/2))+randi(ceil(length(y)/2));
                                   randi(floor(length(x)/2)) (floor(length(y)/2))+randi(ceil(length(y)/2));
                                   (floor(length(x)/2))+randi((ceil(length(x)/2))) randi(floor(length(y)/2))];
                    no_improvement_counter=no_improvement_counter-1;
                    random_additions_attempts=random_additions_attempts+1;
                end
                points_to_add=round(points_to_add);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %Correct points to grid
        points_to_add(points_to_add(:,1)<1,1)=1; points_to_add(points_to_add(:,2)<1,2)=1; 
        points_to_add(points_to_add(:,2)>max(y),2)=max(y); points_to_add(points_to_add(:,1)>max(x),1)=max(x);

        %--> add point indeces to sample_inds
        additional_points=[];
        for i_row=1:size(points_to_add,1)
            additional_points=[additional_points; ...
                find(xyd_classes(:,1)==points_to_add(i_row,1) & xyd_classes(:,2)==points_to_add(i_row,2))];
        end
        sample_inds=[sample_inds; additional_points];
        if length(unique(sample_inds))<length(sample_inds)
            if silent_flag==0; disp(['WARNING:' num2str(length(sample_inds)-length(unique(sample_inds))) '/' num2str(size(additional_points,1)) ' Repeated sample points removed!']); end
            if length(sample_inds)-length(unique(sample_inds))==size(additional_points,1)
                no_improvement_counter=no_improvement_counter+1;
            else
                no_improvement_counter=0;
            end

            if no_improvement_counter==5
                if silent_flag==0;  disp('No improvement for 5 consecutive sampling iterations.')
                disp('Breaking iterative sampling loop.'); end
                sample_inds=unique(sample_inds);
                disp(['Total number of dynamic instances sampled: ' num2str(size(sample_inds,1))])
                if showplots==1
                    [~]= DrawDecisionBoundary(iterative_svm,scores,iterative_sample_xyd_classes,xGrid,title_string);
                    drawnow
                    if saveplots==1
                        print(gcf,[savelocation 'IterativeSVM\ ' file_tag '_IterativeSVM_' num2str(run_j) '_N' num2str(length(sample_inds)) '.png'],'-dpng','-r1200')
                        savefig(gcf,[savelocation 'IterativeSVM\ ' file_tag '_IterativeSVM_' num2str(run_j) '_N' num2str(length(sample_inds)) '.fig'])
                    end
                end
                clf; drawnow
                break
            end
            sample_inds=unique(sample_inds);

        end


        %Training data with new point added:
        iterative_sample_xyd_classes=xyd_classes(sample_inds,:);

        %Retrain:
        iterative_svm = fitcsvm(iterative_sample_xyd_classes(:,1:2),iterative_sample_xyd_classes(:,3),'KernelFunction','rbf','ClassNames',[-1,1],'Standardize',true);
        [scores,xGrid] = PredictScoresOverGrid(iterative_svm);

        hold off
        if showplots==1
            [~]= DrawDecisionBoundary(iterative_svm,scores,iterative_sample_xyd_classes,xGrid,title_string);
            drawnow
    %     pause(2)
            
        else
            if silent_flag==0;  disp(['Completed sampling iteration: ' num2str(rep_i)]); end
        end

        rep_i=rep_i+1;
    end
    
%     if saveplots==1
%        print(gcf,[savelocation 'IterativeSVM\ ' file_tag '_IterativeSVM_' num2str(run_j) '_N' num2str(length(sample_inds)) '.png'],'-dpng','-r1200')
%        savefig(gcf,[savelocation 'IterativeSVM\ ' file_tag '_IterativeSVM_' num2str(run_j) '_N' num2str(length(sample_inds)) '.fig'])
%     end
    
    % Total model accuracy:
    actual_classes=classes;

    [scores,~]=PredictScoresOverGrid(iterative_svm,1);
    final_predicted_classes=[];
    for i=1:size(scores,1)
        final_predicted_classes=[final_predicted_classes; find(scores(i,:)==max(scores(i,:)))];
    end
    final_predicted_classes(final_predicted_classes==1)=-1;
    final_predicted_classes(final_predicted_classes==2)=1;
    final_acc_ISVM=1-(sum((actual_classes+final_predicted_classes)==0)/size(scores,1));
%     disp(['Accuracy of final Iterative-SVM model: ' num2str(final_acc_ISVM)])

    ISVM_accuracies_and_samples=[ISVM_accuracies_and_samples; [final_acc_ISVM length(sample_inds)]];
end
disp(['Mean accuracy of 20 Iterative-SVM models: ' num2str(mean(ISVM_accuracies_and_samples(:,1))) ' +/- ' num2str(round(std(ISVM_accuracies_and_samples(:,1)),2))])
disp(['Mean number of instances sampled per model: ' num2str(mean(ISVM_accuracies_and_samples(:,2))) ' +/- ' num2str(round(std(ISVM_accuracies_and_samples(:,2)),1))])




%%
% SVM made using LHS for instance selection
% Total model accuracy:
actual_classes=classes;
% rng(7); %for reproduciblity
rng(7); LHS_accuracies=[]; title_string=[title_string_base ' (LHS-SVM)'];
for i=1:20 %Change to 1=1:1 for a single example
    p_val=3; %when p_val=3 -> 63 points = 10% of the instance space (JY,FDA etc)
              %when p_val=12 -> 252 points = 40% of the instance space (HE problems)
    samp=lhsdesign(21,p_val,'Criterion','correlation'); 
    samp=ceil(samp.*30); %avoids 0's
    % figure; hold on;
    % for i=1:21; scatter(samp(i,:),[i i i],'.'); end
    g=corr(samp);
    correlation_between_columns=(sum(g(:).^2) - p_val)/2;


    specified_points=[reshape(samp,numel(samp),1) repmat((1:21)',p_val,1)];

    specified_sample_xyd_classes=[]; %sample_inds=[];
    for i_row=1:size(specified_points,1)
        specified_sample_xyd_classes=[specified_sample_xyd_classes; ...
        [specified_points(i_row,:) xyd_classes(find(xyd_classes(:,1)==specified_points(i_row,1) & xyd_classes(:,2)==specified_points(i_row,2)),3)]];
    %     sample_inds=[sample_inds; find(xyd_classes(:,1)==specified_points(i_row,1) & xyd_classes(:,2)==specified_points(i_row,2))];
    end
    LHS_sample_xyd_classes=specified_sample_xyd_classes;

    LHS_sample_svm = fitcsvm(LHS_sample_xyd_classes(:,1:2),LHS_sample_xyd_classes(:,3),'KernelFunction','rbf','ClassNames',[-1,1],'Standardize',true);
    [scores,xGrid] = PredictScoresOverGrid(LHS_sample_svm);
    if showplots==1
        figure('Position',[1428 7 522 601]);
        [h]= DrawDecisionBoundary(LHS_sample_svm,scores,LHS_sample_xyd_classes,xGrid,title_string);
    end

    if saveplots==1
        print(gcf,[savelocation 'LHS-SVM\ ' file_tag '_LHSSVM_' num2str(i) '_N' num2str(length(specified_points)) '.png'],'-dpng','-r1200')
        savefig(gcf,[savelocation 'LHS-SVM\ ' file_tag '_LHSSVM_' num2str(i) '_N' num2str(length(specified_points)) '.fig'])
    end
    
    [scores,~]=PredictScoresOverGrid(LHS_sample_svm,1);
    final_predicted_classes=[];
    for i=1:size(scores,1)
        final_predicted_classes=[final_predicted_classes; find(scores(i,:)==max(scores(i,:)))];
    end
    final_predicted_classes(final_predicted_classes==1)=-1;
    final_predicted_classes(final_predicted_classes==2)=1;
    final_acc_LHS=1-(sum((actual_classes+final_predicted_classes)==0)/size(scores,1));
%     disp(['Accuracy of final LHS-SVM model: ' num2str(final_acc_LHS)])
    drawnow; close %Comment out 'close' to keep all plots
    LHS_accuracies=[LHS_accuracies; final_acc_LHS];
end 
disp(['Mean accuracy of 20 LHS-SVM models: ' num2str(mean(LHS_accuracies)) ' +/- ' num2str(round(std(LHS_accuracies(:,1)),2))])
disp(['Number of instances sampled per model: ' num2str(length(specified_points))])


