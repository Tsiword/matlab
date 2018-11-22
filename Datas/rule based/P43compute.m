function P43 = P43compute(b, kc)
kr2 = b./kc+1/4;
P43 = 0.99*sqrt(kr2);
P43(kr2>=1) = 0.99;   
end

