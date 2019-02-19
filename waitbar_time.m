function []=waitbar_time(duration,message)
a=0;
w = waitbar(0,message);
while a <= duration
    pause(2)
    a = a + 2;
    waitbar(a/duration,w)
end
close(w)