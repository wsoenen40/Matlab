%Put this in the folder of the data (important!!!!!!)

clear
clc

fileList = dir('H:\Backup\Data_15_12_2014\Data\HighSpeedMeasurament\M6079_SSC\2015_10_5\dB_angle\M6079_2_7_3_2_20C_*.S2P')
col =4; %insert number of column that you are interested
%Sort per data
 [junk, sortorder] = sort([fileList.datenum]);
 fileList = fileList(sortorder); %list is now in ascending date order

Header{1}=strtrim('Frequency');
 
 numfiles = numel(fileList);
 DATA = cell(numfiles,1);
 
 fid2 = fopen('Frequency Response U2t photo-receiver.dat','r');
 CAL = textscan(fid2,'%f %f','Delimiter','\t','headerlines',1);
 fclose(fid2);
 
 for ii = 1:numfiles     
 fid = fopen(fileList(ii).name,'r');
 DATA{ii} = textscan(fid,'%f %f %f  %f %f %f %f %f %f ','Delimiter','\t','headerlines',11);
 fclose(fid);
 Header{1,ii+1} = strtrim(fileList(ii).name); %Header

 A(:,1)=DATA{ii}{1}; %Frequency
 A(:,ii+1)=DATA{ii}{col}-CAL{2}; %Responce % take only column column 
 end
  for ii = 1:numfiles  
 A(:,ii+1)=A(:,ii+1)-DATA{3}{col}(6);
  end
 ds = dataset({A,Header{:}});
 export(ds,'file','M6079_2_7_3_2_20C','Delimiter','\t')