---
title: 'MetaStat: An R Shiny Application for Accessible and Reproducible Meta-Analysis'
tags:
  - R
  - Shiny
  - meta-analysis
  - systematic review
  - statistics
  - evidence synthesis
  - graphical user interface
authors:
  - name: Franco Suarez
    orcid: 0000-0003-3179-2701
    affiliation: 1
  - name: Sebastian Filipigh
    orcid: 0009-0008-6573-6840
    affiliation: 1
  - name: Cecilia Bruno
    orcid: 0000-0002-3674-7128
    affiliation: "1, 2"
affiliations:
  - name: Estadística y Biometría, Facultad de Ciencias Agropecuarias, Universidad Nacional de Córdoba, Argentina
    index: 1
  - name: Grupo Vinculado Unidad de Fitopatología y Modelización Agrícola INTA-CONICET, Córdoba, Argentina
    index: 2
date: 20 May 2026
bibliography: paper.bib
repository-code: 'https://github.com/FrancoMSuarez/MetaStat'
archive-doi: '10.5281/zenodo.20310380'
---

# Summary

Systematic reviews and meta-analyses are cornerstones of evidence-based science. A
systematic review synthesizes evidence from a research question using comprehensive and
reproducible methods to search, identify, select, evaluate, and extract data from
published primary studies [@zhai2024]. Meta-analysis is the statistical technique that
combines quantitative results from those studies to produce a pooled effect estimate with
a confidence interval, increasing statistical power and resolving ambiguities that arise
when individual studies are underpowered [@allami2021; @zhai2024].

Despite their importance, meta-analyses are technically demanding. Widely used R packages
such as `meta` [@balduzzi2019] and `metafor` [@viechtbauer2010] implement state-of-the-art
procedures but require programming skills that constitute a barrier for practitioners
outside computational disciplines. Commercial software such as SAS [@sas2023], STATA
[@statacorp2015], and SPSS [@ibm2017] partially addresses usability but imposes licensing
costs and limits reproducibility. `MetaStat` was developed to fill this gap: it is a
free, open-source R package that wraps the analytical power of `meta` and `metafor` in
an intuitive Shiny [@chang2024] web application, making the full meta-analysis workflow
available without requiring any programming knowledge.

`MetaStat` supports both continuous and discrete outcomes, fixed-effect and random-effects
models, subgroup analyses, meta-regression, and three standard diagnostic visualisations.
It is available as a standalone Windows desktop application [@zarathucorp2025], as an
installable R package via GitHub, and as a hosted web application at
<https://francosuarez.shinyapps.io/metastats/>.

# Statement of Need

Evidence synthesis is increasingly required across scientific disciplines. In agricultural
sciences, for example, meta-analyses are used to evaluate treatment effects across
experiments conducted in diverse environments [@allami2021]. Yet many researchers in these
fields lack formal training in statistical computing and face practical barriers when
attempting to use command-line tools.

Existing meta-analysis software occupies two extremes: powerful but code-intensive
packages (R's `meta` and `metafor`) or limited web calculators such as RevMan
[@revman2025] that do not support meta-regression or flexible heterogeneity estimation.
Some authors have noted that performing auxiliary analyses—meta-regression, subgroup
comparisons, publication bias diagnostics—often requires switching between multiple tools
[@tantry2021], disrupting workflow and reproducibility.

`MetaStat` addresses all of these limitations in a single, integrated application. By
building on the `golem` framework [@fay2023], `MetaStat` is itself an R package, meaning
its source code is versioned, testable, and installable with standard R tooling. The
Shiny interface hides implementation details without sacrificing analytical depth,
allowing the same researcher who cannot write R code to access fixed/random effects
estimation, several heterogeneity estimators, subgroup contrasts, and meta-regression
from a single browser tab. This combination of accessibility and analytical completeness
is, to the authors' knowledge, unique among freely available meta-analysis tools.

# Implementation

`MetaStat` is structured as an R package using the `golem` framework [@fay2023], which
enforces a modular Shiny architecture and makes the application installable, testable,
and deployable from a single codebase. Each analytical model (e.g., odds ratio, mean
difference, correlation) is implemented as an independent Shiny module, enabling clean
separation of concerns and straightforward extension. The user interface is built with
`bslib` [@sievert2024] using the Minty Bootswatch theme and a `page_navbar` layout with
a top navigation bar whose panels are revealed progressively as the user advances through
the workflow—preventing navigation errors before data are loaded.

Core meta-analytic computations are delegated entirely to the `meta` package
[@balduzzi2019], which itself calls `metafor` [@viechtbauer2010] for heterogeneity
estimation and meta-regression. `MetaStat` therefore inherits the full suite of
estimators available in those packages (DerSimonian–Laird, REML, ML, Hedges, and
others) without reimplementing any statistical logic. Results tables are rendered with
`DT` [@xie2023] for interactive sorting and filtering, and `shinyjs` [@attali2021]
manages dynamic UI visibility. All plots are generated with base R graphics via
`meta`'s `forest()`, `funnel()`, and `baujat()` functions, with `MetaStat` adding
automatic height scaling so that forest plots remain legible regardless of the number
of studies.

The dependency graph is kept intentionally lean: `shiny`, `bslib`, `golem`, `meta`,
`readxl`, `DT`, `dplyr`, and `shinyjs`. This minimises installation friction and
reduces the risk of future breaking changes.

# Functionality

## Workflow Overview

The application guides the user through a linear workflow enforced by the navigation
bar. Panels for models, plots, and meta-regression are hidden until data have been
successfully loaded, preventing common usage errors.

![MetaStat home screen. Users select the outcome type (continuous or discrete) to begin
the workflow.\label{fig:home}](figures/fig_home.png){ width=90% }

## Data Input

After selecting the outcome type, the user uploads a dataset in `.csv`, `.xlsx`, or
`.txt` format. Configurable options cover column separators (comma, semicolon, tab),
decimal characters (period or comma), and the presence of a header row. The loaded
dataset is rendered in an interactive `DT` table for immediate visual verification
(\autoref{fig:data}).

![Data loading panel. The sidebar contains file and format options; the main area shows
an interactive preview of the uploaded dataset.\label{fig:data}](figures/fig_data.png){ width=90% }

## Meta-Analysis Models

`MetaStat` implements ten meta-analysis models, divided by outcome type:

**Continuous outcomes:** ratio of means, correlations, mean difference, standardised
mean difference, single mean.

**Discrete outcomes:** odds ratio, arcsine transformation (Freeman–Tukey), risk
difference, single proportion, risk ratio.

After selecting a model, the user maps dataset columns to the required parameters via
dropdown menus. Both fixed-effect and random-effects estimation are available, along
with optional subgroup analysis (\autoref{fig:model}). Several heterogeneity estimators
can be selected (DerSimonian–Laird, REML, ML, Hedges, and others, depending on the model).

![Model configuration and results panel showing parameter dropdowns (left sidebar) and
the nine-table results output.\label{fig:model}](figures/fig_model.png){ width=90% }

## Results Tables

Fitted models produce up to nine structured tables:

1. Study-level estimates, confidence intervals, z-statistics, p-values, and weights
2. Count of combined and individual studies
3. Overall effect estimate, confidence interval, and p-value
4. Heterogeneity quantification (τ², H, I²)
5. Test of heterogeneity
6. Heterogeneity estimation method
7. Subgroup effect estimates, confidence intervals, and p-values *(if applicable)*
8. Within-subgroup heterogeneity *(if applicable)*
9. Test for differences between subgroups *(if applicable)*

## Visualisation

Three diagnostic plots are available as dedicated tabs and can each be downloaded as
`.png` files (\autoref{fig:plots}):

- **Forest plot** — displays individual study estimates with confidence intervals and
  the pooled effect diamond. Plot height scales automatically with the number of
  studies (and the number of subgroups when applicable) to ensure readability.
- **Funnel plot** — plots study precision against effect size to support visual
  assessment of publication bias.
- **Baujat plot** — identifies studies that contribute disproportionately to overall
  heterogeneity, aiding sensitivity analysis decisions.

![Visualisation tab showing a forest plot (top) and funnel/Baujat plots (bottom) from
a fitted random-effects model.\label{fig:plots}](figures/fig_plots.png){ width=90% }

## Meta-Regression

The meta-regression tab (\autoref{fig:metareg}) extends the fitted model by adding a
moderator variable selected from the dataset columns. `MetaStat` returns a full
diagnostic table including log-likelihood, deviance, AIC, BIC, AICc, heterogeneity
quantification, residual heterogeneity test, and the meta-regression coefficients with
standard errors and p-values.

![Meta-regression tab showing covariate selection (left) and results tables including
model fit statistics and regression coefficients.\label{fig:metareg}](figures/fig_metareg.png){ width=90% }

# Usage

Install from GitHub and launch with two lines:

```r
# install.packages("pak")
pak::pkg_install("FrancoMSuarez/MetaStat")

MetaStat::run_app()
```

No installation is required to use the hosted version:
<https://francosuarez.shinyapps.io/metastats/>

A standalone Windows executable (built with Electron via the template by
@zarathucorp2025) is available from the GitHub releases page for users who prefer a
desktop application without an R installation.

# Acknowledgements

The authors thank the R community and the developers of the `meta`, `metafor`, `shiny`,
and `golem` packages, whose work forms the analytical and structural foundation of
`MetaStat`. Development was carried out at the Estadística y Biometría department of the
Facultad de Ciencias Agropecuarias, Universidad Nacional de Córdoba, Argentina.