# globepbcpexa

The **GLOBE score** for primary biliary cholangitis (PBC), original
continuous model (2015). It predicts transplant-free survival, meaning no
liver transplant and no death from any cause, in patients treated with
ursodeoxycholic acid (UDCA).

Lammers WJ, Hirschfield GM, Corpechot C, et al. Development and Validation
of a Scoring System to Predict Outcomes of Patients With Primary Biliary
Cirrhosis Receiving Ursodeoxycholic Acid Therapy. *Gastroenterology.*
2015;149(7):1804–1812.e4.
[doi:10.1053/j.gastro.2015.07.061](https://doi.org/10.1053/j.gastro.2015.07.061)

## Model

From the "Construction of the GLOBE score" section of the authors' accepted
manuscript
([University of Birmingham repository](https://pure-oai.bham.ac.uk/ws/files/22313085/Lammers_et_al_Development_validation_scoring_system_Gastroenterology_2015.pdf)):

```
GLOBE score = 0.044378 × age + 0.93982 × ln(bilirubin / ULN)
            + 0.335648 × ln(ALP / ULN) − 2.266708 × (albumin / LLN)
            − 0.002581 × platelets + 1.216865
S(t) = S0(t)^exp(GLOBE score)
S0 = 0.9652, 0.9385, 0.8429, 0.7361 at 3, 5, 10, 15 years
```

**Timing.** The paper's follow-up starts at the start of UDCA therapy, so
the 3-, 5-, 10- and 15-year horizons count from then. Age is at the start of
UDCA. The laboratory values are those after one year of UDCA.

This is the original continuous model. The paper's responder threshold
(score 0.30) and the age-specific thresholds shown on the authors' website
are not included.

## Inputs

| Field | Meaning |
|---|---|
| `age` | years, at the start of UDCA |
| `bilirubin`, `bilirubin_uln` | total bilirubin after 1 year of UDCA, and its upper limit of normal |
| `alp`, `alp_uln` | alkaline phosphatase after 1 year, and its upper limit of normal |
| `albumin`, `albumin_lln` | albumin after 1 year, and its lower limit of normal |
| `platelets` | 10⁹/L after 1 year (not divided by a reference limit) |

Each value and its limit must be in the same units. To enter multiples of
the limit directly, set the limit to 1.

## Outputs

- **`globe_score`:** unrounded.
- **`transplant_free_survival`, `risk_transplant_or_death`:** at 3, 5, 10
  and 15 years, as probabilities.
- **`calculator`:** the score to 2 decimals and survival to 0.1%, as the
  authors' calculator shows them.

## Validation

- **The authors' calculator** ([globalpbc.com/globe](https://www.globalpbc.com/globe/),
  13 November 2026): 11 cases, from low to very high risk, with bilirubin
  in µmol/L and in mg/dL. The scores and all 44 survival figures are
  identical at the calculator's precision.
- **The paper's Table 2:** the coefficients match its multivariable hazard
  ratios.

## Discrepancies in the paper

- **Worked example.** The manuscript's example gives age 50, bilirubin 1 × ULN,
  ALP 3 × ULN, albumin 1.5 × LLN and platelets 250, and prints score 0.64,
  S(5) 88.6% and S(10) 72.2%. For these inputs, both the printed equation
  and the authors' calculator give a score of −0.24 and survival of 95.1% and
  87.4%. The printed figures match age 70 with the same laboratory values
  (score 0.647). This package follows the equation and the calculator.
- **Platelet hazard ratio.** Table 2 gives 0.970 per 10 × 10⁹/L. The equation's
  coefficient implies 0.975, and the table's own confidence interval
  (0.961–0.990) is centred on 0.975.

The final journal article could not be checked: the publisher's page is
behind a bot check. No erratum is indexed in PubMed.

## Limitations

- The model was developed in UDCA-treated patients from European and North
  American centres.
- The laboratory values must come after one year of UDCA.

## Licence

This package implements the published equation independently; no code from
the authors' website was used. The accepted manuscript is CC BY-NC-ND. The R
code here is GPL-3. For research use; not a medical device.
