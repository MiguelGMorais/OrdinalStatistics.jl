module OrdinalStatisticsCategoricalArraysExt

using OrdinalStatistics
using CategoricalArrays: CategoricalArray, isordered, levelcode, levels

# Loaded automatically when both OrdinalStatistics and CategoricalArrays are in use.
# The order of the levels defines the categories x₁ ≺ … ≺ x_m; unused levels are kept,
# so m = number of levels.

function _check_ordered(x::CategoricalArray)
    isordered(x) || throw(ArgumentError(
        "the CategoricalArray is not ordered; an ordinal variable needs ordered levels " *
        "(worst to best). Declare them with `categorical(x; levels = [...], ordered = true)` " *
        "or `ordered!(x, true)` after checking `levels(x)`."))
    return nothing
end

function OrdinalStatistics.fromresponses(x::CategoricalArray)
    _check_ordered(x)
    any(ismissing, x) && throw(ArgumentError(
        "the responses contain missing values; drop them explicitly with " *
        "`fromresponses(skipmissing(x))`"))
    return fromresponses((levelcode(v) for v in x), length(levels(x)))
end

function OrdinalStatistics.fromresponses(s::Base.SkipMissing{<:CategoricalArray})
    x = s.x
    _check_ordered(x)
    return fromresponses((levelcode(v) for v in s), length(levels(x)))
end

end
