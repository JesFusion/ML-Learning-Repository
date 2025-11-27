# Assignment

import numpy as np
import pandas as pd
np.random.seed(19)


huge_data = pd.DataFrame({
    "name": ["Jesse", "Favour", "Caleb"],
    "age": [19, 18, 16]
})

print(huge_data.to_markdown())

# huge_data.to_csv(r"C:\Users\USER\Documents\My Programs\Machine_Learning\Python Programs\jesseVirtualEnvs\.mainDog\python code\ML-Learning-Repository\learning_git_and_numpy\numpy-learning-project\huge_data.csv", index = False)


dataset = np.random.randint(0, 100, 100)

dataset[:3] = 1000

print(f'''
Original Dataset: {dataset[:23]}

Mean of Dataset: {np.mean(dataset)}

Median of Dataset: {np.median(dataset)}

Standard Deviation of Dataset: {np.std(dataset):.3f}

Index of Highest Value in Dataset: {np.argmax(dataset)}
''')

cleaned_dataset = dataset[dataset < 100]


print(f'''
Cleaned Dataset: {cleaned_dataset[:23]}

Mean of Cleaned Dataset: {np.mean(cleaned_dataset):.2f}

Median of Cleaned Dataset: {np.median(cleaned_dataset)}
''')

