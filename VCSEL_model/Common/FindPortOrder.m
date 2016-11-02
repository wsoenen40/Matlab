function [ Ports ] = FindPortOrder(FileName)
%%search for string in a file
%INPUT=path to s2p file
%OUTPUT=portorder
FID = fopen(FileName, 'r');
if FID == -1, error('Cannot open file'), end
Data = textscan(FID, '%s', 'delimiter', '\n', 'whitespace', '');
CStr = Data{1};
fclose(FID);
SearchedString='! VAR PHYS_PORTS=';
%Var2Search=x,y

IndexC = strfind(CStr, SearchedString);
Index = find(~cellfun('isempty', IndexC), 1);
IndexAfterSearchedString=IndexC{Index,1}+length(SearchedString);
VarX=str2num(CStr{Index,1}(1,IndexAfterSearchedString));
VarY=str2num(CStr{Index,1}(1,IndexAfterSearchedString+2));
CStr{Index,1}
Ports=[VarX VarY];
end

