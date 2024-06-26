# CovarianceMatrices.jl

[![Build Status](https://travis-ci.org/gragusa/CovarianceMatrices.jl.svg?branch=master)](https://travis-ci.org/gragusa/CovarianceMatrices.jl)
[![Coverage Status](https://coveralls.io/repos/gragusa/CovarianceMatrices.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/gragusa/CovarianceMatrices.jl?branch=master)
[![codecov.io](http://codecov.io/github/gragusa/CovarianceMatrices.jl/coverage.svg?branch=master)](http://codecov.io/github/gragusa/CovarianceMatrices.jl?branch=master)

Heteroskedasticity and Autocorrelation Consistent Covariance Matrix Estimation for Julia.

## Installation

```julia
Pkg.add("CovarianceMatrices")
```

## Introduction

This package provides types and methods applicable to obtain consistent estimates of the long-run covariance matrix of a random process.

Three classes of estimators are considered:

1. **HAC**
   a. **Kernel** 
   b. **EWC** 
   c. **Smoothed**
   d. **VarHAC**

2. **HC**

3. **CR** 

4. **DriscolKray**


The typical application of these estimators is to conduct robust inference about the parameters of a statistical model. 


The package extends methods defined in [StatsBase.jl](http://github.com/JuliaStat/StatsBase.jl) and [GLM.jl](http://github.com/JuliaStat/GLM.jl) to provide a plug-and-play replacement for the standard errors calculated by default by [GLM.jl](http://github.com/JuliaStat/GLM.jl). The [GLM.jl](http://github.com/JuliaStat/GLM.jl) are implemented as an extension. 

The API can be used regardless of whether the model is fit with [GLM.jl](http://github.com/JuliaStat/GLM.jl) and developers can extend their estimation methods to provide robust standard errors. 

## HAC (Heteroskedasticity and Autocorrelation Consistent)

Let $\{X_t, t=1,\ldots\}$ be a random vector process. Under suitable conditions, we have that as $T\to\infty$

$$
\sqrt{T}\Sigma_T^{-1/2}(\bar{X}_T - \mu_T) \xrightarrow{d} N(0, I_k),
$$
where 
$$
\bar{X}_T = \frac{1}{T}\sum_{t=1}^T X_t,\quad \mu_T = E\bar{X}_T,
$$
and $\Sigma_T$ is the asymptotic variance of $\sqrt{T}\bar{X}_T$, that is, 
$$
\Sigma_T := \lim_{T\to\infty} \mathrm{Var}\left(\frac{1}{\sqrt{T}}\sum_{t=1}^T X_t \right).
$$

### Kernel methods

The covariance matrix $\Sigma_T$ can be estimated using kernel method:
$$
\hat{\Sigma}_T = \sum_{h=-T+1}^{T-1} k\left(\frac{h}{B_T}\right) \hat\Gamma(h) + \hat\Gamma(h)'
$$

where 
$$
\hat{\Gamma}(h) = \frac{1}{T-h}\sum_{t=h+1}^T (X_t - \bar{X}_T)(X_t - \bar{X}_T)',
$$
and $k(\cdot)$ is a _kernel_ function, and $B_T$ is the bandwidth parameter. 

The kernel is a symmetric, real-valued, and non-negative function that determines the weights given to each sample autocovariance. 

The kernel implemented in `CovarianceMatrices` are:

_Truncated_

$$
k(u)=\begin{cases}
1 & |u|\leqslant1\\
0 & \text{otherwise}
\end{cases}
$$

_Bartlett_

$$
k(u)=\begin{cases}
1-|u| & |u|\leqslant1\\
0 & \text{otherwise}
\end{cases}
$$

_Parzen_

$$
k(u) = \begin{cases}
1-6|u|^{2}+6|u|^{3} & |u|\leqslant1/2\\
2(1-|u|)^{2} & \text{otherwise}
\end{cases}
$$

_Tukey-Hanning_

$$
k(u)=\begin{cases}
0.5(1+\cos(\pi u)) & |u|\leqslant1\\
0 & \text{otherwise}
\end{cases}
$$


_Quadratic Spectral_

$$
k(u)=\frac{25}{12\pi^{2}u^{2}}\left(\frac{\sin(6\pi u/5)}{\frac{6}{5}\pi x}-cos(6\pi u/5)\right)
$$


A kernel based estimate of $\Sigma_T$ can be obtained by

```julia
Sigma_hat = aVar(Truncated(3.4), X)
Sigma_hat = aVar(Bartlett(3.4), X)
Sigma_hat = aVar(Parzen(3.4), X)
```

- `TruncatedKernel`
- `BartlettKernel`
- `ParzenKernel`
- `TukeyHanningKernel`
- `QuadraticSpectralKernel`

For example, `ParzenKernel{NeweyWest}()` returns an instance of `TruncatedKernel` parametrized by `NeweyWest`, the type that corresponds to the optimal bandwidth calculated following Newey and West (1994).  Similarly, `ParzenKernel{Andrews}()` corresponds to the optimal bandwidth obtained in Andrews (1991). If the bandwidth is known, it can be directly passed, i.e. `TruncatedKernel(2)`.



### Long-run variance of regression coefficients

In the regression context, the function `vcov` does all the work:
```julia
vcov(::HAC, ::DataFrameRegressionModel; prewhite = true)
```

Consider the following artificial data (a regression with autoregressive error component):

```julia
using CovarianceMatrices
using Random, DataFrames, GLM
Random.seed!(1)
n = 500
x = randn(n,5)
u = zeros(2*n)
u[1] = rand()
for j in 2:2*n
    u[j] = 0.78*u[j-1] + randn()
end
u = u[n+1:2*n]
y = 0.1 .+ x*[0.2, 0.3, 0.0, 0.0, 0.5] + u

df = convert(DataFrame,x)
df[!,:y] = y
```

The coefficient of the regression can be estimated using `GLM`

```julia
lm1 = glm(@formula(y~x1+x2+x3+x4+x5), df, Normal(), IdentityLink())
```

To get a consistent estimate of the long run variance of the estimated coefficients using a Quadratic Spectral kernel with automatic bandwidth selection  _à la_ Andrews
```julia
vcov(QuadraticSpectralKernel{Andrews}(), lm1, prewhite = false)
```
If one wants to estimate the long-time variance using the same kernel, but with a bandwidth selected _à la_ Newey-West
```julia
vcov(QuadraticSpectralKernel{NeweyWest}(), lm1, prewhite = false)
```
The standard errors can be obtained by the `stderror` method
```julia
stderror(::HAC, ::DataFrameRegressionModel; prewhite::Bool)
```
For the previous example:
```julia
stderror(QuadraticSpectralKernel{NeweyWest}(), lm1, prewhite = false)
```

The bandwidth selected by the automatic procedures can be accessed by `optimalbandwidth`
```julia
optimalbandwidth(QuadraticSpectralKernel{NeweyWest}(), lm1; prewhite = false)
optimalbandwidth(QuadraticSpectralKernel{Andrews}(), lm1; prewhite = false)
```
Alternatively, the optimal bandwidth is stored in the kernel structure (upon variance calculation) and can be accessed (this way requires, however, that the kernel type is materialized)
```julia
kernel = QuadraticSpectralKernel{NeweyWest}()
stderror(kernel, lm1, prewhite = false)
bw = CovarianceMatrices.bandwidth(kernel)
```


### Covariances without `GLM.jl`

One might want to calculate a variance estimator when the regression (or some other model) is fit "manually". Below is an example of how this can be accomplished.

```julia
X   = [ones(n) x]
_,K = size(X)
b   = X\y
res = y .- X*b
momentmatrix = X.*res
B   = inv(X'X)      # Jacobian of moment conditions
bw = CovarianceMatrices.optimalbandwidth(kernel, momentmatrix, prewhite=false)
A   = lrvar(QuadraticSpectralKernel(bw), momentmatrix, scale = n^2/(n-K))   # df adjustment is built into vcov
Σ   = B*A*B
Σ .- vcov(QuadraticSpectralKernel(bw), lm1, dof_adjustment=true)
```
The utility function `sandwich` does all this automatically:

```julia
vcov(QuadraticSpectralKernel(bw[1]), lm1, dof_adjustment=true) ≈ CovarianceMatrices.sandwich(QuadraticSpectralKernel(bw[1]), B, momentmatrix, dof = K)
vcov(QuadraticSpectralKernel(bw[1]), lm1, dof_adjustment=false) ≈ CovarianceMatrices.sandwich(QuadraticSpectralKernel(bw[1]), B, momentmatrix, dof = 0)
```


## HC (Heteroskedastic consistent)

As in the HAC case, `vcov` and `stderror` are the main functions. They know get as argument the type of robust variance being sought

```julia
vcov(::HC, ::DataFrameRegressionModel)
```

Where HC is an abstract type with the following concrete types:

- `HC0`
- `HC1` (this is `HC0` with the degree of freedom adjustment)
- `HC2`
- `HC3`
- `HC4`
- `HC4m`
- `HC5`


```julia
using CovarianceMatrices, DataFrames, GLM
# A Gamma example, from McCullagh & Nelder (1989, pp. 300-2)
# The weights are added just to test the interface and are not part
# of the original data
clotting = DataFrame(
    u    = log.([5,10,15,20,30,40,60,80,100]),
    lot1 = [118,58,42,35,27,25,21,19,18],
    lot2 = [69,35,26,21,18,16,13,12,12],
    w    = 9*[1/8, 1/9, 1/25, 1/6, 1/14, 1/25, 1/15, 1/13, 0.3022039]
)
wOLS = fit(GeneralizedLinearModel, @formula(lot1~u), clotting, Normal(), wts = clotting[!,:w])

vcov(HC0(),wOLS)
vcov(HC1(),wOLS)
vcov(HC2(),wOLS)
vcov(HC3(),wOLS)
vcov(HC4(),wOLS)
vcov(HC4m(),wOLS)
vcov(HC5(),wOLS)

```


## CRHC (Cluster robust heteroskedasticity consistent)

The API of this class of estimators is subject to change, so please use it with care. The difficulty is that `CRHC` type needs access to the clustering variables. For the moment, the following approach works 

```julia
using RDatasets
df = dataset("plm", "Grunfeld")
lm = glm(@formula(Inv~Value+Capital), df, Normal(), IdentityLink())
vcov(CRHC1(:Firm, df), lm)
stderror(CRHC1(:Firm, df),lm)
```

Alternatively, the cluster indicator can be passed directly (but this will only work if there are not missing values)

```julia
vcov(CRHC1(df[:Firm]), lm)
stderror(CRHC1(df[:Firm]),lm)
```

As in the `HAC` case, `sandwich` and `lrvar` can be leveraged to construct cluster-robust variances without relying on `GLM.jl`.

## Performances


```julia
using BenchmarkTools
## Calculating a HAC on a large matrix
Z = randn(10000, 10)
@btime aVar($(Bartlett{Andrews}()), $Z; prewhite = true) 
```

```
681.166 μs (93 allocations: 3.91 MiB)
```

```r
library(sandwich)
library(microbenchmark)
Z <- matrix(rnorm(10000*10), 10000, 10)
microbenchmark( "Bartlett/Newey" = {lrvar(Z, type = "Andrews", kernel = "Bartlett", adjust=FALSE)})
```

```
Unit: milliseconds
        expr    min      lq      mean     median      uq     max  neval
 Bartlett/Newey 59.56402 60.7679 63.85169 61.47827 68.73355 82.26539 100
```
