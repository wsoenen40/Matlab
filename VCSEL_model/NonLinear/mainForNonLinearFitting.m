%Template for extracting non-linear VCSEL model based on extraction of K
%and D factor
%VCSEL model consists of electrical access part isolated from a optical RLC
%model of which L and R are non-linear and C is fixed
%S21 is fitted to squared magnitude of three pole function to extract
%fr,gamma and wp=> K and D are extracted from linear fit to fr,gamma
%Verilog-A model needs to be created for L and R 



%PROBLEM: fp is almost always higher than fr, probably best to fit fp first
%to electricall access model before fitting to S21
close all
clear all
addpath ~/GitHub/Matlab/VCSEL_model/Common
%addpath ~/CloudStation/Matlab/VCSEL_model

vcsel=7;
saveVar=0;
debug=1;

Ith=0.8;


%% Read in .s2p files with corresponding Ibias
switch vcsel
    case 1 
        Ivcsel=[3.75 6 9.75 15];
        %Ivcsel=[3.75 9.75];
    case 2 
        Ivcsel=[1.5 2.1 2.9 3.8 4.8 6 7.4 9];
        %Ivcsel=[6];
        %load('../SilviaM6079B1.mat');
    case 3
        Ivcsel=[1.8 3.4 6.2 10 15];
    case 4
        Ivcsel=[1.8 3.4 6.2 10 15];
        %Ivcsel=1.8;
        %load('../SilviaM6082C3sm.mat');
    case 5
        %Ivcsel=[1.8 2.5 3.5 4.8 6.4 8.3 10 10.4];
        Ivcsel=6.4;
    case 6
        Ivcsel=[1.4 1.8 2.5 3.5 4.8 6.4 8.3 10.4 12.9 15.6];
        %Ivcsel=6.4;
    case 7
        Ivcsel=[0];
        

end
%vcsel_ea=zeros(5,length(Ivcsel));
%vcsel_opt=zeros(6,length(Ivcsel));
for i=1:length(Ivcsel)
    switch vcsel

        case 1 
            File=strcat('../P7C1/M5400_2_7_14_5__',num2str(Ivcsel(i)),'mA_22C.S2P');
        case 2 
            File=strcat('../SilvaUltraShortCavity/dB_angle/M6079_2_7_3_2_20C_',num2str(Ivcsel(i)),'mA_-17.5dBm.S2P');
        case 3
            File=strcat('../SilvaUltraShortCavity/M6082/dB_angle/M6082_18_15_2_2_20C_',num2str(Ivcsel(i)),'mA_-16.5dBm.S2P');
        case 4
            File=strcat('../SilvaUltraShortCavity/M6082/M6082C3sm/M6082_19_17_2_2_20C_',num2str(Ivcsel(i)),'mA_-17.5dBm.S2P');
        case 5
           File=strcat('../SilvaUltraShortCavity/M6082differentMesaDiameter/dB_angle/M6082_13_13_2_2_20C_',num2str(Ivcsel(i)),'mA_-17.5dBm_1_1.S2P');
        case 6
           File=strcat('../SilvaUltraShortCavity/M6082differentMesaDiameter/dB_angle/M6082_10_13_2_2_20C_',num2str(Ivcsel(i)),'mA_-17.5dBm.S2P');
        case 7
            File=strcat('../SilvaUltraShortCavity/M6079_SG100/Vb_0_2V_0mA.s1p');
    end
    Ivcsel(i)
    Ports=FindPortOrder(File);
    measured_data=read(rfdata.data, File);
    freq = measured_data.Freq;
    aperture=1e6;
    AnalyzedData=analyze(measured_data,freq,aperture);
    Zo=AnalyzedData.Z0;

    %% Construct circuit model for every Ibias 
    
    if 0
        %Debug .S2P file by plotting all Sparameters
        total_S=AnalyzedData.S_parameters;
        total_S11(:,1)=total_S(1,1,:);
        total_S12(:,1)=total_S(1,2,:);
        total_S21(:,1)=total_S(2,1,:);
        total_S22(:,1)=total_S(2,2,:);
        subplot(2,2,1)
        semilogx(freq,db(total_S11))
        title('S11')
        subplot(2,2,2)
        semilogx(freq,db(total_S12))
        title('S12')
        subplot(2,2,3)
        semilogx(freq,db(total_S21))
        title('S21')
        subplot(2,2,4)
        semilogx(freq,db(total_S22))
        title('S22')
    end  
        S_parameters=SwitchSpar(AnalyzedData.S_parameters, Ports);
        %[vcsel_ea(:,i), residual_S11]=GenerateEA_RC(S_parameters, freq, Zo);
        %Req=50.*vcsel_ea(1,:)./(50+vcsel_ea(1,:));
        %fp=1./(6.28*Req.*vcsel_ea(2,:));
        [vcsel_ea(:,i), residual_S11]=GenerateEA_S_Silvia(S_parameters, freq, Zo);

        %[ fp(i) ] = fitEAtoTf(vcsel_ea(:,i),freq ,Zo,1);
        %[ fr(i), gamma(i), gain(i)] = FitS21toThreePoleTf(S_parameters,freq ,Zo,fp(i),0);
        [ fr2(i), gamma2(i), gain2(i), fp2(i)] = FitS21toMultiPoleTf(S_parameters,freq ,Zo,vcsel_ea(:,i),0);
        
end

% figure;
% plot(sqrt(Ivcsel-Ith),fr2,sqrt(Ivcsel-Ith),fr,sqrt(Ivcsel-Ith),fp2);
% legend('fr2','fr','fp2')
% figure;
% plot(fr2.^2,gamma2,fr.^2,gamma)
% legend('gamma2','gamma1')
% 
if saveVar
    switch vcsel
        case 1
            save('SilviaM5400p7C1.mat','vcsel_ea','vcsel_opt');
        case 2 
            save('SilviaM6079B1RC.mat','vcsel_ea','fp');
        case 3
            save('SilviaM6082B1.mat','vcsel_ea','vcsel_opt'); 
        case 4
            save('SilviaM6082C3sm_fixedRpCp.mat','vcsel_ea','fp2','fr2','gamma2','gain2'); 
        case 5
            save('SilviaM6082_14umRC.mat','vcsel_ea','fp'); 
        case 6
            save('SilviaM6082_20um_largeRpCp.mat','vcsel_ea','fp2','fr2','gamma2','gain2');
    end
end
      
