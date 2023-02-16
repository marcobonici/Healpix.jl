function ChainRulesCore.frule((_, Δalm, _), ::typeof(alm2map), alm, nside::Integer)
    #TODO added, intentionally, no signature to alm
    y = alm2map(alm, nside)
    Δy = alm2map(Δalm, nside)
    return y, Δy
end

function ChainRulesCore.rrule(::typeof(alm2map), alm, nside::Integer)
    y = alm2map(alm, nside)
    @info "Pippo!!"

    project_x = ChainRulesCore.ProjectTo(alm)
    function alm2map_pullback(ȳ)
        alm_back = project_x(adjoint_alm2map(ChainRulesCore.unthunk(ȳ), alm.lmax, alm.mmax))
        return ChainRulesCore.NoTangent(), alm_back, ChainRulesCore.NoTangent()
    end
    return y, alm2map_pullback
end

function ChainRulesCore.rrule(::typeof(sum), map::HealpixMap{T,O,AA}) where{T, O <:Order, AA<:AbstractArray{T,1}}
    y = sum(map)
    @info "Pippo!"
    function sum_pullback(ȳ)
        return ChainRulesCore.NoTangent(), HealpixMap{T,O,AA}(fill!(similar(map.pixels), ȳ))
    end
    return y, sum_pullback
end

@adjoint function Base.sum(map::HealpixMap{T,O,AA}) where{T, O <:Order, AA<:AbstractArray{T,1}}
    y = sum(map)
    @info "Pippo!!!"
    function sum_pullback(ȳ)
        return (HealpixMap{T,O,AA}(fill!(similar(map.pixels), ȳ)),)
    end
    return y, sum_pullback
end

@adjoint function Alm{T,AA}(lmax, mmax, arr::AA) where {T <: Number,AA <: AbstractArray{T,1}}
    (numberOfAlms(lmax, mmax) == length(arr)) || throw(DomainError())
    y = Alm{T,AA}(lmax, mmax, arr::AA)
    function Alm_pullback(ȳ)
        return (nothing, nothing, ȳ.alm)
    end
    return y, Alm_pullback
end
