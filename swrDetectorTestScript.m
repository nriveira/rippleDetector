swrFile = open("t1.mat");

%%
fs = 2083.3;
bs = 5;
bl = 10;
sd = 5;
rf = 100;

t = swrFile.vv.t(1:floor(fs*300));
t = t-t(1);
v = swrFile.vv.v(1:floor(fs*300));

zv = zeros(1, length(v));
b = zeros(1, length(v));
swr = zeros(1, length(v));

det = detector(fs, bs, sd, rf, false);

for i = 1:length(v)
    det = det.step(v(i));
    b(i) = det.buffer_status;
    swr(i) = det.swr_status;
end

plot(swr)