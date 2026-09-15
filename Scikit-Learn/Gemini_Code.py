# =============================================================================
# MODULE 5: SUPERVISED LEARNING — CLASSIFICATION
# Segments: Logistic Regression | SVM | Decision Trees
# =============================================================================
# [Comment: We are using the breast cancer dataset. It's a real, clean, binary
# classification dataset (Malignant vs Benign) built into scikit-learn.
# Binary = perfect for comparing all 3 classifiers we're learning today.]

import numpy as np
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier, export_text
from sklearn.metrics import accuracy_score, classification_report

# --- GLOBAL SETUP: LOAD & SPLIT DATA ONCE ---

# [Comment: load_breast_cancer() returns a Bunch object.
# .data is the feature matrix (X), .target is the label array (y).
# .target_names tells us what 0 and 1 mean: ['malignant', 'benign']]
cancer = load_breast_cancer()

X = cancer.data    # Shape: (569 samples, 30 features)
y = cancer.target  # 0 = malignant, 1 = benign

print("=" * 65)
print("  DATASET: Breast Cancer Wisconsin")
print(f"  Samples: {X.shape[0]} | Features: {X.shape[1]}")
print(f"  Classes: {cancer.target_names}")
print("=" * 65)

# [Comment: train_test_split splits our data into training and test sets.
# test_size=0.2: 20% of data goes to testing, 80% for training.
# random_state=42: Seeds the random number generator so splits are
#   reproducible. Your results will match mine every single time.
# stratify=y: Ensures the class ratio (malignant/benign) is preserved
#   in both train and test sets. Critical for medical datasets.]
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

# [Comment: We scale the data ONCE and reuse it across all 3 segments.
# WHY: LogisticRegression and SVM are both distance/gradient sensitive —
# they behave poorly when features are on wildly different scales.
# Decision Trees don't need scaling (they split on thresholds), but
# it doesn't hurt them either, so we apply it uniformly for clean code.
#
# CRITICAL RULE: We fit the scaler ONLY on X_train.
# If we fit on the full dataset, we "leak" test data statistics
# into our preprocessing — that's cheating. The test set must stay
# invisible until the final evaluation.]
scaler = StandardScaler()

# .fit_transform() = learn the mean/std from X_train, then transform it
X_train_scaled = scaler.fit_transform(X=X_train)

# .transform() = apply the SAME mean/std learned from training to test data
# We do NOT call .fit() here. The test set doesn't get to influence scaling.
X_test_scaled = scaler.transform(X=X_test)


# =============================================================================
print("\n--- SEGMENT 1: LOGISTIC REGRESSION ---\n")
# =============================================================================
# [Comment: Despite the name, LogisticRegression IS a classifier.
# It models the PROBABILITY of belonging to a class using the sigmoid function,
# then thresholds at 0.5 to make a hard class prediction.
#
# Key Parameters:
# max_iter=1000: The solver (optimizer) needs iterations to converge.
#   The default (100) is often too low for real datasets — you'll get a
#   ConvergenceWarning. 1000 is a safe default.
# random_state=42: Some solvers use randomness. We pin it for reproducibility.
# C=1.0 (default): The regularization strength. Lower C = stronger regularization
#   (simpler model). Higher C = weaker regularization (model fits training data harder).
#   It's the INVERSE of regularization strength — counterintuitive but important.]
log_reg = LogisticRegression(max_iter=1000, random_state=42)

# [Comment: .fit() is where the model learns. It finds the optimal weights
# (coefficients) that maximize the probability of correct classifications
# across all training samples.]
log_reg.fit(X=X_train_scaled, y=y_train)

# [Comment: .predict() uses the learned weights to classify the test samples.
# Internally it runs the sigmoid, gets probabilities, then rounds to 0 or 1.]
y_pred_lr = log_reg.predict(X=X_test_scaled)

# [Comment: accuracy_score = (correct predictions) / (total predictions)
# Simple but useful as a first-pass metric.]
lr_accuracy = accuracy_score(y_true=y_test, y_pred=y_pred_lr)

print(f"  Logistic Regression Accuracy: {lr_accuracy:.4f} ({lr_accuracy*100:.2f}%)\n")

# [Comment: classification_report gives us Precision, Recall, and F1-Score
# broken down by class. This is far more informative than raw accuracy,
# especially for medical data where False Negatives (missing a cancer case) are far more dangerous than False Positives.
#
# Precision: Of all we PREDICTED as malignant, how many actually were?
# Recall: Of all ACTUAL malignant cases, how many did we catch?
# F1-Score: The harmonic mean of Precision and Recall. Balances both.
# target_names: Maps 0 → 'malignant' and 1 → 'benign' in the output for readability.]
print("  Detailed Report:")
print(classification_report(
    y_true=y_test,
    y_pred=y_pred_lr,
    target_names=cancer.target_names
))

# .coef_ gives us the learned weight for each of the 30 features.
# A large positive weight means that feature strongly pushes toward class 1 (benign).
# A large negative weight pushes toward class 0 (malignant).
# This interpretability is one of Logistic Regression's biggest selling points
print("  Top 3 Most Influential Features (by absolute coefficient weight):")
feature_importance = np.abs(log_reg.coef_[0])
top_indices = np.argsort(a=feature_importance)[::-1][:3]
for i in top_indices:
    print(f"    → {cancer.feature_names[i]}: {log_reg.coef_[0][i]:.4f}")


# =============================================================================
print("\n--- SEGMENT 2: SUPPORT VECTOR MACHINE (SVC) ---\n")
# =============================================================================
# [Comment: SVC = Support Vector Classifier. It finds the maximum-margin
# hyperplane that separates the two classes.
#
# Key Parameters:
# kernel='rbf': The Radial Basis Function kernel. This is the "kernel trick"
#   in action — it implicitly maps data to infinite dimensions to find
#   non-linear boundaries. It's the default and best general-purpose choice.
# C=1.0 (default): Same regularization trade-off as LogisticRegression.
#   Low C = wider margin (more misclassifications tolerated = simpler model).
#   High C = narrower margin (fewer misclassifications = risk of overfitting).
# gamma='scale' (default): Controls how far the influence of a single
#   training sample reaches. 'scale' = 1 / (n_features * X.var()). Safe default.]
svm_rbf = SVC(kernel='rbf', random_state=42)
svm_rbf.fit(X=X_train_scaled, y=y_train)
y_pred_svm_rbf = svm_rbf.predict(X=X_test_scaled)
svm_rbf_accuracy = accuracy_score(y_true=y_test, y_pred=y_pred_svm_rbf)
print(f"  SVM (kernel='rbf')    Accuracy: {svm_rbf_accuracy:.4f} ({svm_rbf_accuracy*100:.2f}%)")

# Now we test the 'linear' kernel — no mapping trick, just a straight hyperplane. Useful as a baseline to confirm if the data is already linearly separable (which it roughly is for this dataset)
svm_linear = SVC(kernel='linear', random_state=42)
svm_linear.fit(X=X_train_scaled, y=y_train)
y_pred_svm_linear = svm_linear.predict(X=X_test_scaled)
svm_linear_accuracy = accuracy_score(y_true=y_test, y_pred=y_pred_svm_linear)
print(f"  SVM (kernel='linear') Accuracy: {svm_linear_accuracy:.4f} ({svm_linear_accuracy*100:.2f}%)")

# [Comment: The 'poly' kernel uses polynomial combinations of features.
# degree=3: Uses cubic polynomial combinations (x1^3, x1^2*x2, etc.).
# More powerful than linear but slower and prone to overfitting on small datasets.]
svm_poly = SVC(kernel='poly', degree=3, random_state=42)
svm_poly.fit(X=X_train_scaled, y=y_train)
y_pred_svm_poly = svm_poly.predict(X=X_test_scaled)
svm_poly_accuracy = accuracy_score(y_true=y_test, y_pred=y_pred_svm_poly)
print(f"  SVM (kernel='poly')   Accuracy: {svm_poly_accuracy:.4f} ({svm_poly_accuracy*100:.2f}%)")

# [Comment: .support_vectors_ are the actual training samples that sit on the
# margin boundary — the "houses on the edge of the street" from our analogy.
# The SVM decision boundary is ENTIRELY defined by these points.]
print(f"\n  RBF Support Vectors: {svm_rbf.n_support_} (one count per class)")
print(f"  → Only these {sum(svm_rbf.n_support_)} training samples define the entire decision boundary.\n")

print("  Best SVM kernel for this dataset:")
kernels = {'rbf': svm_rbf_accuracy, 'linear': svm_linear_accuracy, 'poly': svm_poly_accuracy}
best_kernel = max(kernels, key=kernels.get)
print(f"    → '{best_kernel}' with {kernels[best_kernel]*100:.2f}% accuracy")


# =============================================================================
print("\n--- SEGMENT 3: DECISION TREE ---\n")
# =============================================================================
# [Comment: DecisionTreeClassifier builds a flowchart-like model by
# recursively splitting the data on the feature that produces the
# "purest" child nodes (measured by Gini impurity by default).
#
# Key Parameters:
# criterion='gini': Gini Impurity measures how often a randomly chosen
#   element would be incorrectly labeled if randomly labeled by the class
#   distribution. Ranges from 0 (pure) to 0.5 (maximally impure for binary).
#   Alternative: criterion='entropy' (Information Gain). Both work similarly.
# random_state=42: Handles tie-breaking when multiple features give equal splits.]

# --- FIRST: Let it grow unconstrained to demonstrate overfitting ---
dt_overfit = DecisionTreeClassifier(criterion='gini', random_state=42)
dt_overfit.fit(X=X_train_scaled, y=y_train)

y_pred_dt_train = dt_overfit.predict(X=X_train_scaled)  # Predict on TRAINING data
y_pred_dt_test  = dt_overfit.predict(X=X_test_scaled)   # Predict on TEST data

train_accuracy = accuracy_score(y_true=y_train, y_pred=y_pred_dt_train)
test_accuracy  = accuracy_score(y_true=y_test,  y_pred=y_pred_dt_test)

print("  UNCONSTRAINED TREE (Overfitting Demonstration):")
print(f"    Training Accuracy : {train_accuracy:.4f} ({train_accuracy*100:.2f}%) ← Memorized everything")
print(f"    Test Accuracy     : {test_accuracy:.4f} ({test_accuracy*100:.2f}%)  ← Falls apart on new data")
print(f"    Tree Depth        : {dt_overfit.get_depth()} levels deep")
print(f"    Number of Leaves  : {dt_overfit.get_n_leaves()} leaf nodes")
print(f"\n    ⚠  Gap = {(train_accuracy - test_accuracy)*100:.2f}% — That gap IS the overfitting.\n")

# --- SECOND: Constrain it with max_depth to fix overfitting ---
# [Comment: max_depth=4: We cap the tree at 4 levels of questions.
# This forces the model to find the 4 MOST IMPORTANT splits rather than
# memorizing every training sample. It generalizes much better.
# min_samples_split=10: A node must have at least 10 samples to be
# allowed to split further. Prevents the tree from chasing tiny clusters
# of 2-3 samples that are likely noise, not signal.]
dt_pruned = DecisionTreeClassifier(
    criterion='gini',
    max_depth=4,
    min_samples_split=10,
    random_state=42
)
dt_pruned.fit(X=X_train_scaled, y=y_train)

y_pred_pruned_train = dt_pruned.predict(X=X_train_scaled)
y_pred_pruned_test  = dt_pruned.predict(X=X_test_scaled)

pruned_train_acc = accuracy_score(y_true=y_train, y_pred=y_pred_pruned_train)
pruned_test_acc  = accuracy_score(y_true=y_test,  y_pred=y_pred_pruned_test)

print("  PRUNED TREE (max_depth=4, min_samples_split=10):")
print(f"    Training Accuracy : {pruned_train_acc:.4f} ({pruned_train_acc*100:.2f}%)")
print(f"    Test Accuracy     : {pruned_test_acc:.4f} ({pruned_test_acc*100:.2f}%)")
print(f"    Tree Depth        : {dt_pruned.get_depth()} levels deep")
print(f"    Number of Leaves  : {dt_pruned.get_n_leaves()} leaf nodes")
print(f"\n    ✅ Gap = {(pruned_train_acc - pruned_test_acc)*100:.2f}% — Much healthier generalization.\n")

# [Comment: export_text() renders the decision tree as a text-based flowchart.
# feature_names: Maps feature indices to human-readable names so we can
#   understand WHAT the tree is actually asking at each split.
# max_depth=3: We only print the top 3 levels to keep terminal output readable.]
print("  Decision Tree Flowchart (Top 3 Levels of Questions):\n")
tree_rules = export_text(
    decision_tree=dt_pruned,
    feature_names=list(cancer.feature_names),
    max_depth=3
)
print(tree_rules)

# [Comment: feature_importances_ tells us how much each feature contributed
# to reducing impurity across all splits in the tree.
# Values sum to 1.0. Higher = more important.
# This is one of the most valuable outputs of a Decision Tree — free feature selection.]
print("  Top 5 Most Important Features (by Gini impurity reduction):")
importances = dt_pruned.feature_importances_
top5_indices = np.argsort(a=importances)[::-1][:5]
for rank, i in enumerate(top5_indices, start=1):
    print(f"    {rank}. {cancer.feature_names[i]}: {importances[i]:.4f}")


# =============================================================================
print("\n" + "=" * 65)
print("  FINAL SCOREBOARD — ALL 3 CLASSIFIERS")
print("=" * 65)
# =============================================================================

results = {
    "Logistic Regression":       lr_accuracy,
    f"SVM (kernel='{best_kernel}')": kernels[best_kernel],
    "Decision Tree (pruned)":    pruned_test_acc,
}

for model_name, acc in sorted(results.items(), key=lambda x: x[1], reverse=True):
    bar = "█" * int(acc * 40)
    print(f"  {model_name:<30} {acc*100:.2f}%  {bar}")

print("=" * 65)
print("\n  Key Takeaways:")
print("  → Logistic Regression: Fast, interpretable, solid baseline.")
print("  → SVM: Powerful on small/medium datasets. Kernel choice matters.")
print("  → Decision Tree: Interpretable but needs pruning. Foundation of ensembles.")
print()