function out = dataInterp(inputStream, fs, newFs, saveFileName)
% DATAINTERP This function interpolates the LFP signal to a new sampling rate
    dataStream = resample(inputStream, fs, newFs);
    audiowrite(saveFileName, dataStream, fs);
    clear dataStream
end

