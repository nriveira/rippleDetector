classdef detector
    %DETECTOR Detector Class for SWR Detector
    %   Class that simulates the FPGA components of the ripple detector to
    %   implement the algorithm and analyze compute time
    
    properties
    % PARAMETERS
        fs;                 % Sampling rate
        buffer_size;        % Size of buffer in seconds
        buffer_latency;     % Latency from aqc time to use for buffer, must be larger than buffer_size
        threshold;          % Threshold in SD to reach to be considered SWR
        refractory;         % Refactory period before new swr can be detected

    % VARIABLES
        buffer;             % Buffer of sample values for last X seconds
        buffer_count;       % Binary variable indicating if buffer is filled
        running_mean;       % Running total for mean
        running_stdv;       % Running total for standard dev
        running_zscr;       % Running Z-score 
        buffer_status;      % Status is the buffer
        swr_status;         % SWR detection output
    end
    
    methods
        function det = detector(fs, bs, th, rf, dy)
            %DETECTOR Construct an instance of this class
            det.fs = fs;
            det.buffer_size = bs;
            det.threshold = th;
            det.refractory = rf;
            det.swr_status = 0;
            
            det.buffer = zeros(1, floor(fs*bs));
            det.running_zscr = zeros(1, floor(fs*bs));
            det.buffer_status = 0;
            det.buffer_count = 0;

            if(dy)  
                det.running_mean = 0;
                det.running_stdv = 0;   
            else
                det.running_mean = -1.5e-7;
                det.running_stdv = 1e-4;
            end

            
        end

        function det = step(det, sample)
            det.buffer(1:end-1) = det.buffer(2:end);
            det.buffer(end) = sample;

            if(det.buffer_count < det.buffer_size*det.fs)
                det.buffer_count = det.buffer_count+1;
            else
                det.buffer_status = 1;
                det.running_zscr(1:end-1) = det.running_zscr(2:end); 
                det.running_zscr(end) = (sample-det.running_mean)/det.running_stdv;
                det.swr_status = swrDetector0(det);
            end
        end
        
        function det = step_dynamic(det, sample)
            %STEP What happens during a single sample acquisition
            %   After a sample is acquired, do the following:

            % Start by filling up the buffer
            if(det.buffer_count < det.buffer_latency*det.fs)
                det.buffer_count = det.buffer_count+1;

                % Calculate mean and standard deviation (Running and
                % assuming constant buffer size)
                det.running_mean = (1/(det.buffer_size))*sample;
                det.running_stdv = (1/(det.buffer_size)-1)*((sample-det.running_mean)^2);
            else
            % Once buffer is filled, calculate the running mean and std
                % prev_mean = det.running_mean;
                det.buffer_status = 1;
                det.running_mean = det.running_mean + (1/det.buffer_size)*(det.buffer(det.buffer_last) - det.buffer(det.buffer_first));
                det.running_stdv = det.running_stdv + (1/(det.buffer_size-1))*((det.buffer(det.buffer_last) - det.running_mean)^2 - (det.buffer(det.buffer_first) - prev_mean)^2);

                det.running_zscr = (sample-det.running_mean)/det.running_stdv;
                det.buffer_first = mod(det.buffer_first, det.buffer_latency*det.fs)+1;
            end

            % Push sample onto FIFO buffer
            det.buffer(det.buffer_last) = sample;
            det.buffer_last = mod(det.buffer_last, det.buffer_latency*det.fs)+1;
        end
    end
end
