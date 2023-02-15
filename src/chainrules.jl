function ChainRulesCore.frule((_, Δalm, _), ::typeof(alm2map), alm, nside::Integer)
    #TODO added, intentionally, no signature to alm
    y = alm2map(alm, nside)
    Δy = alm2map(Δalm, nside)
    return y, Δy
end

function ChainRulesCore.rrule(::typeof(alm2map), x, nside::Integer)
    y = alm2map(x, nside)
    project_x = ChainRulesCore.ProjectTo(x)
    function alm2map_pullback(ȳ)
        x̄ = project_x(adjoint_alm2map(ChainRulesCore.unthunk(ȳ), nside))
        return ChainRulesCore.NoTangent(), x̄, ChainRulesCore.NoTangent()
    end
    return y, alm2map_pullback
end
