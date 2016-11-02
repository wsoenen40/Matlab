function [ fr, gamma, fp, gain] = FitS21toThreePoleTf( total_S,freqRange ,Zo,debug )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
freq_start=1;
freq=freqRange(freq_start:end);
ydata(1:length(freq),1)=0.00; %target error of optimizer
xdata(:,1)=total_S(2,1,freq_start:end)/abs(total_S(2,1,freq_start));
%x=[fr_Hz ; gamma_s ; fp_Hz ; gain] 
xtyp=[20 ; 80 ; 15 ; 0.2];
x0=[20 ; 80 ; 15 ; 0.2];
lb=[0.1 ; 0.01 ; 0.1 ; 0.0001];
ub=[100 ; 400 ; 50 ; 1000];
options=optimset('TolFun',1e-9, 'TolX', 1e-9,'MaxIter',5000,'FinDiffType','central','MaxFunEvals',inf ,'TypicalX',xtyp);
x = lsqcurvefit(@myfun,x0,xdata,ydata,lb,ub,options); % @myfun is function handle to pass a function like a variable

fr=x(1);
gamma=x(2);
fp=x(3);
gain=x(4);

if debug
figure
semilogx(freq, db(Hvcsel), freq,db(xdata)-db(xdata(freq_start)));
end

function F=myfun(x,xdata)    
   %s=2*pi*1i*freq;
   fri=x(1)*1e9;
   gammai=x(2)*1e9;
   fpi=x(3)*1e9;
   gaini=x(4);
   %Hvcsel=x(4)*x(1)^2./(x(1)^2-f.^2+f/2/pi*x(2))./(1+f/x(3));
   %Hvcsel=gaini*fri^2./(fri^2-f.^2+f/2/pi*gammai)./(1+f/fpi);
   Hvcsel=gaini*fri^2./(fri^2-freq.^2+1i*freq/2/pi*gammai)./(1+freq/fpi);

   F=abs(Hvcsel).^2-abs(xdata).^2;
end

end

