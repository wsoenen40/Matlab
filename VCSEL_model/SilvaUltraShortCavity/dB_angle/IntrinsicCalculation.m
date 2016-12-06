%Put this in the folder of the data (important!!!!!!)
% CHANGEEE THRESHOLD !!!!!!!!!!!!!!!!!!!!!!
clear
clc

files = dir('H:\Backup\Data_15_12_2014\Data\HighSpeedMeasurament\M6079_SSC\2015_10_5\dB_angle\M6079_2_7_3_2_20C_*.S2P')
Ith=0.9; %mA

col =4; %insert number of column that you are interested
%Sort per data
 [junk, sortorder] = sort([files.datenum]);
 files = files(sortorder); %list is now in ascending date order

Header{1}=strtrim('Frequency');
 
 numfiles = numel(files);
 DATA = cell(numfiles,1);
 
 fid2 = fopen('Frequency Response U2t photo-receiver.dat','r');
 CAL = textscan(fid2,'%f %f','Delimiter','\t','headerlines',1);
 fclose(fid2);
 
 for ii = 1:numfiles
 numberStr = regexp(files(ii).name,'M6079_2_7_3_2_20C_(\d*).(\d*)','tokens')
 Current(ii,1)= str2double(numberStr{1}{1,1})+str2double(numberStr{1}{1,2})/10    
 fid = fopen(files(ii).name,'r');
 DATA{ii} = textscan(fid,'%f %f %f  %f %f %f %f %f %f ','Delimiter','\t','headerlines',11);
 fclose(fid);
 
 Header{1}=strtrim('Frequency');
 Header{ii+1} = strtrim(files(ii).name); %Header
 %Header{2*ii+1} = strtrim(files(ii).name); %Header
 
 nu(:,1)=DATA{ii}{1}; %Frequency
 data= DATA{ii}{col}-CAL{2}-DATA{1}{col}(6);
 A(:,ii+1)=data;
 
 
 x0=[2 10 1.5 1];
%options.Algorithm = 'trust-region-reflective';
[x,resnorm,~,exitflag,output]=lsqnonlin(@(x)Fit(x,nu,data),x0); %credo che trovi le x che minimizzano data al variare di omega.. solo reali
FitParam(ii,1)= Current(ii,1);
FitParam(ii,2)= x(1)*1E10; %omegaR
FitParam(ii,3)= x(2)*1E10; %Gamma
FitParam(ii,4)= x(3)*1E10; %f_p
FitParam(ii,5)= x(4); %C
Header4{1}=strtrim('Current');
Header4{2}=strtrim('NuR');
Header4{3}=strtrim('Gamma');
Header4{4}=strtrim('Fp');
Header4{5}=strtrim('C');

 Fout =@(x,nu) 10*log10(x(4)*(x(1)*1E10)^4./(((x(1)*1E10)^2-nu.^2).^2+(nu/(2*pi)*(x(2)*1E10)).^2)./(1+(nu/(x(3)*1E10)).^2))  ;    %(x(1)+x(2)./(1+((nu*2*pi).^2)*(x(2).^2)*(x(3).*10^(-12))^2))-j*((nu*2*pi).*(x(2).^2)*(x(3).*10^(-12)))./(1+((nu*2*pi).^2)*(x(2).^2)*(x(3).*10^(-12))^2);

    plot(nu/10^9,data(:),'o');
    hold on
    plot(nu/10^9,Fout(x,nu),'r')
    hold on
        
%D factor
DK(ii,1)=sqrt(FitParam(ii,1)-Ith);
DK(ii,2)=FitParam(ii,2);
DK(ii,3)=FitParam(ii,2)^2;
DK(ii,4)=FitParam(ii,3);
DK(ii,5)=FitParam(ii,1);
DK(ii,6)=FitParam(ii,4);
Header2{1}=strtrim('sqrt(I-Ith)');
Header2{2}=strtrim('NuR');
Header2{3}=strtrim('NuR^2');
Header2{4}=strtrim('Gamma');
Header2{5}=strtrim('I');
Header2{6}=strtrim('fp');

 end
 hold off
 
  ds4=  dataset({FitParam,Header4{:}})
  export(ds4,'file','M6079_2_7_3_2_20C_FitParam','Delimiter','\t')
  
  ds2=  dataset({DK,Header2{:}})
  export(ds2,'file','M6079_2_7_3_2_20C_DK','Delimiter','\t')
  
    A(:,1)=nu; 
    for ii = 1:numfiles  
    A(:,ii+1)=A(:,ii+1)-DATA{3}{col}(6)+DATA{1}{col}(6);
    end     
 ds = dataset({A,Header{:}});
 export(ds,'file','M6079_2_7_3_2_20C','Delimiter','\t')