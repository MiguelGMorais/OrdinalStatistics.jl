using OrdinalStatistics
using Test

# Reference data from the lecture notes (Peñaloza 2012a; Peñaloza & Macedo 2012).
const EDUCATION = [
    [0, 0, 0, 1, 0],             # literacy
    [0, 1, 0, 0, 0],             # numeracy
    [0.5, 0, 0.5, 0, 0],         # sociality
    [0.25, 0, 0, 0, 0.75],       # learning
    [0.1, 0.5, 0.1, 0.2, 0.1],   # physical activities
    [0.1, 0.6, 0.3, 0, 0],       # science
    [0.3, 0.5, 0.1, 0.1, 0],     # practical reason
]
const POLITICAL = [7, 13, 13, 5, 8, 2, 0]
const CIVIL = [11, 12, 17, 3, 1, 4, 0]

@testset "OrdinalStatistics.jl" begin
    @testset "OrdinalDistribution" begin
        d = OrdinalDistribution(POLITICAL)
        @test ncategories(d) == 7
        @test nobs(d) == 48
        @test sum(frequencies(d)) ≈ 1
        @test frequencies(d) ≈ POLITICAL ./ 48
        r = OrdinalDistribution([0.2, 0.3, 0.5])
        @test nobs(r) === nothing
        @test frequencies(OrdinalDistribution([2.0, 3.0, 5.0])) ≈ frequencies(r)
        @test OrdinalDistribution(d) === d
        @test_throws ArgumentError OrdinalDistribution([1.0])
        @test_throws ArgumentError OrdinalDistribution([0, 0, 0])
        @test_throws ArgumentError OrdinalDistribution([0.5, -0.1, 0.6])
        @test_throws ArgumentError OrdinalDistribution([0.5, NaN])
    end

    @testset "fromresponses" begin
        answers = [4, 5, 5, 1, 4, 5, 3, 5]
        d = fromresponses(answers, 5)
        @test d == OrdinalDistribution([1, 0, 1, 2, 4])
        @test nobs(d) == 8
        @test ncategories(d) == 5
        @test ordinal_index(d) ≈ ordinal_index([count(==(k), answers) for k in 1:5])
        # empty top categories still count towards m
        @test ncategories(fromresponses([1, 2, 1], 4)) == 4
        # the democracy series rebuilt from individual country scores
        political = reduce(vcat, [fill(k, n) for (k, n) in enumerate(POLITICAL)])
        @test fromresponses(political, 7) == OrdinalDistribution(POLITICAL)
        # any iterable works; missing values are dropped only explicitly
        @test fromresponses((k for k in (1, 2, 2)), 3) == OrdinalDistribution([1, 2, 0])
        @test nobs(fromresponses(skipmissing([2, missing, 3]), 3)) == 2
        @test_throws ArgumentError fromresponses([2, missing, 3], 3)
        @test_throws ArgumentError fromresponses([1, 2, 6], 5)
        @test_throws ArgumentError fromresponses([0, 1], 5)
        @test_throws ArgumentError fromresponses([1.0, 2.0], 5)
        @test_throws ArgumentError fromresponses(Int[], 5)
        @test_throws ArgumentError fromresponses([1, 1], 1)
    end

    @testset "location" begin
        @test mean_charge([0.5, 0, 0, 0, 0.5]) ≈ 0.6
        @test mean_charge([0.1, 0.5, 0.1, 0.2, 0.1]) ≈ 0.54
        @test mean_charge([5, 5, 50, 60, 80]) ≈ 0.805
        @test mean_charge([0, 0, 1, 0, 0]) ≈ 3 / 5

        @test centrum([0.5, 0, 0, 0, 0.5]) == 3:3
        @test centrum([0.5, 0, 0.5, 0, 0]) == 2:2
        @test centrum(fill(0.2, 5)) == 3:3
        @test centrum([0.1, 0.5, 0.1, 0.2, 0.1]) == 3:3
        @test centrum([5, 5, 50, 60, 80]) == 4:4
        @test centrum([0.5, 0, 0, 0.5]) == 2:3
        @test centrum(POLITICAL) == 3:3
        @test centrum(CIVIL) == 3:3

        @test ordinal_index([0.1, 0.5, 0.1, 0.2, 0.1]) ≈ 42.5
        @test ordinal_index([0.55, 0.45, 0, 0]) ≈ 15
        @test ordinal_index(POLITICAL) ≈ 33.333333 atol = 1e-5
        @test ordinal_index(CIVIL) ≈ 27.43 atol = 5e-3
        @test ordinal_index([0, 0, 0, 1]) ≈ 100
        @test ordinal_index([1, 0, 0, 0]) ≈ 0
        # symmetric distributions have index 50
        @test ordinal_index([0.1, 0.2, 0.4, 0.2, 0.1]) ≈ 50
        # mean charge and index are linked: m S̄ = (m − 1) ℐ / 100 + 1
        f = [0.1, 0.6, 0.3, 0, 0]
        @test 5 * mean_charge(f) ≈ 4 * ordinal_index(f) / 100 + 1

        @test index_thresholds(3) ≈ [25, 75]
        @test index_thresholds(5) ≈ [12.5, 37.5, 62.5, 87.5]
        @test index_thresholds(7) ≈ [100 / 12, 25, 500 / 12, 700 / 12, 75, 1100 / 12]
        @test_throws ArgumentError index_thresholds(1)
    end

    @testset "variability" begin
        x = [0.02, 0.10, 0.70, 0.18]
        y = [0.01, 0.28, 0.70, 0.01]
        @test modal_variability(x) ≈ 0.4
        @test modal_variability(y) ≈ 0.4
        @test gini_simpson(x) ≈ 0.6229 atol = 1e-4
        @test gini_simpson(y) ≈ 0.5752 atol = 1e-4
        @test normalized_entropy(x) ≈ 0.6253 atol = 1e-4
        @test normalized_entropy(y) ≈ 0.5036 atol = 1e-4
        @test gini_simpson(POLITICAL) ≈ 0.9236 atol = 1e-4
        @test gini_simpson(CIVIL) ≈ 0.8730 atol = 1e-4
        @test gini_simpson([0.1, 0.5, 0.1, 0.2, 0.1]) ≈ 0.85

        for v in (modal_variability, gini_simpson, normalized_entropy, q -> renyi_variability(q, 3))
            @test v([0, 0, 1, 0]) ≈ 0 atol = 1e-12
            @test v(fill(0.25, 4)) ≈ 1
        end
        @test renyi_variability(x, 2) ≈ gini_simpson(x)
        @test_throws DomainError renyi_variability(x, 1)
        @test_throws DomainError renyi_variability(x, Inf)
        # ordering υ² ≥ υ^∞ (exercise, ch. 2)
        @test gini_simpson(x) ≥ modal_variability(x)
    end

    @testset "dual and codual" begin
        # Peñaloza (2012a), education
        coduals = [1.0, 0.0, 0.1938, 0.8644, 0.3064, 0.7850, 0.2764]
        for (f, c) in zip(EDUCATION, coduals)
            @test codual(f) ≈ c atol = 1e-4
            @test dual(f) + codual(f) ≈ 1
        end
        # Peñaloza & Macedo (2012), democracy
        @test dual(POLITICAL) ≈ 0.6382 atol = 1e-4
        @test dual(CIVIL) ≈ 0.6782 atol = 1e-4
        @test codual(POLITICAL) ≈ 0.3618 atol = 1e-4
        @test codual(CIVIL) ≈ 0.3218 atol = 1e-4
        # worked examples, ch. 3
        @test dual([0.1, 0.5, 0.1, 0.2, 0.1]) ≈ 0.6936 atol = 1e-4
        @test dual([5, 5, 50, 60, 80]) ≈ 0.3115 atol = 1e-4
        # concentrated distributions, m = 5
        @test codual([0, 0, 0, 1, 0]) ≈ 1
        @test codual([0, 1, 0, 0, 0]) ≈ 0 atol = 1e-12
        # retail Q6 and the PCA example
        @test codual([0, 0, 0.8, 0.2]) ≈ 0.8786 atol = 1e-4
        @test codual([0.2, 0, 0, 0, 0.8]) ≈ 0.8873 atol = 1e-4
        @test codual([0.8, 0, 0, 0, 0.2]) ≈ 0.1127 atol = 1e-4
        # fundamental equation: d² − d + υ²/4 = 0
        for f in EDUCATION
            d = dual(f)
            @test d^2 - d + gini_simpson(f) / 4 ≈ 0 atol = 1e-12
        end

        # retail Q4: ambiguous dualization
        q4 = [0.5, 0, 0, 0.5]
        @test_throws AmbiguousDualError codual(q4)
        @test_throws AmbiguousDualError dual(q4)
        @test codual(q4; ambiguous = :upper) ≈ 0.7887 atol = 1e-4
        @test codual(q4; ambiguous = :lower) ≈ 0.2113 atol = 1e-4
        @test_throws ArgumentError codual(q4; ambiguous = :foo)
        @test sprint(showerror, AmbiguousDualError(OrdinalDistribution(q4))) isa String
        # uniform: both roots equal ½, no ambiguity to resolve
        @test codual(fill(0.25, 4)) ≈ 0.5
        @test codual(fill(0.2, 5)) ≈ 0.5
    end

    @testset "c-index" begin
        # Peñaloza (2012a), education
        @test cindex(EDUCATION) ≈ 54.92 atol = 5e-3
        @test all(isapprox.(endogenous_weights(EDUCATION),
                            [0.292, 0.0, 0.057, 0.252, 0.089, 0.229, 0.081]; atol = 1e-3))
        @test sum(endogenous_weights(EDUCATION)) ≈ 1
        Δ = contribution(EDUCATION)
        @test all(isapprox.(Δ, [8.28, 0.0, -1.79, 6.78, -1.22, -7.41, -2.63]; atol = 5e-3))
        # Σ (1 − w_q) Δ_q = 0
        w = endogenous_weights(EDUCATION)
        @test sum((1 .- w) .* Δ) ≈ 0 atol = 1e-10
        # definition: Δ_q = Γ − Γ_{−q}
        Γ = cindex(EDUCATION)
        for q in (1, 3, 5)
            @test Δ[q] ≈ Γ - cindex(EDUCATION[setdiff(1:7, q)])
        end

        # Peñaloza & Macedo (2012), democracy
        dem = [POLITICAL, CIVIL]
        @test all(isapprox.(endogenous_weights(dem), [0.5293, 0.4707]; atol = 1e-4))
        @test cindex(dem) ≈ 30.55 atol = 5e-3

        # questions with different numbers of categories
        @test cindex([[0, 0, 1], [0, 0, 0, 1]]) ≈ 100

        # retail: Q4 makes the c-index ambiguous
        retail = [fill(0.25, 4), [0, 1, 0, 0], [0, 0, 1, 0], [0.5, 0, 0, 0.5],
                  [0, 0.2, 0.8, 0], [0, 0, 0.8, 0.2], [0.2, 0, 0.8, 0], [0.1, 0.1, 0.8, 0]]
        @test ordinal_index.(retail) ≈ [50, 100 / 3, 200 / 3, 50, 60, 220 / 3, 160 / 3, 170 / 3]
        @test_throws AmbiguousDualError cindex(retail)
        @test cindex(retail; ambiguous = :upper) ≈ 61.20 atol = 5e-3
        @test cindex(retail; ambiguous = :lower) ≈ 63.38 atol = 5e-3

        # degenerate questionnaires
        @test_throws ArgumentError cindex(Vector{Float64}[])
        @test_throws DomainError cindex([[1, 0, 0], [0, 1, 0, 0, 0]])
        @test isnan(only(contribution([[0, 0, 1]])))

        # equal coduals ⇒ arithmetic mean of the indices (exercise, ch. 13)
        @test cindex([[0, 0, 1, 0], [0, 0, 0, 1]]) ≈ (200 / 3 + 100) / 2
    end
end
