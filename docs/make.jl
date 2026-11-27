using OrdinalStatistics
using Documenter

DocMeta.setdocmeta!(OrdinalStatistics, :DocTestSetup, :(using OrdinalStatistics); recursive=true)

makedocs(;
    modules=[OrdinalStatistics],
    authors="Miguel Morais",
    sitename="OrdinalStatistics.jl",
    format=Documenter.HTML(;
        canonical="https://MiguelGMorais.github.io/OrdinalStatistics.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting started" => "getting_started.md",
        "Manual" => [
            "Ordinal distributions" => "manual/distributions.md",
            "Location" => "manual/location.md",
            "Variability" => "manual/variability.md",
            "Dual and codual" => "manual/duality.md",
            "The c-index" => "manual/composite_index.md",
        ],
        "References" => "references.md",
        "Function index" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/MiguelGMorais/OrdinalStatistics.jl",
    devbranch="main",
)
