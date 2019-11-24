function posllh = xyz2llh_a(posxyz)

x = posxyz(1);
y = posxyz(2);
z = posxyz(3);

a = 6378137.0;
f = 1/298.257223563;
b = a*(1-f);
e2 = f*(2-f);
m2 = 1/(1-e2) - 1;

p = sqrt(x^2 + y^2);
theta = atan(z*a/(p*b));
phi = atan((z+m2*b*sin(theta)^3)/(p-e2*a*cos(theta)^3));
N = a/sqrt(1-e2*sin(phi)^2);
h = p/cos(phi) - N;

posllh(1,1) = phi;
posllh(2,1) = atan2(y,x);
posllh(3,1) = h;
