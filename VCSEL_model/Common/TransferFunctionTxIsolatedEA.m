function [ tf_driver_vcsel tf_driver_ea tf_driver_opt ] = TransferFunctionTxIsolatedEA( ea, opt, Rd, Lbw, Cd,laplace,f)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Calculate transfer function driver-vcsel interface

%driver output
%electrical parasitics: [Rp Cp Rm1 Cm Rm2]
Rp=ea(1);
Cp=ea(2);
Rm1=ea(3);
Cm=ea(4);
Rm2=ea(5);
%optical response: [Rj Cj Lo Ro H Cpd]
Rj=opt(1);
Cj=opt(2);
Lo=opt(3);
Ro=opt(4);
H=opt(5);
Cpd=opt(6);

%transfer function
if laplace
    s=tf('s');
    
    vd=Rd/(1+s*Rd*Cd);%normalized input voltage, should result in decreased DC gain for decreasing Rd
    Zd=Rd/(1+s*Rd*Cd);
    va=vd*(Rp+1/(s*Cp))/(Zd+s*Lbw+Rp+1/(s*Cp));
    Za=(Rp+1/(s*Cp))*(Zd+s*Lbw)/(Rp+1/(s*Cp)+Zd+s*Lbw);
    vb=va/(1+(Rm1+Za)*s*Cm);
    Zb=(Za+Rm1)/(1+s*Cm*(Za+Rm1));
    ia=vb/(Zb+Rm2)*(Rm1+Rm2+Rd)/Rd;%(Rm1+Rm2+Rd)/Rd normalizes current gain
    Zj=Rj/(1+s*(Rj*Cj));
    il=ia*Zj/(Zj+s*Lo+Ro);
    tf_driver_vcsel=H/(1+s*Cpd*50/2)*il;        
    tf_driver_ea=ia;
    tf_driver_opt=Zj/(Zj+s*Lo+Ro);
    
else
    s=1i*2*pi*f;

    vd=Rd./(1+s.*Rd.*Cd);%normalized input voltage, should result in decreased DC gain for decreasing Rd
    Zd=Rd./(1+s.*Rd.*Cd);
    va=vd.*(Rp+1./(s.*Cp))./(Zd+s.*Lbw+Rp+1./(s.*Cp));
    Za=(Rp+1./(s.*Cp)).*(Zd+s.*Lbw)./(Rp+1./(s.*Cp)+Zd+s.*Lbw);
    vb=va./(1+(Rm1+Za).*s.*Cm);
    Zb=(Za+Rm1)./(1+s.*Cm.*(Za+Rm1));
    ia=vb./(Zb+Rm2).*(Rm1+Rm2+Rd)./Rd;%(Rm1+Rm2+Rd)./Rd normalizes current gain
    %ia=vb./(Zb+Rm2);%includes current gain

    Zj=Rj./(1+s.*(Rj.*Cj));
    il=ia.*Zj./(Zj+s.*Lo+Ro);
    tf_driver_vcsel=abs(H./(1+s.*Cpd.*50./2).*il);        
    tf_driver_ea=abs(ia);
    tf_driver_opt=abs(Zj./(Zj+s.*Lo+Ro));
    
end

end

