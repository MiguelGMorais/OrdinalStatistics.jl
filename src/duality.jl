"""
    AmbiguousDualError(d)

Thrown by [`dual`](@ref) and [`codual`](@ref) when the isotonia rule cannot assign the roots
of the fundamental equation to the dual categories: the masses weakly below and above the
centrum tie, and so do the numbers of categories weakly below and above it (e.g.
`f = (½, 0, 0, ½)`). Pass `ambiguous = :lower` or `ambiguous = :upper` to choose explicitly.
"""
struct AmbiguousDualError{D<:OrdinalDistribution} <: Exception
    d::D
end

function Base.showerror(io::IO, e::AmbiguousDualError)
    print(io, "AmbiguousDualError: the isotonia rule does not determine the dual of ", e.d,
          ". Pass `ambiguous = :lower` (codual is the smaller root) or ",
          "`ambiguous = :upper` (codual is the larger root).")
end

# Roots d₋ ≤ d₊ of the fundamental equation d² − d + υ²/4 = 0.
function _fundamental_roots(d::OrdinalDistribution)
    s = sqrt(max(zero(eltype(frequencies(d))), 1 - gini_simpson(d)))
    return (1 - s) / 2, (1 + s) / 2
end

# Isotonia rule. Returns :lower if the lower dual category is the heavier one (dual = d₊),
# :upper if the upper one is (dual = d₋), or :ambiguous.
#
# With centrum c:c′ (c′ = c, or c′ = c + 1 for a pair centrum), compare the mass
# Σ_{j≤c} fⱼ with Σ_{j≥c′} fⱼ; on a tie, compare the number of categories c with m − c′ + 1.
function _isotonia(d::OrdinalDistribution, atol::Real)
    f = frequencies(d)
    m = length(f)
    cr = centrum(d; atol)
    c, c′ = first(cr), last(cr)
    below = sum(@view f[1:c])
    above = sum(@view f[c′:m])
    below > above + atol && return :lower
    above > below + atol && return :upper
    nbelow, nabove = c, m - c′ + 1
    nabove > nbelow && return :lower   # respondents "off track": low position in the spectrum
    nbelow > nabove && return :upper
    return :ambiguous
end

"""
    dual(d; ambiguous = :error, atol = √eps)

Ordinal dual `⟨υ²⟩` of the Gini–Simpson variability: the weight of the **lower** category of
the dual series, a dichotomous series `y₁ ≺ y₂` with weights `(⟨υ²⟩, ⟨υ²⟩ᶜ)` satisfying

1. *isovariability*: the dual series has the same [`gini_simpson`](@ref) variability `υ²` as
   `f`, so `⟨υ²⟩` is a root of the *fundamental equation of duality*
   ```math
   d^2 - d + \\frac{\\upsilon^2}{4} = 0, \\qquad d_\\pm = \\frac{1 \\pm \\sqrt{1-\\upsilon^2}}{2};
   ```
2. *isotonia*: let `x_c` be the centrum (for a pair centrum `{x_c, x_{c+1}}`, use `c` below
   and `c+1` above) and compare the mass weakly below it, `Σ_{j≤c} fⱼ`, with the mass weakly
   above it, `Σ_{j≥c} fⱼ`:
   - if the mass below is larger, `⟨υ²⟩ = d₊`;
   - if the mass above is larger, `⟨υ²⟩ = d₋`;
   - on a tie, compare the numbers of categories weakly below (`c`) and above (`m − c + 1`):
     more categories above (respondents "off track") gives `⟨υ²⟩ = d₊`, more below gives
     `⟨υ²⟩ = d₋`;
   - if these also tie, the dual is ambiguous.

`ambiguous` controls the ambiguous case: `:error` throws an [`AmbiguousDualError`](@ref),
`:lower` takes the smaller root as the codual (dual `d₊`), `:upper` the larger root as the
codual (dual `d₋`). `atol` is the tolerance for the centrum and isotonia ties.

The [`codual`](@ref) is `1 - ⟨υ²⟩`.

Source: Peñaloza (2012a); Peñaloza & Macedo (2012).

# Examples
```jldoctest
julia> round(dual([0.1, 0.5, 0.1, 0.2, 0.1]), digits = 4)
0.6936
```
"""
function dual(d::OrdinalDistribution; ambiguous::Symbol = :error, atol::Real = _default_atol(d))
    ambiguous in (:error, :lower, :upper) ||
        throw(ArgumentError("`ambiguous` must be :error, :lower or :upper, got :$ambiguous"))
    dm, dp = _fundamental_roots(d)
    side = _isotonia(d, atol)
    if side === :ambiguous
        # with υ² = 1 both roots equal ½ and there is nothing to choose
        dp - dm ≤ atol && return dp
        ambiguous === :error && throw(AmbiguousDualError(d))
        side = ambiguous
    end
    return side === :lower ? dp : dm
end
dual(x::AbstractVector{<:Real}; kw...) = dual(OrdinalDistribution(x); kw...)

"""
    codual(d; ambiguous = :error, atol = √eps)

Ordinal codual `⟨υ²⟩ᶜ = 1 - ⟨υ²⟩`: the weight of the **upper** category of the dual series.
Reducing the spectrum of answers to "low" and "high" ("off track" and "on track"), it is the
degree of belief of being "on track". See [`dual`](@ref) for the definition and keywords.

Source: Peñaloza (2012a); Peñaloza & Macedo (2012).

# Examples
```jldoctest
julia> round(codual([0.25, 0, 0, 0, 0.75]), digits = 4)
0.8644

julia> round(codual([0.5, 0, 0, 0.5]; ambiguous = :upper), digits = 4)
0.7887
```
"""
codual(d::OrdinalDistribution; kw...) = 1 - dual(d; kw...)
codual(x::AbstractVector{<:Real}; kw...) = codual(OrdinalDistribution(x); kw...)
