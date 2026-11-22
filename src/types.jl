"""
    OrdinalDistribution(x::AbstractVector{<:Real})

An observation `(X, ≺, m, f)` of an ordinal variable: relative frequencies
`f ∈ Δ^{m-1}` over `m ≥ 2` categories `x₁ ≺ x₂ ≺ … ≺ x_m`, ordered from the **worst**
(or lowest intensity) to the **best** (or highest intensity).

`x` may hold absolute or relative frequencies; it is normalized to sum to one. Entries must
be finite, non-negative and not all zero. If `x` has an integer element type, it is read as
absolute frequencies and the number of observations `n = Σ xⱼ` is stored (see [`nobs`](@ref)).

Every measure in this package accepts either an `OrdinalDistribution` or a plain frequency
vector.

# Examples
```jldoctest
julia> d = OrdinalDistribution([7, 13, 13, 5, 8, 2, 0]);

julia> ncategories(d), nobs(d)
(7, 48)
```

Source: Souza & Peñaloza (2005), ch. II; Peñaloza (2012a).
"""
struct OrdinalDistribution{T<:AbstractFloat}
    freqs::Vector{T}
    nobs::Union{Int,Nothing}

    function OrdinalDistribution{T}(x::AbstractVector{<:Real}, n::Union{Int,Nothing}) where {T<:AbstractFloat}
        m = length(x)
        m ≥ 2 || throw(ArgumentError("an ordinal variable needs at least 2 categories, got $m"))
        all(isfinite, x) || throw(ArgumentError("frequencies must be finite"))
        all(≥(0), x) || throw(ArgumentError("frequencies must be non-negative"))
        s = sum(x)
        s > 0 || throw(ArgumentError("frequencies must not all be zero"))
        return new{T}(T[xi / s for xi in x], n)
    end
end

function OrdinalDistribution(x::AbstractVector{<:Integer})
    T = float(eltype(x)) <: AbstractFloat ? float(eltype(x)) : Float64
    return OrdinalDistribution{T}(x, Int(sum(x)))
end
OrdinalDistribution(x::AbstractVector{<:Real}) = OrdinalDistribution{float(eltype(x))}(x, nothing)
OrdinalDistribution(d::OrdinalDistribution) = d

"""
    frequencies(d::OrdinalDistribution)

Relative frequencies `(f₁, …, f_m)`, ordered from the worst to the best category.
"""
frequencies(d::OrdinalDistribution) = d.freqs

"""
    ncategories(d::OrdinalDistribution)

Number of categories `m`.
"""
ncategories(d::OrdinalDistribution) = length(d.freqs)

"""
    nobs(d::OrdinalDistribution)

Number of observations `n`, or `nothing` if `d` was built from relative frequencies.
"""
nobs(d::OrdinalDistribution) = d.nobs

Base.:(==)(a::OrdinalDistribution, b::OrdinalDistribution) = a.freqs == b.freqs && a.nobs == b.nobs

function Base.show(io::IO, d::OrdinalDistribution)
    print(io, "OrdinalDistribution(", d.freqs)
    d.nobs === nothing || print(io, "; n = ", d.nobs)
    print(io, ")")
end

# Default tolerance for tie decisions (centrum at exactly ½, isotonia ties).
_default_atol(::OrdinalDistribution{T}) where {T} = sqrt(eps(T))
