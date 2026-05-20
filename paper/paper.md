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
    affiliation: "1, 2"
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
---

# Summary

A systematic review (SR) synthesizes evidence from a research question using
comprehensive and reproducible methods to search, identify, select, evaluate, and extract
data from published primary studies. Meta-analysis is the statistical technique that
combines quantitative results from those studies—all addressing the same research
question—to produce a pooled effect estimate together with a confidence interval (CI)
that reflects the weighted mean of the included primary studies and provides a measure of
the reliability of the combined estimate [@zhai2024]. By pooling results across studies,
meta-analyses increase statistical power, improve precision, and can answer questions that
individual trials cannot address due to insufficient sample size. When integrated with a
systematic review they produce high-quality evidence that informs and facilitates
evidence-based decision-making [@allami2021].

Carrying out a meta-analysis requires proficiency in statistical software. Several
programs support this workflow—SAS [@sas2023], R [@rcoreteam2024], STATA
[@statacorp2015], SPSS [@ibm2017], and the Cochrane web calculator [@revman2025]—but
researchers who need supplementary analyses such as meta-regression or publication-bias
diagnostics must often switch between multiple tools [@tantry2021]. Within R, the
packages `meta` [@balduzzi2019] and `metafor` [@viechtbauer2010] provide a comprehensive
suite of functions for meta-analysis and are widely used in research. However, neither
package ships a graphical user interface (GUI), and applying them requires proficiency in
R programming—a barrier for investigators who lack the time or resources to learn to
code.

`MetaStat` was developed to close this gap. It combines the analytical depth of R's
meta-analysis ecosystem with the accessibility of a Shiny [@chang2024] web application,
allowing researchers to execute the full meta-analysis workflow—data ingestion, model
fitting, result inspection, and diagnostic plotting—through a point-and-click interface
that requires no programming experience. The application is freely available as an installable R package
from GitHub, and as a hosted web application on ShinyApps.io at
<https://francosuarez.shinyapps.io/metastats/>.

# Statement of Need

Evidence synthesis is a growing methodological requirement across scientific
disciplines—from clinical medicine and public health to agricultural sciences, ecology,
and social sciences. The increasing volume of primary studies makes it both possible and
necessary to combine results quantitatively, yet the community of potential users of
meta-analysis is far larger than the community of researchers comfortable with R
programming.

Existing options present a clear trade-off. Command-line tools such as `meta` and
`metafor` are analytically complete but require programming expertise. GUI-based
commercial options (SAS, STATA, SPSS) impose licensing costs that exclude many
institutions, particularly in the Global South. Free alternatives such as RevMan
[@revman2025] focus on clinical trial data and offer limited support for meta-regression
and heterogeneity estimation. As a consequence, many researchers either avoid
meta-analysis entirely or conduct partial analyses with whichever tool is most
familiar—compromising both rigour and reproducibility.

`MetaStat` addresses all of these limitations at once. It is free and open-source,
integrates the full meta-analysis workflow in a single application, and requires no
software installation when used through the hosted version. Because it is built as an R
package using the `golem` framework [@fay2023], the underlying analysis code is
versioned, testable, and auditable by anyone with R knowledge—supporting reproducibility
even when the end user interacts only with the GUI. This combination of accessibility,
analytical completeness, and open-source transparency is, to the authors' knowledge,
unique among freely available meta-analysis tools.

The application is particularly relevant for the Latin American research context, where
large multi-environment agricultural experiments generate datasets well-suited to
meta-analysis but where R programming skills are less widely distributed among
practitioners. MetaStat was developed at the Department of Statistics and Biometry of
the Faculty of Agricultural Sciences, Universidad Nacional de Córdoba, Argentina, with
this user base directly in mind.

# Implementation

`MetaStat` is structured as an R package using the `golem` framework [@fay2023], which
enforces a modular Shiny architecture: each analytical model is implemented as an
independent Shiny module, ensuring clean separation of concerns and making it
straightforward to add new models in future versions. The framework also provides a
standardised project layout with configuration management (`config`), internal utility
functions (`fct_utils.R`), and deployment targets for both web and desktop platforms.

The user interface is constructed with `bslib` [@sievert2024] using a `page_navbar`
layout and the Minty Bootswatch theme. Navigation tabs for model fitting, plots, and
meta-regression are programmatically hidden until data have been successfully loaded,
preventing the navigation errors that arise when users attempt to run analyses before
uploading their dataset. Dynamic UI visibility throughout the application is managed by
`shinyjs` [@attali2021].

All statistical computations are delegated to the `meta` package [@balduzzi2019], which
in turn calls `metafor` [@viechtbauer2010] for mixed-effects and meta-regression models.
`MetaStat` does not reimplement any statistical logic; it acts as an interface layer that
collects user inputs, constructs the appropriate `meta` function call, and formats the
resulting objects for display. This design ensures that analytical correctness is
inherited directly from well-validated, peer-reviewed packages, and that future
improvements to those packages are automatically available to `MetaStat` users.

Results tables are rendered as interactive `DT` [@xie2023] widgets, allowing users to
sort, filter, and search within results without leaving the application. All plots are
produced by `meta`'s `forest()`, `funnel()`, and `baujat()` functions via base R
graphics. Forest plot height is computed dynamically in the utility function
`save_forest_plot_png()` based on the number of studies and the number of subgroups,
ensuring legibility regardless of dataset size.

The standalone Windows application is built using the Electron-based template provided
by Zarathucorp [@zarathucorp2025], which bundles R, the application package, and all
dependencies into a single self-contained executable. This deployment target requires
no prior R installation, extending the reach of the application to users who work in
environments where installing R is not straightforward.

# Functionality

## Workflow and Navigation

Upon launching the application, the user is presented with the home screen
(\autoref{fig:home}), which displays the MetaStat logo and two buttons for selecting the
outcome type: *Continuous Data* or *Discrete Data*. The choice determines which set of
models is available throughout the session. The top navigation bar becomes fully
populated only after data are successfully loaded, guiding the user through the analysis
in a logical sequence.

![MetaStat home screen. The user selects the type of outcome variable to begin the
session.\label{fig:home}](figures/fig_home.png){ width=90% }

## Data Input

After selecting an outcome type, the user navigates to the *Data* tab (\autoref{fig:data}).
`MetaStat` accepts tabular datasets in three formats: `.csv`, `.xlsx` (processed with
`readxl`), and `.txt`. The sidebar offers configurable options for column separator
(comma, semicolon, or tab), decimal character (period or comma), and the presence of a
header row. Automatic type coercion is applied to numeric columns detected from the
decimal separator setting. Once loaded, the complete dataset is displayed in a `DT`
interactive table, allowing the user to verify that columns and values were parsed
correctly before proceeding.

![Data loading panel. Format and separator options appear in the sidebar; the main panel
shows an interactive preview of the uploaded dataset.\label{fig:data}](figures/fig_data.png){ width=90% }

## Meta-Analysis Models

`MetaStat` implements ten meta-analysis models, grouped by outcome type and implemented
in dedicated Shiny modules:

**Continuous outcomes** (`mod_cociente_medias`, `mod_correlaciones`, `mod_difdemedias`,
`mod_dm_estandar`, `mod_medias`):

- Ratio of means
- Correlations
- Mean difference
- Standardised mean difference
- Single mean

**Discrete outcomes** (`mod_chance`, `mod_Arcoseno`, `mod_dif_risk`, `mod_proporcion`,
`mod_risk_rel`):

- Odds ratio
- Arcsine transformation (Freeman–Tukey)
- Risk difference
- Single proportion
- Risk ratio

Once a model tab is selected, the sidebar displays dropdown menus populated
automatically from the column names of the loaded dataset (\autoref{fig:model}). The
user maps each model parameter to the corresponding dataset column, selects fixed-effect
or random-effects estimation, and optionally designates a subgroup variable. Multiple
heterogeneity estimators are available (DerSimonian–Laird, REML, ML, Hedges, and others,
depending on the model). The model is fitted when the user clicks the *Run Model* button.

![Model configuration panel. Dropdown menus in the sidebar are populated from the
dataset column names. Results appear as interactive tables once the model is
fitted.\label{fig:model}](figures/fig_model.png){ width=90% }

## Results Tables

After fitting, `MetaStat` displays up to nine structured results tables:

1. Summary of individual study estimates: point estimate, confidence interval,
   z-statistic, p-value, and weight
2. Number of combined and individual studies
3. Overall pooled effect estimate, confidence interval, and p-value
4. Heterogeneity quantification: τ², H, and I²
5. Test of heterogeneity: Q-statistic and p-value
6. Heterogeneity estimation method
7. Per-subgroup effect estimates, confidence intervals, and p-values *(subgroup models)*
8. Per-subgroup heterogeneity statistics *(subgroup models)*
9. Test for differences between subgroups *(subgroup models)*

All tables are rendered as interactive `DT` widgets and support sorting and filtering.

## Visualisation

Three diagnostic plots are generated from the fitted model and are available on
dedicated tabs (\autoref{fig:plots}). Each plot can be downloaded as a `.png` file
(forest plots can additionally be exported as `.pdf`):

- **Forest plot** — displays individual study effect estimates with confidence intervals,
  and the pooled effect represented as a diamond. Plot height is computed dynamically
  based on the number of studies (and subgroups) to maintain legibility for both small
  and large datasets.
- **Funnel plot** — plots study-level precision (standard error) against the effect
  estimate, supporting visual assessment of publication bias.
- **Baujat plot** — plots each study's contribution to overall heterogeneity against its
  influence on the pooled estimate, facilitating identification of influential or
  outlying studies for sensitivity analysis.

![Visualisation tabs. The forest plot (top) shows individual and pooled estimates; the
funnel and Baujat plots (bottom) support publication-bias and influence
assessment.\label{fig:plots}](figures/fig_plots.png){ width=90% }

## Meta-Regression

The *Meta-regression* tab (\autoref{fig:metareg}) allows the user to extend the fitted
model by adding a continuous or categorical moderator variable selected from the dataset
columns. `MetaStat` calls `meta::metareg()`, which fits a mixed-effects model via
`metafor`, and returns four results tables:

1. Model fit statistics: log-likelihood, deviance, AIC, BIC, AICc
2. Heterogeneity quantification for the meta-regression model: τ², SE(τ²), I², H², R²
3. Residual heterogeneity test: Q_E statistic and p-value
4. Meta-regression coefficients: estimate, standard error, p-value, 95% CI

A bubble plot is also produced, in which each study is represented by a bubble scaled
to its weight, overlaid on the fitted regression line. This visualisation aids
interpretation of the relationship between the moderator and the effect size across
studies.

![Meta-regression tab. The covariate is selected in the sidebar; four results tables
and a bubble plot are displayed in the main panel.\label{fig:metareg}](figures/fig_metareg.png){ width=90% }

# Usage

`MetaStat` can be installed from GitHub and launched with two lines of R code:

```r
# install.packages("pak")
pak::pkg_install("FrancoMSuarez/MetaStat")
MetaStat::run_app()
```

No installation is required to use the hosted version, which is accessible from any
modern web browser:

<https://francosuarez.shinyapps.io/metastats/>



# Acknowledgements

The authors thank the R community and the developers of the `meta`, `metafor`, `shiny`,
and `golem` packages, whose work forms the analytical and structural foundation of
`MetaStat`. This work was carried out at the Estadística y Biometría department of the
Facultad de Ciencias Agropecuarias, Universidad Nacional de Córdoba, and the Grupo
Vinculado Unidad de Fitopatología y Modelización Agrícola, INTA-CONICET, Córdoba,
Argentina.

# References

