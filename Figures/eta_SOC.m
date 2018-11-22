Soc = 0:0.01:1;
a = 0.15;
b = 0.35;
% eta = (1-a*b-(1-b)*Soc)./(1-a);
eta = zeros(101,3);
eta(:,1) = sqrt(1.2-Soc);
eta(:,2) = sqrt(1-Soc)+0.2;
eta(:,3) = sqrt(1-Soc)+0.3;
eta(eta>1) = 1; 
figure,plot(Soc,eta);
axis([0 1 0 1]);
xlabel('SOC'),ylabel('Charge Power Ratio \eta');
% legend('1','2','3')
% xlabel('SOC'),ylabel('Charge Power Ratio {\eta}','Rotation',90,'FontSize',10);
