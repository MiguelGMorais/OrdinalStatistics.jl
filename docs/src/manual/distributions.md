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
