"""
    OrdinalStatistics

Location, variability, association, inequality and poverty measures for ordinal and
categorical variables, following the work of R. Peñaloza and J. Souza.

All measures act on an [`OrdinalDistribution`](@ref) (relative frequencies over `m`
categories ordered from worst to best) and also accept a plain vector of absolute or
relative frequencies.
"""
module OrdinalStatistics

export OrdinalDistribution, fromresponses, frequencies, ncategories, nobs
export mean_charge, centrum, ordinal_index, index_thresholds
export modal_variability, gini_simpson, renyi_variability, normalized_entropy
export AmbiguousDualError, dual, codual
export endogenous_weights, cindex, contribution

include("types.jl")
include("location.jl")
include("variability.jl")
include("duality.jl")
include("cindex.jl")

end
