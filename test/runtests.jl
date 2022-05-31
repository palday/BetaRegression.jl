using BetaRegression
using StatsBase
using Test

#=
library(betareg)

data <- read.table("~/Downloads/betareg_example/pratergrouped.mat",
                   skip=1, header=FALSE)
data <- data[, -(1:4)]
names(data) <- c(paste0("x", 2:ncol(data)), "y")
data$y <- data$y / 100

fit <- betareg(y ~ ., data=data, link="logit", type="ML")
sqrt(diag(vcov(fit)))
=#

@testset "Basics" begin
    @test_throws ArgumentError BetaRegressionModel([1 2 3; 4 5 6], [1, 2])
    @test_throws DimensionMismatch BetaRegressionModel([1 2; 3 4; 5 6], [1, 2])
    @test_throws ArgumentError BetaRegressionModel([1 2; 3 4; 5 6], [1, 2, 3])
    @test_throws ArgumentError BetaRegressionModel([1 2; 3 4; 5 6], [0.1, 0.2, 0.3];
                                                   weights=[1])
    X = [1 2; 3 4; 5 6]
    y = [0.1, 0.2, 0.3]
    b = BetaRegressionModel(X, y, CauchitLink())
    @test b isa BetaRegressionModel{Float64,CauchitLink,Vector{Float64},Matrix{Float64}}
    @test response(b) === y
    @test modelmatrix(b) == X
    @test Link(b) == CauchitLink()
    @test nobs(b) == 3
    @test coef(b) == [0, 0]
    @test dispersion(b) == 0
    fit!(b)
    @test coef(b) != [0, 0]
    @test dispersion(b) > 0
    X = ones(Int, 3, 1)
    y .= 0.5
    b = BetaRegressionModel(X, y, CauchitLink())
    @test_throws ConvergenceException fit!(b)
end

@testset "Example: Food expenditure data (Ferrari table 2)" begin
    food = [15.998 62.476 1
            16.652 82.304 5
            21.741 74.679 3
             7.431 39.151 3
            10.481 64.724 5
            13.548 36.786 3
            23.256 83.052 4
            17.976 86.935 1
            14.161 88.233 2
             8.825 38.695 2
            14.184 73.831 7
            19.604 77.122 3
            13.728 45.519 2
            21.141 82.251 2
            17.446 59.862 3
             9.629 26.563 3
            14.005 61.818 2
             9.160 29.682 1
            18.831 50.825 5
             7.641 71.062 4
            13.882 41.990 4
             9.670 37.324 3
            21.604 86.352 5
            10.866 45.506 2
            28.980 69.929 6
            10.882 61.041 2
            18.561 82.469 1
            11.629 44.208 2
            18.067 49.467 5
            14.539 25.905 5
            19.192 79.178 5
            25.918 75.811 3
            28.833 82.718 6
            15.869 48.311 4
            14.910 42.494 5
             9.550 40.573 4
            23.066 44.872 6
            14.751 27.167 7]
    y = food[:, 1] ./ food[:, 2]
    X = hcat(ones(size(food, 1)), food[:, 2:end])
    model = fit(BetaRegressionModel, X, y)
    @test coef(model) ≈ [-0.62255, -0.01230, 0.11846] atol=1e-5
    @test dispersion(model) ≈ 35.60975 atol=1e-5
    @test stderror(model) ≈ [0.22385, 0.00304, 0.03534, 8.07960] atol=1e-5
end

@testset "Example: Prater's gasoline data (Ferrari table 1)" begin
    X = [1  1  0  0  0  0  0  0  0  0  205
         1  1  0  0  0  0  0  0  0  0  275
         1  1  0  0  0  0  0  0  0  0  345
         1  1  0  0  0  0  0  0  0  0  407
         1  0  1  0  0  0  0  0  0  0  218
         1  0  1  0  0  0  0  0  0  0  273
         1  0  1  0  0  0  0  0  0  0  347
         1  0  0  1  0  0  0  0  0  0  212
         1  0  0  1  0  0  0  0  0  0  272
         1  0  0  1  0  0  0  0  0  0  340
         1  0  0  0  1  0  0  0  0  0  235
         1  0  0  0  1  0  0  0  0  0  300
         1  0  0  0  1  0  0  0  0  0  365
         1  0  0  0  1  0  0  0  0  0  410
         1  0  0  0  0  1  0  0  0  0  307
         1  0  0  0  0  1  0  0  0  0  367
         1  0  0  0  0  1  0  0  0  0  395
         1  0  0  0  0  0  1  0  0  0  267
         1  0  0  0  0  0  1  0  0  0  360
         1  0  0  0  0  0  1  0  0  0  402
         1  0  0  0  0  0  0  1  0  0  235
         1  0  0  0  0  0  0  1  0  0  275
         1  0  0  0  0  0  0  1  0  0  358
         1  0  0  0  0  0  0  1  0  0  416
         1  0  0  0  0  0  0  0  1  0  285
         1  0  0  0  0  0  0  0  1  0  365
         1  0  0  0  0  0  0  0  1  0  444
         1  0  0  0  0  0  0  0  0  1  351
         1  0  0  0  0  0  0  0  0  1  424
         1  0  0  0  0  0  0  0  0  0  365
         1  0  0  0  0  0  0  0  0  0  379
         1  0  0  0  0  0  0  0  0  0  428]
    y = [0.122, 0.223, 0.347, 0.457, 0.080, 0.131, 0.266, 0.074, 0.182, 0.304, 0.069,
         0.152, 0.260, 0.336, 0.144, 0.268, 0.349, 0.100, 0.248, 0.317, 0.028, 0.064,
         0.161, 0.278, 0.050, 0.176, 0.321, 0.140, 0.232, 0.085, 0.147, 0.180]
    model = fit(BetaRegressionModel, X, y)
    @test coef(model) ≈ [-6.15957, 1.72773, 1.32260, 1.57231, 1.05971, 1.13375,
                         1.04016, 0.54369, 0.49590, 0.38579, 0.01097] atol=1e-5
    @test dispersion(model) ≈ 440.27838 atol=1e-5
    @test stderror(model) ≈ [0.18232, 0.10123, 0.11790, 0.11610, 0.10236, 0.10352,
                             0.10604, 0.10913, 0.10893, 0.11859, 0.00041, 110.02562] atol=1e-4
end