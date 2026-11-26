# Variability

```@meta
CurrentModule = OrdinalStatistics
```

**Variability** is the tendency of a variable to take a wide spectrum of values. For
categorical data it depends on the frequencies only: it is **minimal** when the
distribution is concentrated in one category and **maximal** when it is uniform. All
measures below are normalized to ``[0, 1]``.

| Measure | Formula | Function |
|:--|:--|:--|
| modal variability ``\upsilon^\infty`` | ``\frac{m}{m-1}\left(1 - \max_j f_j\right)`` | [`modal_variability`](@ref) |
| Gini–Simpson index ``\upsilon^2`` | ``\frac{m}{m-1}\left(1 - \sum_j f_j^2\right)`` | [`gini_simpson`](@ref) |
| Rényi variability ``\upsilon^\theta`` | ``\dfrac{1 - \sum_j f_j^\theta}{1 - m^{1-\theta}}`` | [`renyi_variability`](@ref) |
| normalized entropy ``\varepsilon`` | ``-\frac{1}{\ln m}\sum_j f_j \ln f_j`` | [`normalized_entropy`](@ref) |

## Comparing the measures

Two series with the same modal frequency:

```@example var
using OrdinalStatistics
x = [0.02, 0.10, 0.70, 0.18]
y = [0.01, 0.28, 0.70, 0.01]
modal_variability(x), modal_variability(y)
```

The modal variability cannot tell them apart: it only looks at the most frequent
category. The Gini–Simpson index and the entropy use every frequency:

```@example var
gini_simpson(x), gini_simpson(y)
```

```@example var
normalized_entropy(x), normalized_entropy(y)
```

!!! tip "Which one to use"
    Prefer [`gini_simpson`](@ref). It uses the whole distribution, has a direct
    interpretation — ``1 - \sum_j f_j^2`` is the proportion of pairs of respondents who
    gave **different** answers — and it is the variability behind the
    [dual and codual](duality.md) and the [c-index](cindex.md).

The Rényi family generalizes the Gini–Simpson index (``\theta = 2``):

```@example var
renyi_variability(x, 2) ≈ gini_simpson(x)
```

## Extreme cases

```@example var
concentrated = [0, 0, 1, 0]
uniform = fill(0.25, 4)
gini_simpson(concentrated), gini_simpson(uniform)
```

## Reference

```@docs
modal_variability
gini_simpson
renyi_variability
normalized_entropy
```
