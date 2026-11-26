# Getting started

This tutorial walks through a complete analysis: measuring **education** as a
multidimensional construct, following Peñaloza (2012a).

## The data

Education is described by seven basic *functionings* (Terzi, 2007). For each one, people
answer: *"To what extent do you feel free to achieve the benefits you value in this
functioning?"*, on a five-point scale

> no freedom ≺ low ≺ some ≺ high ≺ full freedom.

Each question is an ordinal variable with ``m = 5`` categories. The relative frequencies
of the answers are:

```@example edu
using OrdinalStatistics

functionings = ["literacy", "numeracy", "sociality", "learning",
                "physical", "science", "practical reason"]

education = [
    [0, 0, 0, 1, 0],             # literacy
    [0, 1, 0, 0, 0],             # numeracy
    [0.5, 0, 0.5, 0, 0],         # sociality
    [0.25, 0, 0, 0, 0.75],       # learning
    [0.1, 0.5, 0.1, 0.2, 0.1],   # physical activities
    [0.1, 0.6, 0.3, 0, 0],       # science and technology
    [0.3, 0.5, 0.1, 0.1, 0],     # practical reason
]
nothing # hide
```

## Step 1 — summarize each question

Take *physical activities*. Its **index** places it on ``[0, 100]``, and its **centrum**
names the central category:

```@example edu
physical = OrdinalDistribution(education[5])
ordinal_index(physical), centrum(physical)
```

An index of 42.5 lies in the third cell of the partition of ``[0, 100]`` induced by five
categories, so the centrum is the 3rd category, *some freedom*:

```@example edu
index_thresholds(5)
```

The **Gini–Simpson variability** measures how spread the answers are (0 = consensus,
1 = uniform):

```@example edu
gini_simpson(physical)
```

## Step 2 — the codual

The **codual** reduces the five answers to a dichotomy "low" ≺ "high" with the same
variability, and gives the weight of "high". Here roughly 31 % of the population is
"on track":

```@example edu
codual(physical)
```

## Step 3 — the composite index

The **c-index** averages the questions' indices with **endogenous weights**: each
question's share of the total codual. Questions where people do well weigh more.

```@example edu
w = endogenous_weights(education)
```

```@example edu
cindex(education)
```

## Step 4 — which dimensions pull the index up or down?

The **contribution** ``Δ_q`` is how much the c-index would fall if question ``q`` were
removed. Positive values raise the composite index; negative values lower it.

```@example edu
Δ = contribution(education)
for (name, idx, wq, dq) in zip(functionings, ordinal_index.(education), w, Δ)
    println(rpad(name, 18), "index = ", lpad(round(idx; digits = 1), 5),
            "   weight = ", round(wq; digits = 3),
            "   contribution = ", round(dq; digits = 2))
end
```

*Numeracy*, *sociality* and *practical reason* share the same index (25) and centrum,
but contribute very differently: numeracy has zero weight (everyone is concentrated in a
low category), while practical reason, with a worse distribution, lowers the c-index by
2.63 points.

## Working with raw survey answers

Real surveys come as one answer per respondent. Code the answers as category positions
``1, \dots, m`` and use [`fromresponses`](@ref):

```@example edu
answers = [4, 5, 5, 1, 4, 5, 3, 5]      # 8 respondents, 5-point scale
d = fromresponses(answers, 5)
```

```@example edu
ordinal_index(d), nobs(d)
```

Missing answers raise an error unless you drop them explicitly with `skipmissing`:

```@example edu
fromresponses(skipmissing([4, missing, 5, 2]), 5)
```

## Next steps

- [Ordinal distributions](@ref) — building and inspecting the data.
- [Location: mean charge, centrum and index](@ref) — the location measures in detail.
- [The ordinal dual and codual](@ref) — the isotonia rule and ambiguous cases.
- [The c-index](@ref) — composite indices and contributions.
