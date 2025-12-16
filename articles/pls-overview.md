# PLS Overview

## Overview of Partial Least Squares (PLS) Regression

The `snazzieR` package implements Partial Least Squares regression with
support for:

- The **NIPALS** algorithm
- The **SVD-based** method
- Beautiful **console and LaTeX output** formatting

### What is PLS?

PLS regression is a dimension reduction technique that projects
predictors to a lower-dimensional space that maximally explains
covariance with the response variable(s). It is especially useful when:

- Predictors are highly collinear
- The number of predictors exceeds the number of observations

### Learn More

- NIPALS Algorithm:
  [`vignette("pls-nipals", package = "snazzieR")`](https://jesusbutforgaypeople.github.io/snazzieR/articles/pls-nipals.md)
- SVD Method:
  [`vignette("pls-svd", package = "snazzieR")`](https://jesusbutforgaypeople.github.io/snazzieR/articles/pls-svd.md)
- Output Formatting: `vignette("pls-formatting", package = "snazzieR")`

### The Origins of PLS

The story of PLS begins in the snowy mountains of Uppsala, Sweden. In
the early 1960s, **Herman Wold** was working on a method to analyze the
relationship between a set of predictors and a set of responses. He was
particularly interested in the case where the predictors were highly
collinear, which made traditional regression methods unreliable. Wold’s
solution was to use a *latent variable approach*, where he would extract
a small number of latent variables from the predictors and use them to
predict the responses. This method was later named **Partial Least
Squares (PLS)**. The initial algorithm was called **“NILES”** (Nonlinear
Iterative Least Squares), which was later renamed to **“NIPALS”**
(Nonlinear Iterative Partial Least Squares).

Coming from a background in econometrics, where cleanly independent
predictors are rare, Wold was no stranger to the challenges introduced
by multicollinearity. In 1966, he laid the groundwork for what would
become PLS by introducing an iterative least squares method to estimate
principal components \[11\]. By 1969, he and colleagues applied these
methods to econometric problems including canonical correlation analysis
and fixed-point estimation \[15\].

PLS emerged as an extension of PCA. Both reduce dimensionality while
preserving structure, but PLS goes further by maximizing the covariance
between predictors and responses—making it a more effective regression
tool.

![Herman Wold](figures/Herman_Wold.jpg)  
Herman Wold; the father of PLS \[10\]

In 1975, Wold and colleagues released a formal description of the PLS
algorithm with applications to increasingly large predictor spaces
\[13\]. This laid the foundation for the so-called **“Basic Design”** of
PLS in the late 1970s \[14\], which provided a more formal treatment of
algorithm convergence.

By the 1980s, PLS gained traction in **chemometrics**, particularly for
spectroscopy and chromatography. The iterative **NIPALS** algorithm was
well-suited to handling large variable sets and missing data \[16\].
Software packages helped adoption, though theoretical work briefly
stalled.

This changed in the 1990s with a resurgence in PLS development, aided by
modern computing power. A key moment came with **Sijmen de Jong’s 1993
publication** of an **SVD-based** approach to PLS \[3\], which computed
all components at once instead of iteratively. This dramatically
improved efficiency and opened PLS to large-scale applications such as
**genomics**, **proteomics**, and **metabolomics** \[7\].

Modern variants like **sparse PLS** and **kernel PLS** emerged to
address high-dimensional or nonlinear problems. And with the rise of
**R** and **Python** ecosystems, community-driven implementations made
PLS more accessible than ever \[8\].

![Timeline of PLS Development](figures/timeline.png)

In the 2000s, PLS found application in **neuroimaging** (e.g., fMRI
analysis \[5\]) and later in **machine learning** and **data mining**
through kernel-based extensions \[9\]. As toolkits matured, it became a
staple for classification, regression, and feature extraction.

Recent work integrates PLS with **Bayesian models**, **ensemble
methods**, and even **deep learning**. For example, *Deep PLS* methods
combine interpretability with powerful representation learning \[6\].
With this continued expansion, PLS remains one of the most flexible and
powerful tools for multivariate statistical analysis.

------------------------------------------------------------------------

### References

1.  Abdi, H. (2010). Partial least squares regression and projection on
    latent structure regression (PLS regression). *Technical report*.
    University of Texas at Dallas.
    [http://personal.utdallas.edu/~herve/Abdi-PLS-pretty.pdf](https://finitesample.space/snazzier/abdi-pls.html)
2.  Abdi, H., & Williams, L. J. (2013). Partial least squares methods:
    Partial least squares correlation and partial least square
    regression. *Methods in Molecular Biology*, *930*, 549–579.
    [doi.org/10.1007/978-1-62703-059-5_23](https://doi.org/10.1007/978-1-62703-059-5_23)
3.  de Jong, S. (1993). SIMPLS: An alternative approach to partial least
    squares regression. *Chemometrics and Intelligent Laboratory
    Systems*, *18*(3), 251–263.
    [doi.org/10.1016/0169-7439(93)85002-X](https://doi.org/10.1016/0169-7439(93)85002-X)
4.  Ghosh, S., & Doshi-Velez, F. (2017). Model selection in Bayesian
    neural networks via horseshoe priors. *Journal of Machine Learning
    Research*, *20*(1), 1–46.
5.  Krishnan, A., Williams, L. J., McIntosh, A. R., & Abdi, H. (2011).
    Partial least squares (PLS) methods for neuroimaging: A tutorial and
    review. *NeuroImage*, *56*(2), 455–475.
    [doi.org/10.1016/j.neuroimage.2010.07.034](https://doi.org/10.1016/j.neuroimage.2010.07.034)
6.  Kong, X., & Ge, Z. (2023). Deep PLS: A lightweight deep learning
    model for interpretable and efficient data analytics. *IEEE
    Transactions on Neural Networks and Learning Systems*, *34*(11),
    8923–8937.
    [doi.org/10.1109/TNNLS.2022.3154090](https://doi.org/10.1109/TNNLS.2022.3154090)
7.  Nguyen, D. V., & Rocke, D. M. (2002). Tumor classification by
    partial least squares using microarray gene expression data.
    *Bioinformatics*, *18*(1), 39–50.
    [doi.org/10.1093/bioinformatics/18.1.39](https://doi.org/10.1093/bioinformatics/18.1.39)
8.  Rohart, F., Gautier, B., Singh, A., & Lê Cao, K.-A. (2017).
    mixOmics: An R package for ’omics feature selection and multiple
    data integration. *PLOS Computational Biology*, *13*(11), e1005752.
    [doi.org/10.1371/journal.pcbi.1005752](https://doi.org/10.1371/journal.pcbi.1005752)
9.  Rosipal, R., & Trejo, L. J. (2001). Kernel partial least squares
    regression in reproducing kernel Hilbert space. *Journal of Machine
    Learning Research*, *2*, 97–123.
10. Wikipedia contributors. (2025, March 22). Herman Wold. *Wikipedia*.
    [Wikipedia
    Link](https://en.wikipedia.org/wiki/Herman_Wold#/media/File:Professor_Herman_Wold,_Uppsala,_1969.jpg)
11. Wold, H. (1966). Estimation of principal components and related
    models by iterative least squares. In P. R. Krishnajah (Ed.),
    *Multivariate analysis* (pp. 391–420). Academic Press.
12. Wold, H. (1973). Nonlinear iterative partial least squares (NIPALS)
    modelling: Some current developments. In P. R. Krishnaiah (Ed.),
    *Multivariate Analysis III* (pp. 383–407). Academic Press.
13. Wold, H. (1975). Soft modelling by latent variables: The non-linear
    iterative partial least squares (NIPALS) approach. In *Perspectives
    in Probability and Statistics* (pp. 117–142). Academic Press.
14. Wold, H. (1979). Model construction and evaluation when theoretical
    knowledge is scarce: The PLS approach to latent variables. In K. G.
    Jöreskog & H. Wold (Eds.), *Systems under indirect observation:
    Causality, structure, prediction* (Vol. 2, pp. 47–74).
    North-Holland.
15. Wold, H., & Lyttkens, E. (1969). Nonlinear iterative partial least
    squares (NIPALS) estimation procedures. *Bulletin of the
    International Statistical Institute*, *43*, 29–51.
16. Wold, S., Sjöström, M., & Eriksson, L. (1996). PLS-regression: A
    basic tool of chemometrics. *Chemometrics and Intelligent Laboratory
    Systems*, *58*(2), 109–130.
    [doi.org/10.1016/S0169-7439(01)00155-1](https://doi.org/10.1016/S0169-7439(01)00155-1)
17. Wright, K. (2017, October 27). The NIPALS algorithm.
    *R-Project.org*. <https://CRAN.R-project.org/package=nipals>
