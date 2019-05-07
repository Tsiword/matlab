b = lsqcurvefit(@k2_cr,2,Cr,k);
figure,plot(Cr,k,':*',Crn,k2_cr(b,Crn));
xlabel('Relative Supercapacitor Capacity M'),ylabel('{Paremeter k_2}');
legend('Optimization results','Fitting curve')