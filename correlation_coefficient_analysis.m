%% Example script for calcium imaging analysis
% Created by Theo Stylianides 22/1/18
% Note that this script will not work unless you address the following required
% inputs:
% DataLocation
% File should be in .xlsx format
% Here we provide an example of fluorescence Ca2+ imaging under: Low glucose (LG) measured between 1-120s, high glucose (HG) from
% 121-600s, KCl from 601-750s.Sampling_interval should be modified
% according to experiment ex. before or after treatment etc

clear all
close all
clc

%Each excel file is  entitled as 'isletX' etc and depicts the fluorescence
%intensity recorded over time under one or several different conditions.
%Here the conditions are LG, HG, KCl.


op=0;

%Import Files for analysis
%Note: Multiple excel files can be analysed simultaneously by increasing the
%number of d=2, d=3 etc. 
for d=1
   if d==1 
       N=xlsread('islet1.xlsx',1);
        samplename=sprintf('islet1');

   end

%Read sample length, this gives you number of columns in analysis
SampleLength=size(N,2);





%%
%Define sampling  variables and time windows for LG, HG and KCl
% Set up time domain loops
% This enables you to break coding down to 3 windows. This can be edited
% but you need to define alternative w for loops (w=1:2 if 2)
% a and b are the seconds (imaging period) shown in column 1. 
% Plot name is a function used in figures
for w=1:3;
    op=op+1;
if w==1;
    a=1 ;
    b=120;
    plotname=sprintf('LG');
elseif w==2;
    a=121;
    b=600;
    plotname=sprintf('HG');
else
    a=601;
    b=750; 
    plotname=sprintf('KCl');
    
end


% This is the loop responsible for running the correlations 
% i=2:length means from column 2 to last column, column 1 is usually not included as it has text
% Correlation function calculates correlation coeffs between two adjacent
% columns. That's why 2 indexes i and j are set up.

for i=2:SampleLength; 
    for j=2:SampleLength; 
        X=[];
        Y=[]; 
        
        
% Added 5% of sample length smoothing to reduce noise, this can be modified
% accordingly.
% 
        X=smooth(N([a:b],i),0.05);% added 5% smooth  
        Y=smooth(N([a:b],j),0.05); % added 5% smooth

           
[Correlation,Significance]=corrcoef(X,Y);


% Tables below save the output of correlation coeffs. 
% table is always a 2x2 table with 1's in diagonal. Same applies to sign.
% This is purely because corrcoeff evaluates 2 columns at each point of time
% To work around this and keep all values a new table is created (test) to 
% store each output from each loop for each time window (w = 1,2,3)
test(i-1,j-1)=Correlation(2,1);
sign(i-1,j-1)=Significance(2,1);


end
    

     
end


%Plot Heatmaps
z=figure
imagesc(test(:,:),[0 1]) 
%drawnow
colorbar
title('Heatmap of correlation matrix')
xlabel('Cell number')
ylabel('Cell number')
title({['Heatmap of correllation matrix for ',num2str(samplename)];[num2str(plotname)]})
saveas(z,sprintf('FIG%d.jpg',op)); % will create FIG1, FIG2,...


%This function excludes autocorrelation values (1),and calculates the
%significance of each corr coeff value. 
bb(d,w)=(mean(nonzeros(triu(test,1))));
cc(d,w)=mean(nonzeros(triu(sign,1)));
Correlations{d,w}=test(:,:);
Signif{d,w}=sign(:,:);
    

figure
imagesc(sign(:,:),[0 0.1]) 
drawnow
colorbar
title('Heatmap of significance matrix')
xlabel('Cell number')
ylabel('Cell number')
title({['Heatmap of significance matrix for ',num2str(samplename)];[num2str(plotname)]})

figure
hold on
    plot(N([a:b],1),N([a:b],i))
    plot(N([a:b],1),X)
    plot(N([a:b],1),smooth(N([a:b],i),0.1))
    title({['Time series',num2str(samplename)];[num2str(plotname)]})
    legend('N values','Smoothed Values 5%','Smoothed Values 10%')
    axis([a b min(N(a:b,i))/1.2 max(N(a:b,i))*1.2 ]) %axis range adjusts as a function of min and max fluorence in condition state
end


%Empty tables 
test=[]
sign=[]
end

% Calculate R value mean, these are summarised in the command window.  
meanctr=mean(bb,1)


% Column Graphs
figure
y=[meanctr(1) meanctr(2) meanctr(3)];
c=categorical({'LG', 'HG','KCl'})
c = reordercats(c,{'LG' 'HG' 'KCl'});
bar(c,y)
