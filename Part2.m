clear all
clc

%Number of paths
L = 50;

%number of bits
number_of_bits=5000;
%Generating random bit signal of size 5000
random_bits=randi([0 1],number_of_bits,1);

%BPSK modulater (0-> -1) & 1 not changed
for i = 1 : 1 : length(number_of_bits)
  if (random_bits(i) == 0 )
      random_bits(i) = -1;
  end
end

%assuming that the coefficients of the channel are Complex Gaussian with zero mean and variance 1.
variance = 1;
%h is the channel effect on the transmitted signal
h = sqrt(variance/2) * (randn(L,1)+1i*rand(L,1));

%the effect of the length of each path & the attenuation     
attenuation = exp(-0.5*[0:L-1])';        
h = abs(h).*attenuation;

if (number_of_bits >= L)
    h = [h ; zeros(number_of_bits - L , 1)];
else
    h = h(1:number_of_bits);
end

H = zeros(length(h),length(h));

for i = 1:length(h)
    for k = 1:i
        H(i,k) = h(i-k+1);
    end
end

                %%%%%%%%%%%%%%%%%%%%For Testing%%%%%%%%%%%%%%%
%noise (AWGN) 
% noise = 0.05;    %assumption
% sigma = sqrt(noise);
% N = sigma*randn(number_of_bits,1); 
% 
% 
% %Received signal after adding noise
% Y = ( H * random_bits) + N;

%passing the received signal through the equalizer
% H_inv = inv(H);
% orignal_signal = H_inv * Y;    

% %removing noise from equalized signal
%     for k=1:1:number_of_bits
%         if (orignal_signal(k) > 0)
%             orignal_signal(k) = 1;      
%         else
%             orignal_signal(k) = -1;
%         end
%     end

%BER
% error_bits = length( find(orignal_signal ~= random_bits) );
% BER_vector = error_bits/(length(random_bits));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
H_inv = inv(H);
Eb=1; %given Energy
Eb_No_dB = (0:2:20)';         % assumption   
Eb_No = 10.^(Eb_No_dB/10);              
No_vec = (Eb)./ Eb_No;   
BER_vec = zeros(length(No_vec),1);
N_trail = 6;
for count = 1:length(No_vec)
    %sigma = sqrt(No_vec(count));
    %Noise = sigma*randn(number_of_bits,1);
    Noise = awgn(random_bits,No_vec(count),'measured');
    BER_vector = zeros(1,N_trail);
    for s = 1:N_trail        %calculate the BER 6 times for each noise ang get the average
        Y = ( H * random_bits ) + Noise;
        orignal_signal = H_inv * Y;
        for k=1:1:number_of_bits
            if (orignal_signal(k) > 0)
                orignal_signal(k) = 1;      
            else
                orignal_signal(k) = -1;
            end
        end
        error_bits = length( find(orignal_signal ~= random_bits) );
        BER_vector(s) = error_bits/(length(random_bits));
    end
    
    BER_vec(count) = (sum(BER_vector))/N_trail;

end
             %--------------------------plot--------------------------
%Linear:
figure(1)
plot(Eb_No , BER_vec,'linewidth',2);
xlabel('Eb/No (SNR per bits)')
ylabel('BER')
title('Eb/No  vs  BER   (linear scale)')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%DB:
figure(2)
semilogy(Eb_No_dB,BER_vec,'linewidth',2);
grid on;      hold on;
xlabel('Eb/No(dB) -SNR per bits-')
ylabel('BER')
title('Eb/No(dB)  vs  BER   (dB scale)')
