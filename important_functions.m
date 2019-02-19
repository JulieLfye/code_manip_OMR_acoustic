% Verify frames were acquired.
vid = videoinput('pointgrey', 1, 'F7_Raw8_1280x1024_Mode0');
frameslogged = vid.FramesAcquired;
triggerconfig(vid);
triggerconfig(vid,'hardware','risingEdge','externalTriggerMode15-source2');
vid.FramesPerTrigger = 30;
vid.TriggerRepeat = 1;