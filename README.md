# Welcome to my Repo: `ML-Learning-Repository`

This Repo is a personal collection of small learning projects, reference notes, and example code used while learning and practicing the langiages and tools needed to become a __*Machine Learning Enginner*__. The materials are organized loosely by topic and are intended as lightweight, runnable examples and notes you can read and adapt.

## Repo Tree Structure
```
.
├── assignment.txt
├── build.sh
├── Docker
│   ├── Docker_Folders
│   │   ├── fol_2_3
│   │   │   ├── build.sh
│   │   │   ├── cool.flr
│   │   │   ├── Dockerfile
│   │   │   ├── file.py
│   │   │   └── requirements.txt
│   │   └── Previous_folders
│   │       ├── fol_2_1
│   │       │   ├── build.sh
│   │       │   ├── Dockerfile
│   │       │   └── script.py
│   │       └── fol_2_2
│   │           ├── build.sh
│   │           ├── Dockerfile
│   │           ├── file.py
│   │           └── ignore.fl
│   ├── docker_init.sh
│   ├── Gemini_Code.txt
│   ├── script_1.sh
│   ├── script_2s
│   │   ├── Dockerfile
│   │   └── script_2.txt
│   └── things to Note.txt
├── DSA_and_OOP
│   ├── DSA_Learning
│   │   ├── Gemini_Code.py
│   │   ├── script_1.py
│   │   └── script_2.py
│   ├── OOP_Learning
│   │   ├── class_holder.py
│   │   ├── Gemini_Code.py
│   │   ├── script_1.py
│   │   └── script_2.py
│   ├── prompt format.txt
│   └── things_to_note.txt
├── FastAPI
│   ├── Gemini_Code.py
│   ├── __pycache__
│   │   ├── main.cpython-312.pyc
│   │   ├── script_1.cpython-312.pyc
│   │   └── the_client.cpython-312.pyc
│   ├── script_1.py
│   ├── script_2.py
│   ├── the_client.py
│   └── things to Note.txt
├── learning_git_and_numpy
│   ├── numpy-learning-project
│   │   ├── Gemini_Code.py
│   │   ├── script_1.py
│   │   ├── script_2.py
│   │   └── things to note.txt
│   ├── pandas_lib.rar
│   └── Text Files
│       ├── assignment.txt
│       └── how to write commit message.txt
├── Linux
│   ├── Gemini_Code.txt
│   ├── script_1.sh
│   ├── script_2.txt
│   └── things to Note.txt
├── Logging
│   ├── Gemini_Code.py
│   ├── script_1.py
│   ├── script_2.py
│   └── things to Note.txt
├── logs
│   ├── numpy_status_report.log
│   └── oop_status_report.log
├── Matplotlib_and_Seaborn
│   ├── Gemini_Code.py
│   ├── images
│   │   ├── figure1.svg
│   │   └── figure2.svg
│   ├── script_1.py
│   ├── script_2.py
│   ├── test_file.ipynb
│   └── things to Note.txt
├── Projects
│   └── SQL, Pandas, NumPy, and Git
│       └── Project_1__The First Commit
│           ├── query.sql
│           ├── README.md
│           ├── script.py
│           └── sqlite_database.db
├── Pytest
│   ├── Gemini_Code.py
│   ├── main.py
│   ├── __pycache__
│   │   ├── main.cpython-312.pyc
│   │   ├── script_test.cpython-312-pytest-9.0.2.pyc
│   │   └── test_file.cpython-312-pytest-9.0.2.pyc
│   ├── script_2.py
│   ├── test_file.py
│   └── things to Note.txt
├── README.md
├── requirements.txt
├── Saved_Datasets_and_Models
│   ├── Datasets
│   │   ├── diamonds.parquet
│   │   └── model_feature_stats.parquet
│   ├── Models
│   │   ├── KNN
│   │   │   ├── diamond_model.pkl
│   │   │   └── diamond_scaler.pkl
│   │   └── Numpy
│   │       └── model_checkpoint.npz
│   └── Processed_Datasets
│       ├── customer_survey_dataset.parquet
│       ├── reg_sales_dset_parquet.parquet
│       ├── reg_sales_dset_pickle.pkl
│       └── subscription_logs_dataset.parquet
├── Scikit-Learn
│   ├── Gemini_Code.py
│   ├── script_1.py
│   ├── script_2.py
│   └── things to Note.txt
├── SQL_and_pandas
│   ├── database_generator
│   │   ├── build_database.py
│   │   ├── file_a.py
│   │   ├── __pycache__
│   │   │   └── build_database.cpython-312.pyc
│   │   └── run_database_build.py
│   ├── Pandas_Code
│   │   ├── Gemini_Code.py
│   │   ├── postres_connect.py
│   │   ├── script_1.py
│   │   ├── script_2.py
│   │   └── things to Note.txt
│   └── SQL_Code_and_DataBase
│       ├── Gemini_code.sql
│       ├── learn_sql.ipynb
│       ├── script_2.sql
│       └── things to Note.txt
├── test_things.py
└── z_code.ipynb

38 directories, 104 files

```

## Contents (high-level)

- `General things to Note.txt` — Short notes and reminders about ML python development in general.
- `README.md` — (this file) overview of the repo and guidance.
- `learning_git_and_numpy/` — Primary learning projects and example scripts for NumPy and related topics.
  - `numpy-learning-project/` — Series of short example scripts (01..17 and extras) that demonstrate NumPy array creation, indexing, broadcasting, ufuncs, and small image-processing examples. Each file is a self-contained script intended for exploration and learning.
    - Example files: `01_first_array.py`, `02_array_creation.py`, `07_array_indexing.py`, `09_image_processor.py`, `12_vectorization.py`, etc.
  - `things to note.txt` — Misc notes related to the examples in this folder and git markdown formatting procedure.
- `Text Files/` — A small set of text documents (`how to write commit message.txt`, `assignment.txt`).
- `SQL_and_pandas/` — Examples and small utilities showing simple database generation and pandas workflows.
  - `database_generator/` — Scripts to programmatically build example SQL files and demonstrate building a small test database.
    - `build_database.py`, `run_database_build.py`, and helper modules. The database where the tables are generated in is located at [sQL_CoDe/my_database.db](SQL_and_pandas/SQL_Code_and_DataBase/my_database.db).
  - `pandas_codE/` — Short pandas scripts and notes demonstrating data manipulation patterns (`Gemini_Code.py`, `script_1.py`, `script_2.py`).
  - `sQL_CoDe/` — SQL snippets and an example notebook (`learn_sql.ipynb`) containing basic SQL learning material.

## Purpose and intended usage

This folder acts as a personal learning library. Use it to:

- Read the example scripts to learn idiomatic NumPy/pandas patterns.
- Run the small scripts directly (they are written as simple Python scripts — open them in an editor and run with your local Python interpreter).
- Use `database_generator` to produce sample SQL if you want to practice loading data into a local database.

Typical quick-start steps (assumes you have Python 3.8+ installed):

1. Open a console in this folder (for example: the `numpy-learning-project` folder).
2. Create/activate a virtual environment if you like.
3. Run an example script with `python 01_first_array.py` or open an example in VS Code.

Notes:
- These examples intentionally avoid heavy, pinned dependencies. If you need pandas or NumPy, install them in your environment:
```
pip install numpy pandas jupyter
```
or use the `requirements.txt` file:
```
pip install -r requirements.txt
```
- Some files (the notebook `learn_sql.ipynb`) require [Jupyter](https://jupyter.org/install) to view/run.

## File highlights and short descriptions

- Most directories contain one or more of the following files: `script_1.{file extension}`, `script_2.{file extension}`, or `Gemini_Code.{file extension}`. These files serve distinct purposes within the learning workflow:
  - `Gemini_Code`: Stores the code provided for instructional purposes.
  - `script_1`: Used for practicing the concepts currently being taught.
  - `script_2`: Serves as a comprehensive repository for all demonstrated code, optimized for future reference.
- `learning_git_and_numpy/numpy-learning-project/01_first_array.py` — Intro to creating NumPy arrays.
- `.../09_image_processor.py` — Simple image-processing code demonstrating array shapes and indexing.
- `SQL_and_pandas/database_generator/build_database.py` — Generates SQL table creation and sample-data insert files (useful to seed a test database).
- `SQL_and_pandas/pandas_codE/Gemini_Code.py` — Short pandas examples and notes.

## Conventions and organization suggestions

- Filenames are prefixed with numbers in the `numpy-learning-project` folder to indicate a suggested reading order. They are small, self-contained learning scripts.
- The `SQL_and_pandas` area is split into code that generates SQL (`database_generator`) and example pandas scripts (`pandas_codE`).

## Recommended next steps / improvements

1. Add a `requirements.txt` or `environment.yml` listing the minimal packages used (NumPy, pandas, jupyter).
2. Convert a couple of example scripts into small unit tests or notebooks to demonstrate reproducibility.
3. Standardize naming and capitalization (`pandas_codE` vs `pandas_code`) for consistency.
4. Add short README files inside large subfolders (`numpy-learning-project`, `database_generator`) with direct run instructions and expected outputs.

## License & attribution

This folder appears to be personal learning material. If you want to publish or share it, add a LICENSE file (MIT/Apache/BSD as appropriate) and ensure any third-party code snippets include attributions.

## Contact Me

- **Phone Number:** +234 9133982877
- **Whatsapp:** [Link to my Whatsapp](https://wa.link/t8b9hv)
- **Email:** jesfusionprox@gmail.com

---

This README was last edited on 2026-01-25

<!-- TODO: Proof-Read this Markdown content-->
