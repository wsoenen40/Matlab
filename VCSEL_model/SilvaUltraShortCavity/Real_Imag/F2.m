function res = F( x, nu, data )


Lpad=10^(-15);
 z =  (j*(nu*2*pi)*x(4)*10^-12+(j*(nu*2*pi)*Lpad+x(1)+(1/x(2)+j*(nu*2*pi)*x(3)*10^(-12)).^-1).^-1).^-1 - data;

res=[real(z); imag(z)],
end

