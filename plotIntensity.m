function [time,intensity] = plotIntensity(s)
it = strfind(s,'t');
iL = strfind(s,'L');


for i = 1: min(size(it,2),size(iL,2))
    time(i) = sscanf(s(it(i)+1:iL(i)-1),'%f');
    if i < size(it,2)
        intensity(i) = sscanf(s(iL(i)+1:it(i+1)-1),'%f');
    else
        intensity(i) = sscanf(s(iL(i)+1:end),'%f');
    end
end

plot(intensity)
%plot(time,intensity)