% Talkie library
% Copyright 2011 Peter Knight
% This code is released under GPLv2 license.
%
% Emit a parameter as bits

function bitEmit(val,bits,binFile)
    bitpos = 2^(bits-1);
    for b = 1:bits
        if bitand(val,bitpos)
            fprintf('1');
            fprintf(binFile, '1');
        else
            fprintf('0');
            fprintf(binFile, '0');
        end
        val = val*2;
    end
