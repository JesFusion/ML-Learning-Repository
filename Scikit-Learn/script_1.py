# POSTGRE_ML_CONNECT


import os
import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier, export_text
from sklearn.metrics import accuracy_score, classification_report


class Logistic_Regression_SVC_Decision_Trees:

    def __init__(self, the_connection: create_engine):
        
        self.connection = the_connection

        self.class_data = {}

        self.train_test_and_split(conn = self.connection)

    
    
    def loading_dataset(
        self,

        sql_query: str,
        
        the_connection: create_engine
    ) -> pd.DataFrame:
            
        if False:

            cancer_bunch_dset = load_breast_cancer(as_frame = True).frame

            cancer_bunch_dset.to_sql(

                name = "breast_cancer_dataset",

                con = self.connection,

                if_exists = "replace",

                index = False,
            )

        dataset = pd.read_sql(
            sql = sql_query,
            con = the_connection
        )

        self.class_data['names_of_features'] = list(dataset.columns)[:-1]
        
        self.class_data['names_of_targets'] = np.array(['malignant', 'benign'])

        return dataset
    
    
    
    def train_test_and_split(self, conn: create_engine):

        breast_cancer_dataset = self.loading_dataset(

            sql_query = "SELECT * FROM breast_cancer_dataset",

            the_connection = conn
        )

        features_X = breast_cancer_dataset.drop(
            columns = "target",
            axis = 1
        )

        target_y = breast_cancer_dataset['target']

        """
        train_test_split splits our data into training and test sets.

        test_size = 0.2: 20% of data goes to testing, 80% for training

        random_state = 42: Seeds the random number generator so splits are reproducible. Your results will match mine every single time

        stratify = y: Ensures the class ratio (malignant/benign) is preserved in both train and test sets. Critical for medical datasets
        """

        x_tr, x_t, y_tr, y_t = train_test_split(
            features_X,
            target_y,
            test_size = 0.22,
            random_state = 20,
            stratify = target_y
        )

        """
        
        We scale the data ONCE and reuse it across all 3 segments.
        
        LogisticRegression and SVM are both distance/gradient sensitive —
        they behave poorly when features are on wildly different scales.
        Decision Trees don't need scaling (they split on thresholds), but
        it doesn't hurt them either, so we apply it uniformly for clean code.

        We fit the scaler ONLY on X_train.
        If we fit on the full dataset, we "leak" test data statistics
        into our preprocessing — that's cheating. The test set must stay
        invisible until the final evaluation

        """


        the_scaler = StandardScaler()

        # .fit_transform() = learn the mean/std from X_train, then transform it
        x_tr = the_scaler.fit_transform(X = x_tr)

        # .transform() = apply the SAME mean/std learned from training to test data
        
        # We do NOT call .fit() here. The test set doesn't get to influence scaling.

        x_t = the_scaler.transform(X = x_t)

        names = ['X-train', 'X-test', 'Y-train', 'Y-test']

        values = [x_tr, x_t, y_tr, y_t]

        for x in range(len(names)):

            self.class_data[names[x]] = values[x]

        
        return None
    

    
    def logistic_regression(self):

        X_train = self.class_data['X-train']

        y_train = self.class_data['Y-train']

        '''
        
        Despite the name, LogisticRegression IS a classifier

        It models the PROBABILITY of belonging to a class using the sigmoid function,
        then thresholds at 0.5 to make a hard class prediction.

        Key Parameters:
        max_iter=1000: The solver (optimizer) needs iterations to converge.
        The default (100) is often too low for real datasets — you'll get a
        ConvergenceWarning. 1000 is a safe default.
        
        random_state=20: Some solvers use randomness. We pin it for reproducibility.
        
        C=1.0 (default): The regularization strength. Lower C = stronger regularization
        (simpler model). Higher C = weaker regularization (model fits training data harder).
        It's the INVERSE of regularization strength — counterintuitive but important
        '''

        logistic_regression_model = LogisticRegression(
            max_iter = 1000,
            random_state = 20
        )

        # training on the test data...
        # It finds the optimal weights (coefficients) that maximize the probability of correct classifications across all training samples
        logistic_regression_model.fit(
            X = X_train,
            y = y_train
        )

        return logistic_regression_model
    

    def support_vector_machine(self):

        """

        SVC = Support Vector Classifier. It finds the maximum-margin hyperplane that separates the two classes.

        Key Parameters:
        1. kernel='rbf': The Radial Basis Function kernel. This is the "kernel trick" in action — it implicitly maps data to infinite dimensions to find non-linear boundaries. It's the default and best general-purpose choice.
        
        2. C=1.0 (default): Same regularization trade-off as LogisticRegression.
        
        Low C = wider margin (more misclassifications tolerated = simpler model).
        
        High C = narrower margin (fewer misclassifications = risk of overfitting).
        
        3. gamma='scale' (default): Controls how far the influence of a single training sample reaches

        'scale' = 1 / (n_features * X.var()). Safe default

        """

        initialize = True

        if initialize:

            X_train = self.class_data['X-train']

            y_train = self.class_data['Y-train']



        # ===================================== Radial Basis Function (RBF) Model =====================================

        svm_rbf_model = SVC(
            kernel = 'rbf', # (Radial Basis Function): The default and most powerful. It can create complex, non-linear boundaries

            random_state = 20
        )

        svm_rbf_model.fit(
            X = X_train,
            y = y_train
        )


        # ===================================== Linear Model =====================================

        """
        Now we test the 'linear' kernel — no mapping trick, just a straight hyperplane.
        
        Useful as a baseline to confirm if the data is already linearly separable (which it roughly is for this dataset)
        """
        svm_linear_model = SVC(
            kernel = 'linear',
            random_state = 20
        )

        svm_linear_model.fit(
            X = X_train,
            y = y_train
        )



        # ===================================== Polynomial Model =====================================

        '''
        The 'poly' kernel uses polynomial combinations of features.
        
        degree=3: Uses cubic polynomial combinations (x1^3, x1^2*x2, etc.).
        
        It's more powerful than linear but slower and prone to overfitting on small datasets
        '''

        svm_poly_model = SVC(
            kernel = 'poly',
            random_state = 20
        )

        svm_poly_model.fit(
            X = X_train,
            y = y_train
        )

            
        return svm_rbf_model, svm_linear_model, svm_poly_model








    def model_accuracies(self):

        initialize = True
       
        if initialize:

            x_test = self.class_data['X-test']

            y_test = self.class_data['Y-test']
        
            log_model = self.logistic_regression()

            svm_RBF, svm_LINEAR, svm_POLY = self.support_vector_machine()
        


        # ===================================== LOGISTIC REGRESSION =====================================

        lr_x_test = x_test.copy()

        lr_y_test = y_test.copy()

        # .predict() uses the learned weights to classify the test samples.
        
        # Internally it runs the sigmoid, gets probabilities, then rounds to 0 or 1
        
        logistic_Y_prediction = log_model.predict(X = lr_x_test)


        # obtaining the accuracy of model on the test set...
        log_model_acc = accuracy_score(
            y_true = lr_y_test,
            y_pred = logistic_Y_prediction
        )

        """

        classification_report gives us Precision, Recall, and F1-Score
        broken down by class.
        
        This is far more informative than raw accuracy,
        especially for medical data where False Negatives (missing a cancer case) are far more dangerous than False Positives.

        Precision: Of all we PREDICTED as malignant, how many actually were?
        
        Recall: Of all ACTUAL malignant cases, how many did we catch?

        F1-Score: The harmonic mean of Precision and Recall. Balances both
        
        target_names: Maps 0 → 'malignant' and 1 → 'benign' in the output for readability

        """

        the_classification_report = classification_report(
            y_true = lr_y_test,

            y_pred = logistic_Y_prediction,

            target_names = self.class_data['names_of_targets'],
            
            output_dict = True # export as a DataFrame
        )

        the_classification_report = pd.DataFrame(the_classification_report).T.to_markdown(tablefmt = 'fancy_grid')

        f_importance = np.abs(log_model.coef_[0])

        top_coefs = np.argsort(a = f_importance)[::-1][:3]

        influential_features = ""

        for x in top_coefs:

            influential_features += f"{self.class_data['names_of_features'][x]}: {log_model.coef_[0][x]:.4f}\n"

            

        

        # ===================================== Support Vector Machine =====================================

        svm_x_test = x_test.copy()

        svm_y_test = y_test.copy()

        # making predictions with SVM 'rbf' model...

        rbf_predict = svm_RBF.predict(X = svm_x_test)

        rbf_accuracy = accuracy_score(
            y_true = svm_y_test,
            y_pred = rbf_predict
        )


        linear_predict = svm_LINEAR.predict(X = svm_x_test)

        linear_accuracy = accuracy_score(
            y_true = svm_y_test,
            y_pred = linear_predict
        )



        poly_predict = svm_POLY.predict(X = svm_x_test)

        poly_accuracy = accuracy_score(
            y_true = svm_y_test,
            y_pred = poly_predict
        )

        the_kernels = {

            'rbf': rbf_accuracy,
            
            'linear': linear_accuracy,

            'poly': poly_accuracy
        }

        the_best_kernel = max(the_kernels, key = the_kernels.get)



















        print(f'''
===================================== Logistic Regression =====================================
              
Accuracy: {log_model_acc:.3f} ({(log_model_acc * 100):.2f}%)

Detailed Report:

{the_classification_report}


Top 3 Most Influential Features (by absolute coefficient weight):

{influential_features}



===================================== Support Vector Machine =====================================

SVM (kernel = 'rbf') Accuracy: {rbf_accuracy:.4f} ({(rbf_accuracy * 100):.2f}%)

SVM (kernel = 'linear') Accuracy: {linear_accuracy:.4f} ({(linear_accuracy * 100):.2f}%)

SVM (kernel = 'poly') Accuracy: {poly_accuracy:.4f} ({(poly_accuracy * 100):.2f}%)


RBF Support Vectors: {svm_RBF.n_support_} (one count per class)

Only these {sum(svm_RBF.n_support_)} training samples define the entire decision boundary

Best SVM kernel for this dataset is the '{the_best_kernel}' kernel with {(the_kernels[the_best_kernel] * 100):.2f}% accuracy
        ''')




        

        

        
















if __name__ == '__main__':

    model_class = Logistic_Regression_SVC_Decision_Trees(
    
    the_connection = create_engine(
        url = os.environ.get("POSTGRE_ML_CONNECT")

    ).connect())

    model_class.model_accuracies()

    




























































