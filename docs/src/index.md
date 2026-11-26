```@meta
CurrentModule = OrdinalStatistics
```

# OrdinalStatistics.jl

*Location, variability, inequality and poverty measures for ordinal and categorical
variables.*

Ordinal data — Likert items, satisfaction surveys, rights and freedom scores, rating
scales — have an order but no unit of measurement. Means, variances and the usual
inequality indices are not meaningful on them. This package implements the measures that
**are** meaningful for ordinal data, as systematized by **R. Peñaloza** and **J. Souza**:
the *mean charge*, the *centrum*, the *index*, ordinal variability, Theil's *dual* and
*codual* for ordinal variables, and the *c-index*, a composite index with endogenous
weights.

## Installation

The package is not registered yet. Install it from GitHub:

```julia
using Pkg
Pkg.add(url = "https://github.com/MiguelGMorais/OrdinalStatistics.jl")
```

Julia 1.10 or later is required.

## Quick start

```@example home
using OrdinalStatistics

# 48 developing countries, political rights in 1979 (worst → best, 7 categories)
political = [7, 13, 13, 5, 8, 2, 0]

d = OrdinalDistribution(political)
```

```@example home
ordinal_index(d)    # numerical location on [0, 100]
```

```@example home
centrum(d)          # categorical location: the 3rd category
```

```@example home
codual(d)           # weight of the "upper" category of the dual dichotomy
```

Aggregate several ordinal questions into one composite index:

```@example home
civil = [11, 12, 17, 3, 1, 4, 0]
cindex([political, civil])    # democratic development index
```

## Conventions

!!! note "Categories are ordered from worst to best"
    Every frequency vector lists the categories in increasing order,
    ``x_1 \prec x_2 \prec \dots \prec x_m``: the first entry is the **worst** (or lowest
    intensity) category and the last is the **best**. Reverse scales that run the other way
    before using them, e.g. with `reverse(counts)`.

- Frequencies may be **absolute** (counts) or **relative** (proportions); they are
  normalized internally.
- Raw answers, one per respondent, are converted with [`fromresponses`](@ref).
- Every measure accepts either an [`OrdinalDistribution`](@ref) or a plain vector.

## Contents

```@contents
Pages = [
    "getting_started.md",
    "manual/distributions.md",
    "manual/location.md",
    "manual/variability.md",
    "manual/duality.md",
    "manual/cindex.md",
    "references.md",
    "api.md",
]
Depth = 1
```

## Sources

The definitions, notation and numerical examples follow the course notes *Pobreza e
Desigualdade* (Poverty and Inequality, Universidade de Brasília), based on the works of
R. Peñaloza and J. Souza listed in the [References](@ref). Every function's docstring
states its formula and source.
