%Put this in the folder of the data (important!!!!!!)
%This calculate the real and the immaginary part of the impedence from the
%S11 parameter
clear
clc

%fileList = dir('*.S2P')
files = dir('H:\Backup\Data_15_12_2014\Data\HighSpeedMeasurament\M6079_SSC\2015_10_5\Real_Imag\M6079_2_7_3_2_20C_*.S2P')
%fileList = fileList(~[fileList.isdir]); %remove directories

col =2; %Column of the real part of S11
col2= col + 1; %Column of the imaginary part of S11


%Sort per data
 [junk, sortorder] = sort([files.datenum]);
 files = files(sortorder); %list is now in ascending date order


 
 
 numfiles = numel(files);
 DATA = cell(numfiles,1);
 for ii = 1:numfiles 
 numberStr = regexp(files(ii).name,'M6079_2_7_3_2_20C_(\d*).(\d*)','tokens')
 Current(ii,1)= str2double(numberStr{1}{1,1})+str2double(numberStr{1}{1,2})/10
 fid = fopen(files(ii).name,'r');
 DATA{ii} = textscan(fid,'%f %f %f %f %f %f %f %f %f ','Delimiter','\t','headerlines',11);
 fclose(fid);

 Header{1}=strtrim('Frequency');
 Header{2*ii} = strtrim(files(ii).name); %Header
 Header{2*ii+1} = strtrim(files(ii).name); %Header
 %Header2{ii}= strtrim(files(ii).name); 
 
 %Calculate from the data the impedence
 nu= DATA{ii}{1}; %Frequency
    ReS11=DATA{ii}{col};   %REAL S11
    ImS11=DATA{ii}{col2};  %IMAG S11
 
    Zre(:,ii)= 50*(1-ImS11.^2-ReS11.^2)./((1-ReS11).^2+ImS11.^2); % Real part of Zin
    Zim(:,ii)= 50*(2*ImS11)./((1-ReS11).^2+ImS11.^2);              %Imaginary part of Zin 
    Z_in(:,ii)= Zre(:,ii)+j*Zim(:,ii);
    data= Z_in(:,ii);
    

x0=[20 20 1 0.1];
%options.Algorithm = 'trust-region-reflective';
[x,resnorm,~,exitflag,output]=lsqnonlin(@(x)F2(x,nu,data),x0); %credo che trovi le x che minimizzano data al variare di omega.. solo reali
FitParam(ii,1)= Current(ii,1);
FitParam(ii,2)= x(1); %Rm
FitParam(ii,3)= x(2); %R
FitParam(ii,4)= x(3); %Cm
FitParam(ii,5)= x(4); %Cm
Header4{1}=strtrim('Current');
Header4{2}=strtrim('Rm');
Header4{3}=strtrim('R');
Header4{4}=strtrim('Cm');
Header4{5}=strtrim('Cp');


Lpad=1*10^(-15);

Fout =@(x,nu) (j*(nu*2*pi)*x(4)*10^-12+(j*(nu*2*pi)*Lpad+x(1)+(1/x(2)+j*(nu*2*pi)*x(3)*10^(-12)).^-1).^-1).^-1;    %(x(1)+x(2)./(1+((nu*2*pi).^2)*(x(2).^2)*(x(3).*10^(-12))^2))-j*((nu*2*pi).*(x(2).^2)*(x(3).*10^(-12)))./(1+((nu*2*pi).^2)*(x(2).^2)*(x(3).*10^(-12))^2);

    plot(nu/10^9,Zre(:,ii),'o');
    hold on
    plot(nu/10^9,real(Fout(x,nu)),'r')
    hold on
    plot(nu/10^9,imag(Fout(x,nu)),'r')
    hold on  
    plot(nu/10^9,Zim(:,ii),'o');
    hold on
    
    %Output
    ZOut(:,1)=nu;  
    ZOut(:,2*ii)= Zre(:,ii);
    ZOut(:,2*ii+1)= Zim(:,ii);
    %ZimOut(:,ii+1)= Zim(:,ii);
 end
    hold off
 

  ds2=  dataset({ZOut,Header{:}})
  export(ds2,'file','M6079_2_7_3_2_20C_Imped','Delimiter','\t')
  
%   ds3=  dataset({ZimOut,Header{:}})
%   export(ds3,'file','M6079_2_7_3_2_20C_Zim','Delimiter','\t')

  ds4=  dataset({FitParam,Header4{:}})
  export(ds4,'file','M6079_2_7_3_2_20C_FitParam','Delimiter','\t')
  
