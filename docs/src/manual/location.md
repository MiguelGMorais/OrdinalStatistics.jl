# Location: mean charge, centrum and index

```@meta
CurrentModule = OrdinalStatistics
```

Without a unit of measurement the mean is meaningless, and the median can be ambiguous:
for ``f = (0.5, 0, 0, 0, 0.5)`` every inner category splits the mass in half. Peñaloza
proposes three related location measures, all computed from the frequencies alone.

| Measure | Type | Range | Function |
|:--|:--|:--|:--|
| mean charge ``\bar S`` | numerical | ``[1/m,\ 1]`` | [`mean_charge`](@ref) |
| centrum ``\mathcal{E}_\prec`` | categorical | one category or two consecutive ones | [`centrum`](@ref) |
| index ``\mathcal{I}`` | numerical | ``[0,\ 100]`` | [`ordinal_index`](@ref) |

## Mean charge

The **post-cumulated frequency** (distributional charge) of category ``x_j`` is
``S_j = \sum_{k \ge j} f_k``, the share of the distribution that did not fall below
``x_j``. The **mean charge** is their average:

```math
\bar S = \frac{1}{m}\sum_{j=1}^m S_j = \sum_{j=1}^m \frac{j}{m}\, f_j .
```

```@example loc
using OrdinalStatistics
f = [5, 5, 50, 60, 80]        # 200 voters rating a candidate's competence
mean_charge(f)
```

## Centrum

The **centrum** is the category nearest to ``m \bar S``. Here ``5 \bar S = 4.025``, so the
centrum is the 4th category:

```@example loc
centrum(f)
```

It is returned as a range: `c:c` for one central category, `c:c+1` when ``m \bar S`` lies
exactly half-way between two integers.

```@example loc
centrum([0.5, 0, 0, 0, 0.5]), centrum([0.5, 0, 0, 0.5])
```

Unlike the median, the centrum of ``(0.5, 0, 0, 0, 0.5)`` is unambiguous (the middle
category), and unlike the mode it uses the whole distribution.

## Index

The **index** rescales the mean charge linearly to ``[0, 100]``:

```math
\mathcal{I} = 100\,\frac{\bar S - 1/m}{1 - 1/m} = 100 \sum_{j=1}^m \frac{j-1}{m-1}\, f_j .
```

```@example loc
ordinal_index(f)
```

### Index and centrum agree

The thresholds ``t_h = \frac{100}{m-1}\left(h - \tfrac12\right)`` partition ``[0, 100]``
into ``m`` cells, one per category. The index falls inside the cell of the centrum, and
exactly on a threshold when the centrum is a pair.

```@example loc
index_thresholds(5)
```

The voters' index (75.5) lies in ``(62.5, 87.5)``, the 4th cell — the centrum found above.

| ``m`` | thresholds on ``[0, 100]`` |
|:--|:--|
| 3 | 25; 75 |
| 4 | 16.67; 50; 83.33 |
| 5 | 12.5; 37.5; 62.5; 87.5 |
| 7 | 8.33; 25; 41.67; 58.33; 75; 91.67 |

The end cells are half as long as the inner ones: the partition is derived from the
index, not imposed *a priori*.

## Reference

```@docs
mean_charge
centrum
ordinal_index
index_thresholds
```
