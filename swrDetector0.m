function swr = swrDetector0(detector)
%SWRDETECTOR0 Primitive sharp-wave ripple detector algorithm, used for
%comparisons
%   Input is detector object with a full buffer, the output will be based
%   on the algorithms here, and should be implementable on hardware
%   eventually (Though the hardware imp. won't be developed here)
    signal = detector.running_zscr;
    bp_sig = bandpass(signal, [100, 300], detector.fs);
    sd= std(bp_sig);

    swr = detector.buffer(end) > sd;
end