% Name:         Jens Daci 
% UNI:          jd3693
% Course Name:  Analog-Digital Interfaces
% Course Code:  ELEN E6316

clear;
clc;
format long;
N = 9; % 9-bit DAC
V_FS = 1.2; % Full Scale Voltage

filename = 'DAC_9b_levels.csv';
DAC_level = csvread(filename);

% Plotting the DAC Code vs. Analog Output Value
figure(1);
a = DAC_level;
d = (0:1:511);
plot(d, a)
xlim([0 515]);
ylim([-0.6 0.6]);
title("Digital Input Code vs. Analog Output Value")
xlabel("Digital Input Code");
ylabel("Analog Output Value (V)");

% Finding the effective LSB size
V_LSB_actual = (DAC_level(512) - DAC_level(1)) / (2^N - 1);
fprintf('Effective LSB = %.5f mV \n\n', V_LSB_actual * 10^3);

% Finding the Offset Error
V_out_code0 = DAC_level(1);
V_LSB_ideal = V_FS / 2^N;
Offset_Error = V_out_code0 / V_LSB_ideal;
fprintf('Offset Error = %.5f LSBs \n', Offset_Error);

% Finding the Full Scale Error
V_out_all_1_actual = DAC_level(512);
V_out_all_1_ideal = (2^N-1) * V_LSB_ideal;  % 511*VLSB
FullScale_Error = (V_out_all_1_actual - V_out_all_1_ideal) / V_LSB_ideal;
fprintf('Full Scale Error = %.5f LSBs \n\n', FullScale_Error);

% Calculating the DNL and INL 
DNL = zeros(512, 1);
DNL(1) = 0; 

INL = zeros(513, 1);
INL(1) = 0;

for i=2:512
    DNL(i) = ((DAC_level(i) - DAC_level(i-1)) / V_LSB_actual) - 1;
    INL(i+1) = sum(DNL);
end    

% --- DNL ---
% Plotting the DNL vs. DAC Code
figure(2);
plot((0:1:511), DNL)
xlim([0 515]);
title("DNL vs. DAC Code (+0.55602 / -0.13966, std dev 0.07206)");
xlabel("Digital Input Code");
ylabel("DNL");

% Standard deviation of the DNL
DNL_std_dev = std(DNL);
fprintf('Standard Deviation (DNL) = %.5f \n', DNL_std_dev);

% Minimum and Maximum values of DNL 
DNL_Min = min(DNL);
fprintf('Minimum DNL = %.5f LSBs \n', DNL_Min);
DNL_Max = max(DNL);
fprintf('Maximum DNL = %.5f LSBs \n', DNL_Max);
fprintf('The DAC is monotonic. Minimum DNL > -1 LSB. \n\n')

% --- INL ---
% Plotting the INL vs. DAC Code
figure(3);
plot((0:1:512), INL)
xlim([0 515]);
title("INL vs. DAC Code (+1.47870 / -1.65999, std dev 0.96758)");
xlabel("Digital Input Code");
ylabel("INL");

% Standard deviation of the INL
INL_std_dev = std(INL);
fprintf('Standard Deviation (INL) = %.5f \n', INL_std_dev);

% Minimum and Maximum values of INL
INL_Min = min(INL);
fprintf('Minimum INL = %.5f LSBs \n', INL_Min);
INL_Max = max(INL);
fprintf('Maximum INL = %.5f LSBs \n', INL_Max);

% Writing data to a text file
T1 = table(DAC_level, DNL);
writetable(T1, 'analysis_output_DNL.csv', 'WriteVariableNames', 0);
T2 = table(INL);
writetable(T2, 'analysis_output_INL.csv', 'WriteVariableNames', 0);



