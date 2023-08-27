%System siumlator, here is to evaluate the maximum buffer consumption, set
%write-in rate as one loop for once transmission
%% Initialization varibles
%rowmatrix=       should load 'rowmatrix', recording compressed row for one row
maxbuffer1 = 0;   %Record maximum buffer requirement for buffer1
maxbuffer2 = 0;   %Record maximum buffer requirement for buffer2
buffer1 = 0;      %Record current buffer requirement for buffer1
buffer2 = 0;      %Record current buffer requirement for buffer2
waiting_area = NaN(1,10253); %waiting area to transmit data in buffer 2
waiting_area_index = 0;   %Index of the value in waiting area   
rate = 8;      %setting sampling rate
rate2 = 8;     %setting read-out rate
com=lcm(rate2,rate); %find least common multiple to reduce program burden
t = 0;     %set system time
len_rowmatrix = length(rowmatrix);
number_index = 1;
%% Main program
while number_index < len_rowmatrix||waiting_area(1) > 0
    if mod(t, rate) == 0  %sampling process
        if number_index <= len_rowmatrix
            number = rowmatrix(number_index); %put number of compressed row in waitting area
            waiting_area_index = waiting_area_index + 1;
            waiting_area(waiting_area_index) = number;
            buffer1 = buffer1 + 1;    %increase the buffer 1 requirement
            number_index = number_index + 1;
        end
    end
    if ~isempty(waiting_area) && ~isnan(waiting_area(1))&& waiting_area(1) >= 0
        % write-in process
        waiting_area(1) = waiting_area(1) - 1; %transmit one row in buffer2
        if waiting_area(1) >= 0
            buffer2 = buffer2 + 1;   %increase the buffer 2 requirement
        end
        if buffer2 > maxbuffer2
            maxbuffer2 = buffer2;
        end
        if waiting_area(1) <= 0   %if one row in buffer1 has been written in buffer 2
            waiting_area(1:waiting_area_index-1) = waiting_area(2:waiting_area_index);
            waiting_area(waiting_area_index) = NaN; % Set the last position to NaN
            waiting_area_index = waiting_area_index - 1;
            buffer1 = buffer1 - 1; %decrease the buffer 1 requirement
            if buffer1 < 0
                buffer1 = 0;
            end
        end
    end
    if mod(t, rate2) == 0  %read-out process
        buffer2 = buffer2 - 1; %decrease the buffer 2 requirement
        if buffer2 < 0
            buffer2 = 0;
        end
    end
    t = t + 1; %incease system time
    if t==com  %reduce system burden
        t=0;
    end
end
