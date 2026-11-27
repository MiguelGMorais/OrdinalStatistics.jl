# Ordinal distributions

```@meta
CurrentModule = OrdinalStatistics
```

An **ordinal variable** ``(X, \prec)`` is a question whose possible answers form a finite
list of categories ordered from the worst to the best,
``x_1 \prec x_2 \prec \dots \prec x_m``. An **observation** of ``X`` is a vector of
relative frequencies ``f \in \Delta^{m-1}``, written ``(X, \prec, m, f)``. The package
represents it with [`OrdinalDistribution`](@ref).

## Building a distribution

From **absolute frequencies** (counts). The number of observations is kept:

```@example dist
using OrdinalStatistics
d = OrdinalDistribution([5, 5, 50, 60, 80])   # 200 voters rating a candidate
```

```@example dist
ncategories(d), nobs(d)
```

From **relative frequencies**:

```@example dist
OrdinalDistribution([0.1, 0.5, 0.1, 0.2, 0.1])
```

From **raw answers**, one per respondent, coded ``1, \dots, m``:

```@example dist
fromresponses([3, 4, 4, 5, 2, 4], 5)
```

!!! tip "Plain vectors work too"
    You rarely need to build an `OrdinalDistribution` explicitly: every measure also
    accepts a frequency vector, e.g. `ordinal_index([5, 5, 50, 60, 80])`. Building it once
    is useful when you compute many measures on the same data.

## Labelled answers with CategoricalArrays

Survey data often arrive as labels ("low", "high", …) rather than codes. If you use
[CategoricalArrays.jl](https://github.com/JuliaData/CategoricalArrays.jl), pass an
**ordered** `CategoricalArray` directly. The order of its levels defines the categories,
so declare them from worst to best:

```@example dist
using CategoricalArrays

scale = ["none", "low", "some", "high", "full"]
answers = categorical(["high", "full", "full", "none", "high", "full", "some", "full"];
                      levels = scale, ordered = true)

d = fromresponses(answers)
```

Levels nobody chose ("low" here) still count, so ``m`` is always the number of levels:

```@example dist
ncategories(d), ordinal_index(d)
```

!!! warning "The array must be ordered"
    An unordered `CategoricalArray` sorts its levels alphabetically ("full" ≺ "high" ≺
    "low" ≺ …), which is meaningless as an ordinal scale. `fromresponses` therefore rejects
    it with an `ArgumentError`. Missing answers are treated as with plain vectors: use
    `fromresponses(skipmissing(answers))` to drop them explicitly.

This support is provided by a package extension: OrdinalStatistics itself does not depend
on CategoricalArrays, and the method becomes available only when both packages are loaded.

## Validation

The constructor rejects data that cannot be a frequency distribution: fewer than two
categories, negative or non-finite entries, or all-zero vectors.

```@example dist
try
    OrdinalDistribution([0.5, -0.1, 0.6])
catch err
    err
end
```

## Reference

```@docs
OrdinalDistribution
fromresponses
frequencies
ncategories
nobs
```
