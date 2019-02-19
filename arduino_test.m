% --- Open serial connection
s = serial('COM3'); 		% Replace with your actual serial port
set(s,'BaudRate', 115200);
fopen(s);
fprintf('The serial connection is established.\n');

% --- Display client commands
fprintf('%s\n', repmat('-', [1 50]));
fprintf('   BASIC SERIAL CLIENT\n\n');
fprintf('Possible commands:\n');
fprintf('\t- info:      Get information from the device.\n');
fprintf('\t- start:     Start LED blinking.\n');
fprintf('\t- stop:      Stop LED blinking.\n');
fprintf('\t- period p:  Change period (milliseconds).\n');
fprintf('%s\n\n', repmat('-', [1 50]));
fprintf('Enter the serial commands below ([Enter] to exit):\n');

while true
    in = input('?> ', 's');
    % Break condition
    if isempty(in), break; end
       
    % Send command
    fprintf(s, in);

    % Receive message
    while true
        fprintf('%s\n', strtrim(fscanf(s)));
        if ~s.BytesAvailable, break; end
    end
    
end
    
% --- Close the serial connection
fclose(s)
delete(s)
clear s

fprintf('The serial connection is closed.\n');