import numpy as np
np.random.seed(19)
np.set_printoptions(suppress = True)


loss_data = np.random.randint(44, 95, size = (25))

# basic aggregations in numpy: 
# np.sum(): Finds the sum of all elements in a numpy array
# np.min(): Finds the minimum value in a numpy array
# np.max(): Finds the maximum value in a numpy array
# np.argmax(): Finds the index of the maximum value in a numpy array
# np.argmin(): Finds the index of the minimum value in a numpy array


print(f'''
Data: {loss_data}
Shape: {loss_data.shape}

First five losses: {loss_data[:5]}

Total Loss (Sum): {np.sum(loss_data):.2f}

Minimum Loss: {np.min(loss_data):.4f}

Maximum Loss: {np.max(loss_data):.4f}
''')


random_state = np.random.default_rng()

acc_score = random_state.random(5).round(4)

output_class = ["Jesse", "Favour", "Daniel", "Python", "Megalodon"]


h_acc = np.max(acc_score)

h_model_index = np.argmax(acc_score)

print(f"""
Model Accuracies: {acc_score}

Models: {output_class}

Best Accuracy Value: {h_acc}

Best Model Index: {h_model_index}

Best Model: {output_class[h_model_index]}

Worst Accuracy Value: {np.argmin(acc_score)}

Worst Model: {output_class[np.argmin(acc_score)]}
""")

large_data = np.random.rand(1999, 1999)

# np.save(r"C:\Users\USER\Documents\My Programs\Machine_Learning\Python Programs\jesseVirtualEnvs\.mainDog\python code\ML-Learning-Repository\learning_git_and_numpy\numpy-learning-project\large_dset.npy", large_data)

print("Saved Large Dataset! Git LFS should handle it.")
