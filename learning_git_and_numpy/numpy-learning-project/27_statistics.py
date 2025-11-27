import numpy as np
np.random.seed(19)

salary_dataset = np.random.randint(60000, 195000, 13)

# ============================= Mean vs. Median =============================

# np.mean(): used for finding average of elements in an array. Heavily affected by outliers

# np.median(): used for finding the median of elements in an array. Not usually affected by outliers

print(f'''
Normal Salary Dataset: {salary_dataset}

Mean of Dataset: {np.mean(salary_dataset).round(3)}

Median of Dataset: {np.median(salary_dataset)}
''')

# let's add an outlier to the array
# This would greatly affect the mean but not the median

sal_dset_bil = np.append(salary_dataset, 1_000_000_000)

print(f'''
With Outlier:
{sal_dset_bil}

Distorted Mean: {np.mean(sal_dset_bil)}

Robust Median: {np.median(sal_dset_bil)}
''')


# ============================= variance vs. standard Deviation =============================

# creating two datasets with the same mean but different spread

# High consistency (low spread)
MS_dataset_1 = np.array([48, 50, 52, 49, 51])

# Low consistency (high spread)
MS_dataset_2 = np.array([0, 100, 50, 25, 75])

print(f'''
Mean of Dataset 1: {np.mean(MS_dataset_1)}

Mean of Dataset 2: {np.mean(MS_dataset_2)}

Std. Deviation of Dataset 1: {np.std(MS_dataset_1):.2f}

Std. Deviation of Dataset 2: {np.std(MS_dataset_2):.3f}
''')



