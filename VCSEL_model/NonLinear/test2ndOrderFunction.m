clc
clear all
close all
freq=10e6:10e6:40e9;
fri=25*1e9;
gammai=80e9;
fpi=15*1e9;
gaini=1;
%Hvcsel=x(4)*x(1)^2./(x(1)^2-f.^2+f/2/pi*x(2))./(1+f/x(3));
Hvcsel=gaini*fri^2./(fri^2-freq.^2+1i*freq/2/pi*gammai)./(1+freq/fpi);
%Hvcsel=gaini*fri^2./(fri^2-freq.^2+1i*freq/2/pi*gammai);

semilogx(freq, db(Hvcsel));
