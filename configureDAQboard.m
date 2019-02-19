% Configure DAQ board &
% test filter shutter
% for 2P microscope stimulation with trigger

s1 = daq.createSession('ni');
s2 = daq.createSession('ni');
ch = addCounterInputChannel(s1,'Dev3', 'ctr0', 'EdgeCount');
di = addDigitalChannel(s2,'Dev3','Port0/Line0', 'OutputOnly');
resetCounters(s1);
in = inputSingleScan(s1);
if in ~=0
    warning('pb : initial count non null')
    return
end

%test
outputSingleScan(s2,0)
outputSingleScan(s2,1)
disp('filter down')
pause

outputSingleScan(s2,0)
outputSingleScan(s2,1)
disp('filter up again - ok ?')
pause