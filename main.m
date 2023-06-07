clearvars; close all; clc

% Configurações do dispositivo de captura de áudio.
deviceReader = audioDeviceReader;
deviceReader.Driver = 'DirectSound';
deviceReader.Device = 'External Mic (Realtek(R) Audio)';
Fs = deviceReader.SampleRate; % 44100 Hz

% Configuração da saída.
Out = audioDeviceWriter('SampleRate', Fs);

% Coeficientes do filtro passa-alta. 
% Janela de Kaiser (N: 88), Fs: 44100 Hz, Fstop: 220 Hz, Fpass: 1000 Hz, Amax: 30 dB, Amin: 1 dB.
coef = [0.00183967957912628,0.00175964661254210,0.00163992738577175,0.00147746765566453,0.00126944514974097,0.00101331200607814,0.000706835631748383,0.000348137436695825,-6.42710864917189e-05,-0.000531455445700654,-0.00105402887633324,-0.00163212715878514,-0.00226538793195701,-0.00295293486151299,-0.00369336696928961,-0.00448475337312145,-0.00532463362508756,-0.00621002377151572,-0.00713742819085010,-0.00810285719649952,-0.00910185032195487,-0.0101295051356671,-0.0111805113643439,-0.0122491900363413,-0.0133295372926119,-0.0144152724520459,-0.0154998898618779,-0.0165767140128496,-0.0176389573537635,-0.0186797802015384,-0.0196923521114581,-0.0206699140484295,-0.0216058406841253,-0.0224937021371060,-0.0233273244735874,-0.0241008482954571,-0.0248087847594074,-0.0254460683964350,-0.0260081061342215,-0.0264908219656081,-0.0268906967540876,-0.0272048027213095,-0.0274308322214307,-0.0275671204719312,0.970517168591237,-0.0275671204719312,-0.0274308322214307,-0.0272048027213095,-0.0268906967540876,-0.0264908219656081,-0.0260081061342215,-0.0254460683964350,-0.0248087847594074,-0.0241008482954571,-0.0233273244735874,-0.0224937021371060,-0.0216058406841253,-0.0206699140484295,-0.0196923521114581,-0.0186797802015384,-0.0176389573537635,-0.0165767140128496,-0.0154998898618779,-0.0144152724520459,-0.0133295372926119,-0.0122491900363413,-0.0111805113643439,-0.0101295051356671,-0.00910185032195487,-0.00810285719649952,-0.00713742819085010,-0.00621002377151572,-0.00532463362508756,-0.00448475337312145,-0.00369336696928961,-0.00295293486151299,-0.00226538793195701,-0.00163212715878514,-0.00105402887633324,-0.000531455445700654,-6.42710864917189e-05,0.000348137436695825,0.000706835631748383,0.00101331200607814,0.00126944514974097,0.00147746765566453,0.00163992738577175,0.00175964661254210,0.00183967957912628];

while true
    x = step(deviceReader); % Obtendo os blocos do sinal de entrada
    
    signal = conv(x, coef');
    
    % Configurações para plotagem.
    fm = 20000; % Frequencia máxima de exibição.
    plot_title = 'Espectro do Sinal de Entrada';
    x_label = '$f$(Hz)';
    y_label = '$|X(e^{j2\pi f})|_{dB}$';

    % Realização da FFT e normalização.
    fft_signal = fft(signal);
    fft_length = length(fft_signal);
    fft_signal = abs(fft_signal)/fft_length;
    f0 = Fs/fft_length;
    f0max = (fft_length - 1)*f0;
    f = 0:f0:f0max;

    % Correção do sinal de frequência.
    metade = fft_length/2;
    fp = f(1:metade);
    fft_signal_positive = fft_signal(1:metade);
    fn = f(metade+1:fft_length) - f0max - f0;
    fft_signal_negative = fft_signal(metade+1:fft_length);
    ft = [fn, fp];
    fft_signal_total = [fft_signal_negative', fft_signal_positive'];
    fft_signal_total = fft_signal_total';
    
    % Colocando o eixo x em dB.
    y_db = 20*log(fft_signal_total);
    
    % Exibição do espectro do sinal de entrada.
    plot(ft, y_db); grid on;
    xlim([-fm fm])
    ylim([-400 -100])
    title(plot_title);
    hTitle = get(gca, 'title');
    set(hTitle, 'FontSize', 48, 'FontWeight', 'bold')
    xlabel(x_label, 'interpreter', 'latex','FontSize', 24);
    ylabel(y_label, 'interpreter', 'latex','FontSize', 24);
    drawnow
    
    % Reprodução do áudio.
%     step(Out, signal);
end
    