% sound test

amp=1; 
fs=20500;  % sampling frequency
duration=2;
freq=300;
values=0:1/fs:duration;
a=amp*sin(2*pi* freq*values)';
%a(round(size(a,1)/2):end) = 0;
%a(:,2) = amp*sin(2*pi* freq*values);
%a(1:round(size(a,1)/2),2) = 0;
sound(a,fs);
