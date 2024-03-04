function swr = openTFiles(fileName,selectedIndex)
%OPENTFILES Open t file and return the selectedSignal
    swrFile = open(fileName);
    swr.fs = 1000/(swrFile.vv.t(2)-swrFile.vv.t(1));
    swr.t = swrFile.vv.t(floor(selectedIndex(1)*swr.fs):floor(selectedIndex(2)*swr.fs));
    swr.v = swrFile.vv.v(floor(selectedIndex(1)*swr.fs):floor(selectedIndex(2)*swr.fs));
end