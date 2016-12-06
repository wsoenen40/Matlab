function res = F( x, nu, data )


 z = 10*log10(x(4)*(x(1)*1E10)^4./(((x(1)*1E10)^2-nu.^2).^2+(nu/(2*pi)*(x(2)*1E10)).^2)./(1+(nu/(x(3)*1E10)).^2)) - data;

 
res=z,
end

