# Decision Tree Induction in Prolog for Cardiovascular Disease Diagnosis

[![Language: Prolog](https://img.shields.io/badge/Language-Prolog-blue.svg)](#implementation-and-induction-algorithm)
[![Course: Artificial Intelligence](https://img.shields.io/badge/Course-Artificial_Intelligence-003366.svg)](#authors--academic-context)
[![Dataset: 70k Patients](https://img.shields.io/badge/Dataset-Cardio_Data_(70k_records)-green.svg)](#dataset--data-preprocessing-pipeline)
[![Report: PDF](https://img.shields.io/badge/Project_Report-PDF_(ITA)-red.svg)](./docs/Relazione_AI_Sebastianelli.pdf)
[![Slides: PDF](https://img.shields.io/badge/Presentation-PDF_(ITA)-orange.svg)](./docs/Presentazione_AI_Sebastianelli.pdf)

Implementation from scratch of a recursive Decision Tree Induction algorithm written in **Prolog** (declarative/symbolic paradigm) applied to the diagnosis of cardiovascular diseases. 

The project investigates two fundamental splitting heuristics—**Gini Impurity** and **Information Gain (Entropy reduction)**—evaluating tree depth, branching behavior, computational overhead, and predictive accuracy on a balanced clinical dataset derived from 70,000 patient records.

Developed for the *Artificial Intelligence* (Intelligenza Artificiale) Master's course at **Università Politecnica delle Marche (UNIVPM)**, Academic Year 2024/2025.

> Project Documentation:
> * Technical Report (PDF, Italian): [Relazione_AI_Sebastianelli.pdf](./docs/Relazione_AI_Sebastianelli.pdf)
> * Presentation Slides (PDF, Italian): [Presentazione_AI_Sebastianelli.pdf](./docs/Presentazione_AI_Sebastianelli.pdf)
> * Source Code & Generated Trees: [src/](./src/) and [results/](./results/)

---

## Dataset & Data Preprocessing Pipeline

The primary dataset (`cardio.csv`) contains **70,000 patient records** described by demographic, physiological, and lifestyle features:
* `age`: Age in days (converted into years and discretized into standard age brackets).
* `gender`: Biological sex (1: female, 2: male).
* `height` & `weight`: Transformed into Body Mass Index (BMI) and categorized into four clinical ranges: *underweight, normal, overweight, obese*.
* `ap_hi` & `ap_lo`: Systolic and diastolic blood pressure (filtered for anomalous physiological ranges).
* `cholesterol` & `gluc`: Categorical levels (1: normal, 2: above normal, 3: well above normal).
* `smoke`, `alco`, `active`: Binary behavioral indicators.
* `cardio`: Target variable (0: absence, 1: presence of cardiovascular disease).

### Pipeline Steps in Prolog:
1. **CSV to Knowledge Base Conversion (`crea_database.pl`):** Built-in predicates using SWI-Prolog `library(csv)` to parse tabular records into dynamic Prolog facts `fact(Days, Gender, Height, Weight, SystolicBP, DiastolicBP, ...)`.
2. **Data Cleaning & Discretization (`crea_database_elaborato.pl`):** Computed BMI, excluded corrupted measurements (e.g., negative or impossible pressure values), and saved verified facts into `database_cardio_elaborato.pl`.
3. **Stratified Balancing & Split (`dividi_dataset.pl`):** Handled class distribution by shuffling positive and negative instances, extracting an exact balanced subset, and splitting it into a **70% Training Set** (`training_set.pl`) and a **30% Test Set** (`test_set.pl`).

---

## Implementation and Induction Algorithm

The core engine (`cardio_tree_induction.pl`) builds the tree structure recursively through declarative backtracking:

```prolog
induce_albero(Attributi, Esempi, t(Attributo, SAlberi)) :-
    sceglie_attributo_criterio(Attributi, Esempi, Attributo), !,
    del(Attributo, Attributi, Rimanenti),
    a(Attributo, Valori),
    induce_alberi(Attributo, Valori, Rimanenti, Esempi, SAlberi).
```

### Splitting Criteria Compared:
* **Gini Impurity:** Evaluates the probability of incorrect classification of a randomly chosen element:
  $$I_G(p) = 1 - \sum_{i=1}^{J} p_i^2$$
  The algorithm calculates the weighted sum of Gini indices for all attribute values and selects the minimum.
* **Information Gain (Entropy):** Measures the expected reduction in entropy:
  $$IG(T, a) = H(T) - H(T\vert{}a) = H(T) - \sum_{v \in \text{vals}(a)} \frac{\vert{}T_v\vert{}}{\vert{}T\vert{}} H(T_v)$$
  Selecting the attribute that maximizes information gain.

---

## Experimental Results & Comparison

Models were evaluated on a dedicated balanced test set of **20,220 unseen patient records**:

| Splitting Metric | Total Test Samples | Unclassified | True Positives (VP) | False Positives (FP) | True Negatives (VN) | False Negatives (FN) | Test Accuracy | Error Rate |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Gini Impurity** | 20,220 | 214 | 7,061 | 1,914 | 8,111 | 2,920 | **75.84%** | 24.16% |
| **Information Gain** | 20,220 | 439 | 6,971 | 1,913 | 8,031 | 2,866 | **75.87%** | 24.13% |

### Structural Observations:
* **Attribute Ordering Priority:**
  * *Gini:* Systolic BP -> Cholesterol -> Age -> BMI -> Glucose -> Alcohol -> Physical Activity -> Diastolic BP -> Gender.
  * *Information Gain:* Age -> Alcohol -> BMI -> Cholesterol -> Diastolic BP -> Gender -> Glucose -> Physical Activity -> Smoke -> Systolic BP.
* **Tree Topologies:** Gini produces a **deeper tree with fewer initial branches** and more intermediate refinement nodes. In contrast, Information Gain yields a **wider tree with broader initial branching**.
* **Accuracy Invariance:** Both heuristics achieve ~75.85% accuracy, demonstrating that data quality, feature discretizations, and intrinsic clinical variance matter more than the choice of splitting metric.

---

## Execution Guide

### Prerequisites
* SWI-Prolog (version 8.x or 9.x) installed on your system.

### Running the Project
1. Clone the repository:
   ```bash
   git clone https://github.com/Sebastianelli-Nicola/Prolog-Decision-Tree-Induction-Cardio.git
   cd Prolog-Decision-Tree-Induction-Cardio
   ```
2. Open SWI-Prolog in the project directory:
   ```bash
   swipl
   ```
3. Load and run the induction script:
   ```prolog
   ?- [src/cardio_tree_induction].
   ?- induce_albero(Albero).
   ?- stampa_matrice_di_confusione.
   ```

---

## Author & Academic Context

* **Author:** **Nicola Sebastianelli** — [GitHub](https://github.com/Sebastianelli-Nicola)
* **Institution:** Università Politecnica delle Marche (UNIVPM)
* **Degree:** M.Sc. in Computer and Automation Engineering (Ingegneria Informatica e dell'Automazione)
* **Course:** Artificial Intelligence (Intelligenza Artificiale), A.Y. 2024/2025
