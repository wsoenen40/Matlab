function [ Snorm ] = SwitchSpar( S , Ports)
%Switch S-matrix depending on physical port order
sizeS=size(S);
Snorm=zeros(sizeS(1),sizeS(2),sizeS(3));
normPort=[2 1];%PD at port2 and VCSEL at port1
if Ports(1)==normPort(1) && Ports(2)==normPort(2)
    Snorm=S;
else
    %switch S11 with S22 and S21 with S12
    switching=1
    Snorm(1,1,:)=S(2,2,:);
    Snorm(2,2,:)=S(1,1,:);
    Snorm(2,1,:)=S(1,2,:);
    Snorm(1,2,:)=S(2,1,:);
end
end

