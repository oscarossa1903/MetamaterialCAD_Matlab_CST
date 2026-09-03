function r = gielisRadius(theta,m,n1,n2,n3)

a = 1;
b = 1;

term1 = abs(cos(m*theta/4)/a).^n2;

term2 = abs(sin(m*theta/4)/b).^n3;

r = (term1 + term2).^(-1/n1);