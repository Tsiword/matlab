function k2 = k2_cr(b, cr)
% k2 = sqrt(b./cr+1/4);
k2 = b./cr+1/2;
k2(k2>=1) = 0.998;
end

