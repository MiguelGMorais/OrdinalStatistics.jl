# The c-index

```@meta
CurrentModule = OrdinalStatistics
```

Many constructs — education, democracy, human development, business sentiment, hospital
quality — have several facets, each measured by one ordinal question. The **c-index**
(composite index) aggregates the questions' [indices](location.md) with **endogenous
weights** given by the [codual](duality.md) (Peñaloza 2012a; Peñaloza & Macedo 2012).

## Definition

For a questionnaire ``\mathcal{Q} = \{X_1, \dots, X_n\}``:

```math
w_q = \frac{\langle\upsilon^2_q\rangle^c}{\sum_{k=1}^n \langle\upsilon^2_k\rangle^c},
\qquad
\Gamma(\mathcal{Q}) = \sum_{q=1}^n w_q\, \mathcal{I}_q .
```

A question whose answers concentrate in the upper categories has a high codual and
therefore a high weight: the weighting **rewards performance**. Questions may have
different numbers of categories, because duality reduces each of them to the same
lower/upper dichotomy.

## Example: democratic development

Political and civil rights in 48 developing countries in 1979, both on 7-point scales
(Peñaloza & Macedo 2012):

```@example ci
using OrdinalStatistics
political = [7, 13, 13, 5, 8, 2, 0]
civil     = [11, 12, 17, 3, 1, 4, 0]
democracy = [political, civil]

ordinal_index.(democracy)
```

```@example ci
endogenous_weights(democracy)
```

```@example ci
cindex(democracy)
```

## Contribution of a question

The **contribution** of question ``q`` is the change in the c-index caused by including it,
``\Delta_q\Gamma = \Gamma - \Gamma_{-q}``, where ``\Gamma_{-q}`` is the c-index recomputed
without ``q``. It has the closed form

```math
\Delta_q\Gamma = \frac{w_q}{1 - w_q}\left(\mathcal{I}_q - \Gamma\right).
```

For a question with positive weight (``0 < w_q < 1``), the contribution is positive if and
only if its index exceeds the c-index, and its magnitude grows with the weight. A question
with zero weight has zero contribution.

```@example ci
contribution(democracy)
```

!!! note "When a contribution is `NaN`"
    If a single question carries all the weight (``w_q = 1``), removing it leaves no
    positive weight, and its contribution is `NaN`.

## Ambiguous coduals

If a question's codual is ambiguous (see [Ambiguous cases](@ref)), so is the c-index. The
`ambiguous` keyword is forwarded to [`codual`](@ref):

```@example ci
retail = [fill(0.25, 4), [0, 1, 0, 0], [0, 0, 1, 0], [0.5, 0, 0, 0.5],
          [0, 0.2, 0.8, 0], [0, 0, 0.8, 0.2], [0.2, 0, 0.8, 0], [0.1, 0.1, 0.8, 0]]
cindex(retail; ambiguous = :lower), cindex(retail; ambiguous = :upper)
```

Reporting both values makes the ambiguity explicit.

## Reference

```@docs
endogenous_weights
cindex
contribution
```
