# The ordinal dual and codual

```@meta
CurrentModule = OrdinalStatistics
```

Theil's **duality** summarizes the dispersion of a long series by a dichotomy with the
same dispersion. For an ordinal variable, the dual series has a **lower** category
``y_1`` and an **upper** category ``y_2``, ``y_1 \prec y_2``, with weights
``(\langle\upsilon^2\rangle, \langle\upsilon^2\rangle^c)`` summing to one:

- the **dual** ``\langle\upsilon^2\rangle`` is the weight of the lower category ("off track");
- the **codual** ``\langle\upsilon^2\rangle^c`` is the weight of the upper category ("on track").

## Step 1 — isovariability: the fundamental equation

The dual series must have the same Gini–Simpson variability ``\upsilon^2`` as the original
one. For a dichotomy with weights ``(d, 1-d)``, ``\upsilon^2 = 4d(1-d)``, so ``d`` solves the
**fundamental equation of duality**

```math
d^2 - d + \frac{\upsilon^2}{4} = 0,
\qquad
d_\pm = \frac{1 \pm \sqrt{1 - \upsilon^2}}{2}.
```

The two roots sum to one. The question is which one goes to the lower category.

## Step 2 — isotonia: assigning the roots

Let ``x_c`` be the [centrum](location.md). Compare the mass **weakly below** it,
``\sum_{j \le c} f_j``, with the mass **weakly above** it, ``\sum_{j \ge c} f_j``:

| Situation | Dual | Codual |
|:--|:--|:--|
| more mass below the centrum | ``d_+`` | ``d_-`` |
| more mass above the centrum | ``d_-`` | ``d_+`` |
| tie, more categories above (``m - c + 1 > c``) | ``d_+`` | ``d_-`` |
| tie, more categories below (``c > m - c + 1``) | ``d_-`` | ``d_+`` |
| tie in both | ambiguous | ambiguous |

When the centrum is a pair ``\{x_c, x_{c+1}\}``, the masses compared are
``\sum_{j \le c} f_j`` and ``\sum_{j \ge c+1} f_j``, and the category counts ``c`` and
``m - c``.

### Example

```@example dual
using OrdinalStatistics
f = [0.1, 0.5, 0.1, 0.2, 0.1]
gini_simpson(f), centrum(f)
```

The roots are 0.3064 and 0.6936. The mass below the centrum, 0.7, exceeds the mass above
it, 0.4, so the larger root goes to the lower category:

```@example dual
dual(f), codual(f)
```

Reduced to "low" and "high" freedom, about 31 % of the population is in the upper
category.

### Concentrated distributions

If all answers fall in one category, ``\upsilon^2 = 0`` and the roots are 0 and 1. The
masses tie, so the number of categories decides:

```@example dual
codual([0, 0, 0, 1, 0]), codual([0, 1, 0, 0, 0])
```

## Ambiguous cases

For ``f = (\tfrac12, 0, 0, \tfrac12)`` the centrum is the pair ``\{x_2, x_3\}`` and both
the masses and the category counts tie: the isotonia rule cannot decide. By default this
throws an [`AmbiguousDualError`](@ref):

```@example dual
q4 = [0.5, 0, 0, 0.5]
try
    codual(q4)
catch err
    err
end
```

Choose a root explicitly with the `ambiguous` keyword:

```@example dual
codual(q4; ambiguous = :lower), codual(q4; ambiguous = :upper)
```

- `ambiguous = :lower` — the codual is the **smaller** root;
- `ambiguous = :upper` — the codual is the **larger** root.

The uniform distribution is not ambiguous in practice: both roots equal ``\tfrac12``.

## Numerical tolerance

Ties (the centrum at exactly ``\tfrac12``, equal masses) are decided up to a tolerance
`atol`, by default ``\sqrt{\varepsilon}`` of the floating-point type (about
``1.5 \times 10^{-8}`` for `Float64`). This prevents rounding errors in frequencies such as
``1/3`` from breaking a genuine tie. Pass `atol` explicitly to change it.

## Robustness

The roots have derivative ``|d_\pm'(\upsilon^2)| = \frac{1}{4\sqrt{1-\upsilon^2}}``, which
exceeds 1 only when ``\upsilon^2 > 15/16``, i.e. near the uniform distribution. In that
region small changes in the frequencies produce larger changes in the dual.

## Reference

```@docs
dual
codual
AmbiguousDualError
```
