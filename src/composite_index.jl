_questionnaire(qs) = [OrdinalDistribution(q) for q in qs]

function _check_questionnaire(qs)
    isempty(qs) && throw(ArgumentError("the questionnaire must contain at least one question"))
    return nothing
end

"""
    endogenous_weights(qs; ambiguous = :error, atol = √eps)

Endogenous weights of a questionnaire `𝒬 = {X₁, …, X_n}` of ordinal questions: each
question's share of the total codual,

```math
w_q = \\frac{\\langle\\upsilon^2_q\\rangle^c}{\\sum_{k=1}^n \\langle\\upsilon^2_k\\rangle^c}.
```

`qs` is a collection of [`OrdinalDistribution`](@ref)s or frequency vectors; questions may
have different numbers of categories. The keywords are forwarded to [`codual`](@ref).
Throws a `DomainError` if every codual is zero.

Source: Peñaloza (2012a); Peñaloza & Macedo (2012).
"""
function endogenous_weights(qs; kw...)
    _check_questionnaire(qs)
    c = [codual(q; kw...) for q in _questionnaire(qs)]
    s = sum(c)
    s > 0 || throw(DomainError(c, "all coduals are zero; the endogenous weights are undefined"))
    return c ./ s
end

"""
    composite_index(qs; ambiguous = :error, atol = √eps)

Composite index (*c-index*) `Γ(𝒬)` of a questionnaire of ordinal questions: the average of
the questions' [`ordinal_index`](@ref)es weighted by their [`endogenous_weights`](@ref),

```math
\\Gamma(\\mathcal{Q}) = \\sum_{q=1}^n w_q\\,\\mathcal{I}_q .
```

The keywords are forwarded to [`codual`](@ref).

Source: Peñaloza (2012a); Peñaloza & Macedo (2012); Peñaloza (2013).

# Examples
```jldoctest
julia> qs = [[7, 13, 13, 5, 8, 2, 0], [11, 12, 17, 3, 1, 4, 0]];  # democracy, 1979

julia> round(composite_index(qs), digits = 2)
30.55
```
"""
function composite_index(qs; kw...)
    ds = _questionnaire(qs)
    w = endogenous_weights(ds; kw...)
    return sum(w .* ordinal_index.(ds))
end

"""
    contributions(qs; ambiguous = :error, atol = √eps)

Contribution `Δ_q Γ = Γ − Γ_{−q}` of each question to the [`composite_index`](@ref), where `Γ_{−q}` is
the c-index without question `q` (weights recomputed):

```math
\\Delta_q\\Gamma = \\frac{w_q}{1 - w_q}\\bigl(\\mathcal{I}_q - \\Gamma\\bigr).
```

It is positive iff the question's index exceeds the c-index, and satisfies
`Σ_q (1 − w_q) Δ_q Γ = 0`. Returns a vector with one entry per question; an entry is `NaN`
when `w_q = 1` (removing the question leaves no positive weight). The keywords are forwarded
to [`codual`](@ref).

Source: Peñaloza (2012a).
"""
function contributions(qs; kw...)
    ds = _questionnaire(qs)
    w = endogenous_weights(ds; kw...)
    idx = ordinal_index.(ds)
    Γ = sum(w .* idx)
    return [wq == 1 ? oftype(Γ, NaN) : wq / (1 - wq) * (iq - Γ) for (wq, iq) in zip(w, idx)]
end
