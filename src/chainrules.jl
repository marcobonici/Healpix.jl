function ChainRulesCore.frule((_, Δalm, _), ::typeof(alm2map), alm, nside::Integer)
    y = alm2map(alm, nside)
    Δy = alm2map(Δalm, nside)
    return y, Δy
end
