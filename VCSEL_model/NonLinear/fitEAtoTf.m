function [ fp ] = fitEAtoTf(vcsel_ea,freq ,Zo,debug)
%Calculate transferfunction from EA network and fit to first order low pass
%model with cutt-off frequency fp


ydata(1:length(freq),1)=0.00; %target error of optimizer
[tf_driver_vcsel tf_driver_ea tf_driver_opt] = TransferFunctionTxIsolatedEA( vcsel_ea, ones(6,1), Zo, 0, 0,0,freq);
xdata=tf_driver_ea;
%x=[fr_Hz ; gamma_s ; fp_Hz ; gain] 
xtyp=[18e9];
x0=[15e9];
lb=[1e9];
ub=[40e9];
options=optimset('TolFun',1e-9, 'TolX', 1e-9,'MaxIter',5000,'FinDiffType','central','MaxFunEvals',inf ,'TypicalX',xtyp);
x = lsqcurvefit(@myfun,x0,xdata,ydata,lb,ub,options); % @myfun is function handle to pass a function like a variable

fp=x(1);
if debug
figure
semilogx(freq, db(Hea), freq,db(xdata));
legend('1st order model','ea model')
end

function F=myfun(x,xdata)    
   %s=2*pi*1i*freq;
   Hea=1./(1+1i*freq/x(1)); 
   F=abs(Hea)-abs(xdata);
end

end



