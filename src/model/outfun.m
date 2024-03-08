function stop = outfun(x, optimValues, state)
    stop = false;
    global errorHistory
    errorHistory(end+1) = optimValues.fval;
end
