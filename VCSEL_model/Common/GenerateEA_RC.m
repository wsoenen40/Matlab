function [x, resnorm] = GenerateEA_S_RC( xdata_S, freq, Zo)
% Fit measured Z11 parameters to EA model of VCSEL, Construct EA model, Generate EA S matrix
% INPUTS
%   xdata_S=measured S-parameters
%   freq=frequency range
%   Zo=characteristic impedance
%OUTPUTS
%   ea_S=S-matrix of electrical acces network
%   x=circuit values: [Cm Rm2]

%% Optimizer least-square curve fitting
ydata(1:length(freq),1)=0.00; %target error of optimizer
xdata_Z=s2z(xdata_S);
xdata_Z11(:,1)=xdata_Z(1,1,:);

x0=[50 ; 250e-15];
lb=[20 ; 30e-15];
ub=[300 ; 1e-12];
xtyp=[60 ; 300e-15];
options=optimset('TolFun',1e-6, 'TolX', 1e-15,'MaxIter',1000,'MaxFunEvals',1000,'FinDiffType','central','TypicalX',xtyp);

[x, resnorm]= lsqcurvefit(@myfun,x0,xdata_Z11,ydata,lb,ub,options); % @myfun is function handle to pass a function like a variable

%% Generate electrical acces network vcsel

% ser=rfckt.series;
% ser.Ckts={rfckt.shuntrlc('C',x(1)), rfckt.shuntrlc('R',x(2))};
% ea_vcsel=rfckt.cascade;
% ea_vcsel.Ckts={ser,rfckt.seriesrlc('R',x(3)),rfckt.shuntrlc('C',x(4)), rfckt.shuntrlc('R', x(5))};
% analyze(ea_vcsel,freq);
% ea_S=extract(ea_vcsel,'S_parameters',Zo);
% ea_Z=s2z(ea_S);
% ea_Z11(:,1)=ea_Z(1,1,:);
 
 %% debug fitting
 if 1
    ea_vcsel=rfckt.cascade;
    ea_vcsel.Ckts={rfckt.shuntrlc('C',x(2)), rfckt.shuntrlc('R', x(1))};
    analyze(ea_vcsel,freq);
    ea_S=extract(ea_vcsel,'S_parameters',Zo);
    ea_S11(:,1)=ea_S(1,1,:);
    xdata_S11(:,1)=xdata_S(1,1,:);
    %figure
    %plot(freq,abs(ea_S11),freq,abs(xdata_S11)) %S11 does not match because Matlab terminates port 2 while this is not the case with the VCSEL measurement
    %legend('S11 ea','S11 measured')
    figure
    h=plot(freq,real(ea_Z11),freq,imag(ea_Z11),freq,real(xdata_Z11),freq,imag(xdata_Z11));
    legend('Re(Z11 ea)','Im(Z11 ea)','Re(Z11 measured)','Im(Z11 measured)')
    title('Input impedance electrical access','fontname','times','fontsize',28,'fontweight','b','color','k')
    xlabel('Frequency (Hz)','fontname','times','fontsize',24,'fontweight','b','color','k')
    ylabel('Impedance ($\ohm$)','fontname','times','fontsize',24,'fontweight','b','color','k')

    ea_vcsel=rfckt.cascade;
    ea_vcsel.Ckts={rfckt.shuntrlc('C',x(2)), rfckt.shuntrlc('R', x(1)),rfckt.seriesrlc('R',10e6)};
    analyze(ea_vcsel,freq);
    ea_S=extract(ea_vcsel,'S_parameters',Zo);
    ea_S11(:,1)=ea_S(1,1,:);
    xdata_S11(:,1)=xdata_S(1,1,:);
    figure
    smithchart(ea_S11);
    hold on
    smithchart(xdata_S11);
 end
 
%% Fitting function
function F=myfun(x,xdata_Z11)
%Construct electrical acces network VCSEL
    ea_vcsel=rfckt.cascade;
    ea_vcsel.Ckts={rfckt.shuntrlc('C',x(2)), rfckt.shuntrlc('R', x(1))};
    analyze(ea_vcsel,freq);
    ea_S=extract(ea_vcsel,'S_parameters',Zo);
    ea_Z=s2z(ea_S);
    ea_Z11(:,1)=ea_Z(1,1,:);
    %F(:,1)=abs(ea_Z11-xdata_Z11)+abs(real(ea_Z11(1))-real(xdata_Z11(1)));%compare phase and magnitude for curve fitting+DC impedance
    F(:,1)=abs(ea_Z11-xdata_Z11);%compare phase and magnitude for curve fitting

end


end

