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
    fromresponses(answers, m::Integer)

Build an [`OrdinalDistribution`](@ref) from raw responses, one per respondent, coded as
category positions `1, …, m` (`1` the worst category, `m` the best). The absolute frequency
of category `xⱼ` is `nⱼ = #{i : answersᵢ = j}`, and [`nobs`](@ref) is the number of responses.

`answers` may be any iterable of integers. Missing values are not dropped silently: pass
`skipmissing(answers)` to discard them explicitly. Categories with no responses get
frequency zero.

# Examples
```jldoctest
julia> d = fromresponses([4, 5, 5, 1, 4, 5, 3, 5], 5)
OrdinalDistribution([0.125, 0.0, 0.125, 0.25, 0.5]; n = 8)

julia> fromresponses(skipmissing([2, missing, 3]), 3) |> nobs
2
```
"""
function fromresponses(answers, m::Integer)
    m ≥ 2 || throw(ArgumentError("an ordinal variable needs at least 2 categories, got $m"))
    counts = zeros(Int, m)
    for a in answers
        a isa Integer ||
            throw(ArgumentError("responses must be integer category positions, got $(repr(a))"))
        1 ≤ a ≤ m || throw(ArgumentError("response $a is outside the categories 1:$m"))
        counts[a] += 1
    end
    sum(counts) > 0 || throw(ArgumentError("there are no responses"))
    return OrdinalDistribution(counts)
end

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
