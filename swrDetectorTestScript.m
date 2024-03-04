% Script for testing SWRs, calls all of the functions needed for testing purposes
%% Load in data for testing
swrChannel = openTFiles('Data/t1.mat', [1 10]);
plot(swrChannel.t, swrChannel.v);