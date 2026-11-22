using OrdinalStatistics
using Documenter

DocMeta.setdocmeta!(OrdinalStatistics, :DocTestSetup, :(using OrdinalStatistics); recursive=true)

makedocs(;
    modules=[OrdinalStatistics],
    authors="Miguel Morais",
    sitename="OrdinalStatistics.jl",
    format=Documenter.HTML(;
        canonical="https://MiguelGMorais.github.io/OrdinalStatistics.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MiguelGMorais/OrdinalStatistics.jl",
    devbranch="master",
)
