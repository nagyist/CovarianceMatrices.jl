var documenterSearchIndex = {"docs":
[{"location":"introduction.html#Introduction-1","page":"Introduction","title":"Introduction","text":"","category":"section"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"CovarianceMatrices.jl](https://github.com/gragusa/CovarianceMatrices.jl/) implements several covariance estimator for stochastic process. Using these covariances as building blocks, the package extends GLM.jl to alllow obtaining robust covariance estimates of GLM's coefficients. ","category":"page"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"Three classes of estimators are considered:","category":"page"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"HAC \nheteroskedasticity and autocorrelation consistent (Andrews, 1996; Newey and West, 1994)\nVARHAC    \nHC  \nheteroskedasticity consistent (White, 1982)\nCRVE \ncluster robust (Arellano, 1986)","category":"page"},{"location":"introduction.html#Long-run-covariance-1","page":"Introduction","title":"Long run covariance","text":"","category":"section"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"For what follows, let X_t be a stochastic process, i.e. a sequence of random vectors. We will assume throughout that the r.v. are p-dimensional. The sample average of the process is defined as math barX_n = frac1n sum_t=1^n X_t It is often the case that the sampling distribution of sqrtnbarX_n can be approximated (as ntoinfty) by the distribution of a standard multivariate normal distribution centered at mu and long-run variance-covariance V. In other words, the following holds math sqrtnV^-12(barX_n - mu_n) xrightarrowd N(0 I_p) where  math mu = E(X_t) quad textand quad V equiv lim_ntoinfty mathrmVarleft(sqrtnbarX_nright)","category":"page"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"Estimation of V is central in many applications of statistics. For instance, we might be interested in constructing asymptotically valid conficence intervals for a linear combination of the unknown expected value of the process mu, that is, we are interested in making inference about cmu for some p-dimensional vector c. For any random random matrix hatV tending in probability (as ntoinfty) to V, a confidence interval for cbarX with asymptotic coverage (alphatimes 100) is given by math leftcbarX_n - q_1-alpha2 chatVcsqrtn cbarX_n + q_alpha2 chatVcsqrtnright where q_alpha is the alpha-quantile of the standard normal distribution.","category":"page"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"CovarianceMatrices.jl provides methods to estimate V under a variety of assumption on the correlation stracture of the random process. We know explore them one by one starting from the simplest case. ","category":"page"},{"location":"introduction.html#Serially-uncorrelated-process-1","page":"Introduction","title":"Serially uncorrelated process","text":"","category":"section"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"If the process is uncorrelated, the variance covariance reduces to math V_n = Eleftsqrtnleft(frac1nsum_t=1^n left(X_t - muright)right An consistent estimator of V is thus given by math hatV_n = frac1n sum_t=1^n left(X_t - barX_nright) Given X::AbstractMatrix with size(X)=>(n,p) containing n observations on the p dimensional random vectors, an estimate of V can be obtained by lrvar:","category":"page"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"Vhat = lrvar(Uncorrelated(), X)","category":"page"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"Uncorrelated is the type signalling that the random sequence is assumed to be uncorrelated. ","category":"page"},{"location":"introduction.html#Api-1","page":"Introduction","title":"Api","text":"","category":"section"},{"location":"introduction.html#Serially-correlated-process-1","page":"Introduction","title":"Serially correlated process","text":"","category":"section"},{"location":"introduction.html#Correlated-process-(time-series)-1","page":"Introduction","title":"Correlated process (time-series)","text":"","category":"section"},{"location":"introduction.html#Correlated-process-(spatial)-1","page":"Introduction","title":"Correlated process (spatial)","text":"","category":"section"},{"location":"introduction.html#","page":"Introduction","title":"Introduction","text":"In this case, ","category":"page"}]
}