"""
    mean_charge(d)

Mean charge `S̄` (*carga média*; also *mean post-cumulated frequency*):

```math
\\bar S = \\frac{1}{m}\\sum_{j=1}^m S_j = \\sum_{j=1}^m \\frac{j}{m} f_j,
\\qquad S_j = \\sum_{k=j}^m f_k ,
```

where `S_j` is the post-cumulated frequency (distributional charge) of category `xⱼ`.
It satisfies `1/m ≤ S̄ ≤ 1`, and `m·S̄ = k` when `f` is concentrated in `x_k`.

Source: Souza (1977); Souza & Peñaloza (2005), ch. II; Peñaloza (2012a).

# Examples
```jldoctest
julia> mean_charge([0.1, 0.5, 0.1, 0.2, 0.1]) ≈ 0.54
true
```
"""
function mean_charge(d::OrdinalDistribution)
    f = frequencies(d)
    m = length(f)
    return sum(j * f[j] for j in 1:m) / m
end
mean_charge(x::AbstractVector{<:Real}) = mean_charge(OrdinalDistribution(x))

"""
    centrum(d; atol = √eps)

*Centrum* (ordinal expectation) of the observation: the category, or the pair of consecutive
categories, nearest to `m·S̄`. Returned as a range of category positions: `c:c` for a single
central category, `c:c+1` when the fractional part of `m·S̄` equals `½` (within `atol`).

```math
\\mathcal{E}_\\prec(X) = \\{x_c : c \\in \\varsigma(m\\bar S)\\},\\qquad
\\varsigma(y) = \\begin{cases}
\\lfloor y\\rfloor, & y-\\lfloor y\\rfloor < \\tfrac12,\\\\
\\{\\lfloor y\\rfloor, \\lfloor y\\rfloor+1\\}, & y-\\lfloor y\\rfloor = \\tfrac12,\\\\
\\lfloor y\\rfloor+1, & y-\\lfloor y\\rfloor > \\tfrac12.
\\end{cases}
```

Source: Souza & Peñaloza (2005), ch. II; Peñaloza (2012a).

# Examples
```jldoctest
julia> centrum([0.5, 0, 0, 0, 0.5])
3:3

julia> centrum([0.5, 0, 0, 0.5])
2:3
```
"""
function centrum(d::OrdinalDistribution; atol::Real = _default_atol(d))
    y = ncategories(d) * mean_charge(d)
    fl = floor(Int, y)
    r = y - fl
    # handle y within atol of an integer from below (e.g. 2.9999999999)
    if r > 1 - atol
        return (fl + 1):(fl + 1)
    elseif abs(r - 0.5) ≤ atol
        return fl:(fl + 1)
    elseif r < 0.5
        return fl:fl
    else
        return (fl + 1):(fl + 1)
    end
end
centrum(x::AbstractVector{<:Real}; kw...) = centrum(OrdinalDistribution(x); kw...)

"""
    ordinal_index(d)

The *index* `ℐ(X) ∈ [0, 100]` of an ordinal observation, the linear rescaling of the mean
charge to `[0, 100]`:

```math
\\mathcal{I}(X) = 100\\,\\frac{\\bar S - 1/m}{1 - 1/m}
               = 100\\sum_{j=1}^m \\frac{j-1}{m-1} f_j .
```

It equals the *quality index* `ℋ` of Ebserh (2015). The centrum is the category whose cell of
the partition given by [`index_thresholds`](@ref) contains the index.

Source: Peñaloza (2012a); Peñaloza & Macedo (2012).

# Examples
```jldoctest
julia> ordinal_index([0.1, 0.5, 0.1, 0.2, 0.1]) ≈ 42.5
true
```
"""
function ordinal_index(d::OrdinalDistribution)
    f = frequencies(d)
    m = length(f)
    return 100 * sum((j - 1) * f[j] for j in 1:m) / (m - 1)
end
ordinal_index(x::AbstractVector{<:Real}) = ordinal_index(OrdinalDistribution(x))

"""
    index_thresholds(m::Integer)

Thresholds `t₁ < … < t_{m-1}` of the a-posteriori partition of `[0, 100]` induced by an
ordinal variable with `m` categories:

```math
t_h = \\frac{100}{m-1}\\Bigl(h - \\frac12\\Bigr),\\qquad h = 1,\\dots,m-1 .
```

The index lies in `(t_{h-1}, t_h)` iff the centrum is `{x_h}` (with `t₀ = 0`, `t_m = 100`,
end cells closed at `0` and `100`), and equals `t_h` iff the centrum is `{x_h, x_{h+1}}`.
Inner cells have length `100/(m-1)`; the two end cells have half that length.

Source: Peñaloza (2012a); Peñaloza & Macedo (2012).

# Examples
```jldoctest
julia> index_thresholds(5)
4-element Vector{Float64}:
 12.5
 37.5
 62.5
 87.5
```
"""
function index_thresholds(m::Integer)
    m ≥ 2 || throw(ArgumentError("an ordinal variable needs at least 2 categories, got $m"))
    return [100 * (h - 0.5) / (m - 1) for h in 1:(m - 1)]
end
