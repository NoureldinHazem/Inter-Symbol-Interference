
fs = 1e6; % Sampling frequency
N = 1e5;  % Total number of Samples
Ts = 1/fs; % Sampling Time
t = (0:N-1)*Ts; % Main Time Axis
f_axis = -fs/2:fs/N:fs/2-1/N; % Generating f_axis for the pulse
TIME_AXIS_SIZE = length(t); % The length of the time axis


% Channel bandwidth frequency
B = 100 * 10^3;

%----------------------------------------------------------------------------
% Graph Specs
f_limit = fs * 0.55;
t_limit = (2/B)*1.4;


%-----------------------------------------------------------------------------
% Generate Square pulse in Time Domain

N_square_pulse = (2/B) * fs; % Number of samples in the square pulse
first_square_pulse = ones(1, N_square_pulse); % Generate Train of ones

% Put the square signal on the main time axis
first_square_pulse = [first_square_pulse zeros(1, N - N_square_pulse)];  

% Square pulse in the freq domain
square_pulse_freq = fftshift(fft(first_square_pulse)); 


figure
subplot(2,1,1)

% Plot the pulse in time domain
plot(t,first_square_pulse)
grid on
xlim([0 t_limit * 5])
xlabel('Time (s)')
ylabel('Amplitude')
title('Square Signal Pulse (Time Domain)')

% Plot the pulse in freq domain
subplot(2,1,2)
plot(f_axis, abs(square_pulse_freq))
grid on
xlim([-f_limit f_limit])
xlabel('Frequency (Hz)')
ylabel('Amplitude')
title('Square Signal Pulse (Freq Domain)')

%-----------------------------------------------------------------------------
% Generate The Band Limited Channel

% Generate the filter in freq domain
bl_channel_freq = rectpuls(f_axis , 2*B);

% Get the channel in the time domain
bl_channel = real(ifft(ifftshift(bl_channel_freq)));

t_sinc_bl_channel = (-N/2:(N-1)/2)*Ts;

% TODO: FIX THE TIME DOMAIN CHANNEL

figure

% Plot the channel in the time domain
subplot(2,1,1)
plot(t_sinc_bl_channel,bl_channel)
grid on
title('Band Limited Channel (Time Domain)')
xlim([-t_limit * 5 t_limit * 5])
xlabel('Time (s)')
ylabel('Amplitude')

% Plot the channel in the freq domain
subplot(2,1,2)
plot(f_axis, abs(bl_channel_freq))
title('Band Limited Channel (Frequency Domain)')
xlim([-f_limit f_limit])
xlabel('Frequency (Hz)')
ylabel('Amplitude')

%-----------------------------------------------------------------------------
% Filter the signal by passing through the channel


% Convultion of the square signal by the band limited channel (filtering)
filtered_square_pulse = conv(first_square_pulse, bl_channel);

% Trimming the function to fit the time axis
filtered_square_pulse = filtered_square_pulse(1:TIME_AXIS_SIZE);

% Generate frequency domain of the filtered signal
filtered_square_pulse_freq = fftshift(fft(filtered_square_pulse));


figure;
subplot(2,1,1)
plot(t, filtered_square_pulse)
title('Filtered Square Pulse (Time Domain)')
xlim([0 t_limit * 5])
xlabel('Time (s)')
ylabel('Amplitude')


% Plot the channel in the freq domain
subplot(2,1,2)
plot(f_axis, abs(filtered_square_pulse_freq))
title('Band Limited Channel (Frequency Domain)')
xlim([-f_limit * .7 f_limit* .7])
ylabel('Amplitude')
xlabel('Frequency (Hz)')

%------------------------------------------------------------------------------------
% Generate the two consectuive pulses

second_square_pulse = ones(1, N_square_pulse); % Generate Train of ones
second_square_pulse = [zeros(1, N_square_pulse) second_square_pulse zeros(1, N - 2* N_square_pulse)];

figure;
plot(t, first_square_pulse, 'r')
hold on
plot(t, second_square_pulse, 'b')
title('Filtered Square Pulse (Time Domain)')
xlim([0 t_limit * 5])
xlabel('Time (s)')
ylabel('Amplitude')

%------------------------------------------------------------------------------------
% Convlute the two cons pulses with the band limited channel

% Repeat what we have done for the first pulse
filtered_second_square_pulse = conv(second_square_pulse, bl_channel);
filtered_second_square_pulse = filtered_second_square_pulse(1:TIME_AXIS_SIZE);
filtered_second_quare_pulse_freq = fftshift(fft(filtered_second_square_pulse));

figure;

% Plot the two pulses in time domain
subplot(2,1,1)
plot(t, filtered_square_pulse, 'r')
hold on
plot(t, filtered_second_square_pulse, 'b')
title('Filtered Two Pulses (Time Domain)')
xlim([0 t_limit * 5])
xlabel('Time (s)')
ylabel('Amplitude')

% Plot the two pulses in freq domain
subplot(2,1,2)
plot(f_axis, abs(filtered_square_pulse_freq), 'r')
hold on
plot(f_axis, abs(filtered_second_quare_pulse_freq), 'b')
title('Filtered Two Pulses (Freq Domain))')
xlim([-f_limit * .7 f_limit* .7])
ylabel('Amplitude')
xlabel('Frequency (Hz)')


