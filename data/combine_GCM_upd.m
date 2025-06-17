data1=load('GCM_controls_all_k1.mat');
data2=load('GCM_controls_all_k2.mat');
data3=load('GCM_controls_all_k3.mat');
data4=load('GCM_controls_all_k4.mat');
data5=load('GCM_controls_all_k5.mat');
data6=load('GCM_controls_all_k6.mat');
data7=load('GCM_controls_all_k7.mat');
data8=load('GCM_controls_all_k8.mat');



data1=data1.data1;
data2=data2.data2;
data3=data3.data3;
data4=data4.data4;
data5=data5.data5;
data6=data6.data6;
data7=data7.data7;
data8=data8.data8;

%combinedData = [data1; data2];
combinedData = vertcat(data1, data2,data3, data4, data5, data6, data7, data8);
DCM=combinedData;
save('GCM_controls_all.mat', 'DCM');
