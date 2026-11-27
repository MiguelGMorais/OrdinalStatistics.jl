"""
    modal_variability(d)

Modal variability `υ^∞ ∈ [0, 1]`:

```math
\\upsilon^\\infty = \\frac{m}{m-1}\\Bigl(1 - \\max_{1\\le j\\le m} f_j\\Bigr).
```

It is `0` iff `f` is concentrated and `1` iff `f` is uniform. It ignores changes outside the
modal category; [`quadratic_variability`](@ref) should usually be preferred.

Source: Souza & Peñaloza (2005), ch. II; Peñaloza (2011).

# Examples
```jldoctest
julia> modal_variability([0.02, 0.10, 0.70, 0.18]) ≈ 0.4
true
```
"""
function modal_variability(d::OrdinalDistribution)
    f = frequencies(d)
    m = length(f)
    return m / (m - 1) * (1 - maximum(f))
end
modal_variability(x::AbstractVector{<:Real}) = modal_variability(OrdinalDistribution(x))

"""
    quadratic_variability(d)

Quadratic variability `υ² ∈ [0, 1]`, the normalized Gini–Simpson index (GSI), also called the
*nominal variance*:

```math
\\upsilon^2 = \\frac{m}{m-1}\\Bigl(1 - \\sum_{j=1}^m f_j^2\\Bigr).
```

It is `0` iff `f` is concentrated and `1` iff `f` is uniform; `1 - Σ fⱼ²` is the proportion of
ordered pairs of objects (with replacement) falling in different categories.

Source: Peñaloza (2011) (*nominal variance*); Peñaloza (2012a) (*Gini–Simpson index*).

# Examples
```jldoctest
julia> round(quadratic_variability([0.02, 0.10, 0.70, 0.18]), digits = 4)
0.6229
```
"""
function quadratic_variability(d::OrdinalDistribution)
    f = frequencies(d)
    m = length(f)
    return m / (m - 1) * (1 - sum(abs2, f))
end
quadratic_variability(x::AbstractVector{<:Real}) = quadratic_variability(OrdinalDistribution(x))

"""
    renyi_variability(d, θ::Real)

Rényi variability of order `θ > 1`, normalized to `[0, 1]`:

```math
\\upsilon^\\theta = \\frac{1 - \\sum_{j=1}^m f_j^\\theta}{1 - m^{1-\\theta}} .
```

It is `0` iff `f` is concentrated and `1` iff `f` is uniform; `θ = 2` gives
[`quadratic_variability`](@ref).

Source: Souza & Peñaloza (2005), ch. II.

# Examples
```jldoctest
julia> d = OrdinalDistribution([0.1, 0.5, 0.1, 0.2, 0.1]);

julia> renyi_variability(d, 2) ≈ quadratic_variability(d)
true
```
"""
function renyi_variability(d::OrdinalDistribution, θ::Real)
    (θ > 1 && isfinite(θ)) || throw(DomainError(θ, "the order θ must be finite and greater than 1"))
    f = frequencies(d)
    m = length(f)
    return (1 - sum(fj^θ for fj in f)) / (1 - float(m)^(1 - θ))
end
renyi_variability(x::AbstractVector{<:Real}, θ::Real) = renyi_variability(OrdinalDistribution(x), θ)

"""
    normalized_entropy(d)

Normalized entropy `ε ∈ [0, 1]`, with the convention `0 ln 0 = 0`:

```math
\\varepsilon = \\frac{E}{\\ln m}, \\qquad E = -\\sum_{j=1}^m f_j \\ln f_j .
```

It is `0` iff `f` is concentrated and `1` iff `f` is uniform.

Source: Souza & Peñaloza (2005), ch. II.

# Examples
```jldoctest
julia> round(normalized_entropy([0.02, 0.10, 0.70, 0.18]), digits = 4)
0.6253
```
"""
function normalized_entropy(d::OrdinalDistribution)
    f = frequencies(d)
    E = -sum(fj > 0 ? fj * log(fj) : zero(fj) for fj in f)
    return E / log(length(f))
end
normalized_entropy(x::AbstractVector{<:Real}) = normalized_entropy(OrdinalDistribution(x))
