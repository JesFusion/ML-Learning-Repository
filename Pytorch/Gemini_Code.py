"""
================================================================================
  PYTORCH MASTER CURRICULUM — MEGA-BATCH 1 IMPLEMENTATION
  Segments 1.1 → 7.2  |  20 Segments  |  119 Concepts
  Engineer : Chijioke Ekwebelem
  Student  : Jesse
  OS       : Ubuntu Linux  |  Python 3.10+
================================================================================
"""

# ==============================================================================
# GLOBAL BOOTSTRAP — Imports, Device, Dataset, SQLite DB
# ==============================================================================

# [WHAT]: Pull in every dependency the full script needs in one place. Generate
#         200 synthetic student records (features + labels) and persist them to
#         a local SQLite database. Every segment reuses this single dataset.
# [WHY]:  One coherent dataset lets you watch the *same* data travel from a raw
#         numpy array → tensor → model input → gradient → trained prediction.
#         SQLite needs zero server setup, so the script is fully self-contained.

import torch
import torch.nn            as nn
import torch.nn.functional as F
import torch.optim         as optim
import torch.utils.data    as data

import numpy    as np
import sqlite3
import os



# [WATCH OUT]: Seed BOTH torch and numpy independently. They have separate RNG
#              states. Seeding only one gives you partial reproducibility — a
#              silent bug that will drive you crazy in experiment tracking.
torch.manual_seed(seed=42)
np.random.seed(42)

# ---------------------------------------------------------------------------
# Device Detection
# ---------------------------------------------------------------------------
# [WHAT]: Detect the best available hardware at runtime and store it globally.
# [WHY]:  This single line makes every .to(DEVICE) call hardware-agnostic.
#         The code runs identically on a $500 laptop or an A100 cluster.
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print("\n" + "="*72)
print("  PYTORCH MEGA-BATCH | Segments 1.1 → 7.2")
print(f"  Active Compute Device : {DEVICE}")
print("="*72)

# ---------------------------------------------------------------------------
# Synthetic Dataset — "ExamScore"
# ---------------------------------------------------------------------------
# [WHAT]: Generate 200 student records.
#         Features : study_hours, sleep_hours, practice_problems, prev_gpa
#         Labels   : exam_score (float, regression) | passed (int, classification)
# [HOW]:
#   1. Sample each feature from a realistic distribution.
#   2. Compute exam_score as a noisy linear combination of features.
#   3. Derive the binary label with a 50-point pass threshold.

N_SAMPLES   = 200
N_FEATURES  = 4

study_hours    = np.random.uniform(low=1.0,  high=10.0, size=N_SAMPLES)
sleep_hours    = np.random.uniform(low=4.0,  high=9.0,  size=N_SAMPLES)
practice_probs = np.random.randint(low=0,    high=50,   size=N_SAMPLES).astype(np.float64)
prev_gpa       = np.random.uniform(low=1.5,  high=4.0,  size=N_SAMPLES)

noise          = np.random.normal(loc=0.0,   scale=5.0, size=N_SAMPLES)
exam_score_raw = (3.5  * study_hours
                + 2.0  * sleep_hours
                + 0.4  * practice_probs
                + 8.0  * prev_gpa
                + noise)

exam_score  = np.clip(a=exam_score_raw, a_min=0.0, a_max=100.0)
passed      = (exam_score >= 50.0).astype(np.int64)

# Build the raw NumPy feature matrix — shape (200, 4)
np_features = np.column_stack([study_hours, sleep_hours, practice_probs, prev_gpa])

# ---------------------------------------------------------------------------
# SQLite Persistence
# ---------------------------------------------------------------------------
# [WHAT]: Create a fresh SQLite file and insert all 200 records into a
#         'students' table. Segment 7.2 will query this database live.
# [WATCH OUT]: DROP + CREATE on every run guarantees a clean state, but in a
#              real data pipeline you'd use Alembic migrations, not DROP TABLE.
DB_PATH = "/tmp/exam_scores.db"
if os.path.exists(DB_PATH):
    os.remove(DB_PATH)

_conn   = sqlite3.connect(DB_PATH)
_cursor = _conn.cursor()
_cursor.execute("""
    CREATE TABLE students (
        id               INTEGER PRIMARY KEY,
        study_hours      REAL,
        sleep_hours      REAL,
        practice_probs   REAL,
        prev_gpa         REAL,
        exam_score       REAL,
        passed           INTEGER
    )
""")
_rows = [
    (i,
     float(study_hours[i]),
     float(sleep_hours[i]),
     float(practice_probs[i]),
     float(prev_gpa[i]),
     float(exam_score[i]),
     int(passed[i]))
    for i in range(N_SAMPLES)
]
_cursor.executemany("INSERT INTO students VALUES (?,?,?,?,?,?,?)", _rows)
_conn.commit()
_conn.close()

print(f"\n[BOOTSTRAP] SQLite DB created  : {DB_PATH}")
print(f"[BOOTSTRAP] Records inserted   : {N_SAMPLES}")
print("[BOOTSTRAP] Feature columns    : study_hours, sleep_hours, practice_probs, prev_gpa")
print("[BOOTSTRAP] Label columns      : exam_score (regression) | passed (classification)")


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 1.1 — Tensors vs. NumPy Arrays (Device Management)")
print("="*72)
# ==============================================================================

# [WHAT]: Demonstrate the rank hierarchy of tensors and the device system that
#         makes PyTorch fundamentally different from NumPy.
# [WHY]:  NumPy arrays live on the CPU only. torch.tensor() creates data that
#         can be promoted to GPU VRAM with a single .to(DEVICE) call, unlocking
#         parallel computation across thousands of CUDA cores.

# --- Rank-0: Scalar ---
# [HOW]: A rank-0 tensor holds exactly one number. Zero indices needed to address it.
scalar_tensor = torch.tensor(data=5.0)
print(f"\n[1.1] Rank-0 Scalar  | value: {scalar_tensor.item()}  | shape: {scalar_tensor.shape}  | ndim: {scalar_tensor.ndim}")

# --- Rank-1: Vector ---
# [HOW]: A rank-1 tensor is a 1-D array. Its L2 norm = sqrt(sum of squares).
vector_tensor = torch.tensor(data=[1.0, 2.0, 3.0])
l2_norm       = torch.linalg.norm(input=vector_tensor)
print(f"[1.1] Rank-1 Vector  | value: {vector_tensor.tolist()}  | shape: {vector_tensor.shape}  | L2 norm: {l2_norm:.4f}")

# --- Rank-2: Matrix (our feature data) ---
# [HOW]: Convert the NumPy feature matrix to a float32 tensor.
#        torch.from_numpy() creates a ZERO-COPY view — same memory, no duplication.
# [WATCH OUT]: torch.from_numpy() respects dtype from numpy. NumPy defaults to
#              float64; PyTorch models expect float32. Always cast explicitly.
features_f64 = torch.from_numpy(np_features)                        # float64, zero-copy
features     = features_f64.to(dtype=torch.float32)                 # cast to float32
labels_reg   = torch.tensor(data=exam_score, dtype=torch.float32)   # regression targets
labels_cls   = torch.tensor(data=passed,     dtype=torch.long)       # classification targets

print(f"[1.1] Rank-2 Matrix  | shape: {features.shape}  | dtype: {features.dtype}  | ndim: {features.ndim}")

# --- Device Transfer ---
# [HOW]: .to(DEVICE) moves the tensor to the globally selected device.
#        On CPU, this is a no-op. On CUDA, it allocates VRAM.
features_dev   = features.to(device=DEVICE)
labels_reg_dev = labels_reg.to(device=DEVICE)
labels_cls_dev = labels_cls.to(device=DEVICE)
print(f"[1.1] Tensor device  | features: {features_dev.device}  | labels: {labels_reg_dev.device}")

# [WHAT ELSE]: torch.cuda.memory_allocated() reports current VRAM usage in bytes.
#              torch.cuda.empty_cache() releases cached (but unused) VRAM back to
#              the OS — useful between training experiments, not mid-training.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 1.2 — Tensor Construction & Types")
print("="*72)
# ==============================================================================

# [WHAT]: Explore the dtype zoo and make memory costs concrete and numerical.
# [WHY]:  dtype is not a detail — it determines VRAM budget, training stability,
#         and whether your loss function will accept the tensor without crashing.

# --- dtype demonstration ---
t_f32  = torch.tensor(data=[1.0, 2.0, 3.0], dtype=torch.float32)
t_f16  = t_f32.to(dtype=torch.float16)
t_int  = torch.tensor(data=[0, 1, 1, 0],    dtype=torch.long)
t_bool = torch.tensor(data=[True, False, True])

print(f"\n[1.2] float32 tensor : {t_f32.tolist()}  | dtype: {t_f32.dtype}  | bytes/elem: {t_f32.element_size()}")
print(f"[1.2] float16 tensor : {t_f16.tolist()}  | dtype: {t_f16.dtype}  | bytes/elem: {t_f16.element_size()}")
print(f"[1.2] int64  tensor  : {t_int.tolist()}   | dtype: {t_int.dtype}  | bytes/elem: {t_int.element_size()}")
print(f"[1.2] bool   tensor  : {t_bool.tolist()} | dtype: {t_bool.dtype} | bytes/elem: {t_bool.element_size()}")

# --- Random initialization strategies ---
t_randn = torch.randn(size=(3, 4))   # Standard Normal: mean=0, std=1 — for weights
t_rand  = torch.rand(size=(3, 4))    # Uniform [0,1)  — for masks/probabilities
t_zeros = torch.zeros(size=(3, 4))   # All zeros      — for bias initialisation
t_ones  = torch.ones(size=(3, 4))    # All ones       — for attention masks

print(f"\n[1.2] randn(3,4) sample (first row) : {t_randn[0].tolist()}")
print(f"[1.2] rand(3,4)  sample (first row) : {[round(v,4) for v in t_rand[0].tolist()]}")

# --- Memory footprint calculation ---
# [HOW]: nbytes = total_elements * bytes_per_element
#        For our (200, 4) float32 feature tensor: 800 * 4 = 3200 bytes = 3.125 KB
feature_bytes = features.numel() * features.element_size()
hypothetical_1k_matrix_bytes = 1_000_000 * torch.float32.itemsize  # 1000x1000 f32

print(f"\n[1.2] features tensor  : {features.numel()} elements × {features.element_size()} bytes = {feature_bytes} bytes ({feature_bytes/1024:.2f} KB)")
print(f"[1.2] 1000×1000 float32: {hypothetical_1k_matrix_bytes:,} bytes ≈ {hypothetical_1k_matrix_bytes/1e6:.1f} MB")
print(f"[1.2] Same tensor in f16 would be: {hypothetical_1k_matrix_bytes//2:,} bytes ≈ {hypothetical_1k_matrix_bytes/2/1e6:.1f} MB")

# [WHAT ELSE]: torch.bfloat16 (Brain Float 16) is Google's alternative to float16.
#              It has the SAME exponent range as float32 (avoiding underflow) but
#              only 7 mantissa bits vs float32's 23. It's the default dtype on TPUs
#              and increasingly preferred over float16 for LLM training on modern GPUs.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 1.3 — Tensor Math & Linear Algebra")
print("="*72)
# ==============================================================================

# [WHAT]: Demonstrate the three flavours of tensor multiplication and why getting
#         them confused will silently produce wrong shapes and wrong results.
# [WHY]:  Matrix multiplication IS the neural network forward pass. Every Linear
#         layer is matmul(input, weight.T) + bias. Understanding this is non-negotiable.

# --- Build a small weight matrix to simulate a Linear layer ---
# Input: (200, 4) features → Output: (200, 8) hidden representation
W_demo = torch.randn(size=(4, 8))   # (in_features=4, out_features=8)
b_demo = torch.zeros(size=(8,))

# --- Matrix Multiplication ---
# [HOW]: Rule — A(m×n) @ B(n×p) → C(m×p). Inner dimensions MUST match.
#        Here: (200,4) @ (4,8) → (200,8). 200 samples, each projected to 8 dims.
hidden = features @ W_demo + b_demo           # @ operator calls torch.matmul
hidden_explicit = torch.matmul(input=features, other=W_demo) + b_demo

print(f"\n[1.3] features shape : {features.shape}  (m=200, n=4)")
print(f"[1.3] W_demo shape   : {W_demo.shape}   (n=4, p=8)")
print(f"[1.3] hidden shape   : {hidden.shape}  (m=200, p=8) — C = A @ B")
print(f"[1.3] @ vs matmul match: {torch.allclose(input=hidden, other=hidden_explicit)}")

# --- Dot Product (1D only) ---
# [HOW]: dot product = sum of element-wise products → scalar result.
vec_a   = features[0]   # First student's 4 features — shape (4,)
vec_b   = features[1]   # Second student's 4 features — shape (4,)
dot_val = torch.dot(input=vec_a, tensor=vec_b)
print(f"\n[1.3] dot(student_0, student_1) : {dot_val:.4f}  | shape: {dot_val.shape} (scalar)")

# --- Element-wise Operations ---
# [HOW]: Same shape required. Operations applied independently at each position.
features_doubled  = features * 2.0                 # Scale every feature by 2
features_shifted  = features + 0.5                 # Shift every feature up
features_combined = features_doubled - features_shifted

print(f"\n[1.3] Element-wise * 2.0  — first sample: {features_doubled[0].tolist()}")
print(f"[1.3] Element-wise + 0.5  — first sample: {features_shifted[0].tolist()}")

# [WATCH OUT]: The @ operator only works for 2D+ tensors. For 1D vectors, torch.dot()
#              is required. Calling @ on two 1D tensors will raise a RuntimeError.
#              torch.matmul() is smarter — it handles 1D, 2D, and batched 3D cases.

# [WHAT ELSE]: torch.einsum() is the power-user tool for expressing any tensor
#              contraction (matmul, outer product, trace, etc.) with Einstein notation.
#              Example: torch.einsum('bi,ij->bj', features, W_demo) == features @ W_demo.
#              It's verbose but maximally explicit — great for attention mechanisms.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 2.1 — Reshaping & Viewing")
print("="*72)
# ==============================================================================

# [WHAT]: Manipulate tensor shapes without touching the underlying data.
#         These are the most frequently used operations in any model's forward().
# [WHY]:  Layers have strict shape contracts. Data arrives in one shape; the layer
#         expects another. Reshape bridges that gap with zero computation.

# --- Conservation Law: total elements must be preserved ---
T = features.clone()   # shape: (200, 4), total elements = 800
print(f"\n[2.1] Original shape : {T.shape}  | Total elements: {T.numel()}")

# .view() — requires contiguous memory, returns a view (zero-copy)
# [HOW]: -1 tells PyTorch to infer that dimension. 800 / 8 = 100.
T_view = T.view(100, 8)
print(f"[2.1] .view(100, 8)  : {T_view.shape}  | Same memory: {T.data_ptr() == T_view.data_ptr()}")

# .reshape() — handles non-contiguous memory by copying if needed
T_reshaped = T.reshape(shape=(400, 2))
print(f"[2.1] .reshape(400,2): {T_reshaped.shape}  | Elements: {T_reshaped.numel()}")

# .permute() — reorder all dimensions at once
# Imagine our data as (batch=200, features=4). We want (features=4, batch=200).
T_permuted = T.permute(dims=(1, 0))
print(f"\n[2.1] .permute(1,0)  : {T_permuted.shape}  (transposed — features as rows)")

# .transpose() — swap exactly two dimensions (specialised .permute for 2 dims)
T_transposed = T.transpose(dim0=0, dim1=1)
print(f"[2.1] .transpose(0,1): {T_transposed.shape}  (same result as permute above)")

# [WATCH OUT]: .permute() and .transpose() return NON-CONTIGUOUS tensors.
#              Calling .view() directly after them will raise:
#              "RuntimeError: view size is not compatible with... call .contiguous() first"
T_permuted_cont = T_permuted.contiguous()
T_after_permute = T_permuted_cont.view(800)    # Now safe to .view()
print(f"\n[2.1] After .contiguous().view(800): {T_after_permute.shape}")

# [WHAT ELSE]: torch.flatten(start_dim=1) is a convenience wrapper around reshape
#              commonly used after convolutional layers to collapse (C,H,W) → (C*H*W,).
#              torch.squeeze() / torch.unsqueeze() add or remove size-1 dimensions.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 2.2 — Indexing, Slicing, and Advanced Selection")
print("="*72)
# ==============================================================================

# [WHAT]: Select tensor elements not by position but by CONDITION or by another
#         tensor's index values. This is vectorised, GPU-accelerated set theory.
# [WHY]:  Python loops over tensors are ~100x slower than vectorised operations.
#         Boolean masking and torch.where replace every conditional loop.

# --- Boolean Masking (Indicator Function) ---
# [HOW]: Apply condition → get a bool tensor M where M[i] = True if condition holds.
#        Use M as an index to retrieve the matching elements.
pass_mask    = labels_reg > 50.0    # M = 𝟙_{score > 50}(score)
passing_scores = labels_reg[pass_mask]

print(f"\n[2.2] Total students          : {labels_reg.shape[0]}")
print(f"[2.2] Pass mask (True count)  : {pass_mask.sum().item()}")
print(f"[2.2] Passing scores shape    : {passing_scores.shape}")
print(f"[2.2] Passing scores mean     : {passing_scores.mean().item():.2f}")

# Zero-out failing scores using the mask (Y = X * M)
# [HOW]: Cast bool mask to float to enable multiplication.
score_mask_float    = pass_mask.to(dtype=torch.float32)
zeroed_fail_scores  = labels_reg * score_mask_float
print(f"\n[2.2] Zeroed fail scores — first 10: {[round(v,1) for v in zeroed_fail_scores[:10].tolist()]}")

# --- torch.where() — vectorised conditional selection ---
# [HOW]: torch.where(condition, value_if_true, value_if_false)
#        No Python loop. Every element evaluated simultaneously.
PASS_THRESHOLD = 50.0
clamped_scores = torch.where(
    condition=labels_reg > PASS_THRESHOLD,
    input=labels_reg,                        # keep score if passing
    other=torch.zeros_like(input=labels_reg) # zero out if failing
)
print(f"\n[2.2] torch.where output shape : {clamped_scores.shape}")
print(f"[2.2] Non-zero count            : {(clamped_scores > 0).sum().item()}")

# --- torch.gather() — index-based extraction ---
# [HOW]: Simulate a classification scenario: model outputs (N, 2) logit matrix.
#        We want to extract the logit for the ACTUAL correct class per sample.
#        index must be shape (N, 1) of dtype Long.
N_DEMO        = 10
fake_logits   = torch.randn(size=(N_DEMO, 2))          # (10, 2) — 2 classes
true_labels   = labels_cls[:N_DEMO].unsqueeze(dim=1)   # (10, 1) — actual class indices
correct_logit = torch.gather(input=fake_logits, dim=1, index=true_labels)

print(f"\n[2.2] fake_logits shape   : {fake_logits.shape}")
print(f"[2.2] true_labels shape   : {true_labels.shape}")
print(f"[2.2] gathered logits     : {correct_logit.shape}  — one logit per sample")
print(f"[2.2] Sample logits row 0 : {fake_logits[0].tolist()} → gathered: {correct_logit[0].item():.4f}")

# [WHAT ELSE]: torch.index_select(dim, index) selects full rows/columns by integer
#              index tensor, useful when you want entire rows rather than per-row picks.
#              torch.masked_select() returns a 1D tensor of all elements where mask=True
#              (vs boolean masking which preserves shape).


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 2.3 — Broadcasting Semantics")
print("="*72)
# ==============================================================================

# [WHAT]: Perform arithmetic between tensors of incompatible shapes by virtually
#         expanding size-1 dimensions — no data copying, no loops.
# [WHY]:  Broadcasting is how adding a bias vector to an entire batch works in
#         every Linear layer. Without it, you'd need explicit loops or manual tiling.

# --- Classic outer-sum demo: (1×3) + (3×1) → (3×3) ---
# [HOW]: PyTorch aligns shapes from the RIGHT, then expands size-1 dims to match.
row_vec = torch.tensor(data=[[1.0, 2.0, 3.0]])   # shape (1, 3)
col_vec = torch.tensor(data=[[10.0], [20.0], [30.0]])  # shape (3, 1)
outer_sum = row_vec + col_vec                     # broadcasts to (3, 3)

print(f"\n[2.3] row_vec shape   : {row_vec.shape}")
print(f"[2.3] col_vec shape   : {col_vec.shape}")
print(f"[2.3] outer_sum shape : {outer_sum.shape}")
print(f"[2.3] outer_sum:\n{outer_sum}")

# --- Real-world use: feature normalisation via broadcasting ---
# [HOW]: Mean and std have shape (4,) = (N_FEATURES,).
#        Broadcasting expands them to (200, 4) to normalise every row.
feat_mean = features.mean(dim=0)    # shape (4,) — mean of each feature column
feat_std  = features.std(dim=0)     # shape (4,)
features_norm = (features - feat_mean) / (feat_std + 1e-8)  # z-score normalisation

print(f"\n[2.3] feat_mean shape       : {feat_mean.shape}")
print(f"[2.3] features shape        : {features.shape}")
print(f"[2.3] features_norm shape   : {features_norm.shape}  (broadcast subtraction)")
print(f"[2.3] features_norm mean ≈  : {features_norm.mean(dim=0).tolist()}")   # should be ~[0,0,0,0]
print(f"[2.3] features_norm std  ≈  : {[round(v,4) for v in features_norm.std(dim=0).tolist()]}")  # should be ~[1,1,1,1]

# [WATCH OUT]: Broadcasting silently SUCCEEDS on shape (3,) + (4,) if you're
#              not careful — it matches from the right. (3,) + (4,) is NOT
#              broadcast-compatible and will raise, but (1,4) + (3,4) will silently
#              broadcast in a way that may not be what you intended. Always check shapes.

# [WHAT ELSE]: torch.broadcast_to(tensor, shape) makes the expansion explicit.
#              .expand(shape) is a zero-copy manual broadcast for a single tensor.
#              torch.broadcast_tensors(*tensors) aligns multiple tensors at once.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 3.1 — The Computational Graph (DAGs)")
print("="*72)
# ==============================================================================

# [WHAT]: Enable gradient tracking on tensors and observe the DAG being built
#         dynamically as operations execute.
# [WHY]:  The computational graph IS the memory of the forward pass. Without it,
#         .backward() has no path to walk and cannot compute gradients.

# [HOW]: requires_grad=True tells autograd: "record every operation on this tensor".
x = torch.tensor(data=3.0, requires_grad=True)    # Leaf node

# Build y = x^2 + 3  →  graph: x → (PowBackward) → (AddBackward) → y
y = x ** 2 + 3

print(f"\n[3.1] x = {x.item()} | requires_grad: {x.requires_grad} | grad_fn: {x.grad_fn}")
print(f"[3.1] y = x^2 + 3 = {y.item()} | grad_fn: {y.grad_fn}")

# Demonstrate leaf vs intermediate nodes on the feature matrix
W_leaf = torch.randn(size=(4, 8), requires_grad=True)   # Leaf — the "weight"
b_leaf = torch.zeros(size=(8,),   requires_grad=True)   # Leaf — the "bias"

# Intermediate node: created by an operation, has a grad_fn
z_intermediate = features_norm @ W_leaf + b_leaf

print(f"\n[3.1] W_leaf  : is_leaf={W_leaf.is_leaf}  | grad_fn={W_leaf.grad_fn}")
print(f"[3.1] z_inter : is_leaf={z_intermediate.is_leaf} | grad_fn={z_intermediate.grad_fn}")

# [WATCH OUT]: Intermediate tensors do NOT retain .grad by default after .backward().
#              If you need to inspect an intermediate gradient (e.g., for debugging),
#              you must call z_intermediate.retain_grad() BEFORE calling .backward().

# [WHAT ELSE]: torch.autograd.grad(outputs, inputs) is the lower-level API for
#              computing specific gradients without calling .backward() on the loss,
#              used in meta-learning (MAML) and gradient penalty computations.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 3.2 — Forward vs. Backward Pass")
print("="*72)
# ==============================================================================

# [WHAT]: Execute a full forward pass, compute a scalar loss, and trigger
#         backpropagation. Then read the resulting gradients on the leaf tensors.
# [WHY]:  This is THE training loop in miniature. Everything in Phases 2-8
#         is just a more sophisticated version of these exact four lines.

# --- Reinitialise clean leaves for a clear demonstration ---
W_bp = torch.randn(size=(4, 1), requires_grad=True)  # Weight: 4 features → 1 output
b_bp = torch.zeros(size=(1,),   requires_grad=True)  # Bias

# Forward pass: linear prediction
y_pred = features_norm @ W_bp + b_bp             # shape (200, 1)
y_true = labels_reg.unsqueeze(dim=1) / 100.0     # shape (200, 1), normalised to [0,1]

# Loss: MSE
loss_bp = ((y_pred - y_true) ** 2).mean()

print("\n[3.2] Forward pass complete")
print(f"[3.2] y_pred shape : {y_pred.shape}  | loss : {loss_bp.item():.6f}")
print(f"[3.2] W_bp.grad BEFORE backward : {W_bp.grad}")  # None — not yet computed

# Backward pass: walk the DAG in reverse, apply chain rule at each node
# [HOW]: .backward() populates .grad on every leaf with requires_grad=True.
loss_bp.backward()

print(f"[3.2] W_bp.grad AFTER backward  : shape={W_bp.grad.shape} | values={[round(v,6) for v in W_bp.grad.flatten().tolist()]}")
print(f"[3.2] b_bp.grad AFTER backward  : {[round(v,6) for v in b_bp.grad.flatten().tolist()]}")

# --- Gradient Accumulation Bug Demo ---
# [HOW]: Call backward() AGAIN without zeroing — gradients ACCUMULATE (add up).
loss_bp2 = ((y_pred - y_true) ** 2).mean()
# [WATCH OUT]: Can't call backward twice on same graph — graph is freed after first backward.
#              Demonstrating numerically: manually double the existing gradient.
grad_before_zero = W_bp.grad.clone()
W_bp.grad += W_bp.grad.clone()       # Simulate a second backward without zero_grad
print(f"\n[3.2] W_bp.grad WITHOUT zero_grad (accumulated): {W_bp.grad.flatten().tolist()}")
print("[3.2] → Exactly 2x the real gradient. This is the accumulation bug.")

# Zero the gradients — mandatory at start of every training iteration
W_bp.grad.zero_()
b_bp.grad.zero_()
print(f"[3.2] After zero_() — W_bp.grad : {W_bp.grad.flatten().tolist()}")

# [WHAT ELSE]: loss.backward(retain_graph=True) preserves the computational graph
#              after the backward pass, allowing multiple .backward() calls on the
#              same graph. Required in architectures with multiple loss terms or in
#              meta-learning. Has a significant VRAM cost — never use carelessly.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 3.3 — Detaching from the Graph")
print("="*72)
# ==============================================================================

# [WHAT]: Demonstrate the three mechanisms for preventing gradient tracking,
#         each with different scope and performance characteristics.
# [WHY]:  During inference and validation, building the computational graph is
#         pure waste — you're paying VRAM and compute for data you'll never use.
#         On large models, torch.no_grad() cuts inference VRAM by 30-40%.

# --- .detach() — sever a specific tensor from the graph ---
W_d = torch.randn(size=(4, 8), requires_grad=True)
z_d = features_norm @ W_d + 0.1   # intermediate node in graph
z_detached = z_d.detach()          # new tensor, same data, no graph connection

print(f"\n[3.3] z_d requires_grad      : {z_d.requires_grad}   | grad_fn: {z_d.grad_fn}")
print(f"[3.3] z_detached req_grad    : {z_detached.requires_grad} | grad_fn: {z_detached.grad_fn}")
print(f"[3.3] Same data pointer      : {z_d.data_ptr() == z_detached.data_ptr()}")

# --- torch.no_grad() — context manager for full scope disabling ---
# [HOW]: Everything inside the `with` block has requires_grad=False implicitly.
#        The graph is never built — zero memory overhead for validation loops.
print("\n[3.3] Running inference under torch.no_grad()...")
with torch.no_grad():
    y_inference = features_norm @ W_d + 0.1
    print(f"[3.3] y_inference requires_grad: {y_inference.requires_grad}  | grad_fn: {y_inference.grad_fn}")

# --- torch.inference_mode() — maximum speed inference ---
# [HOW]: More aggressive than no_grad. Disables version counter tracking too.
#        Tensors created here cannot participate in any future autograd graph.
print("\n[3.3] Running inference under torch.inference_mode()...")
with torch.inference_mode():
    y_inf_mode = features_norm @ W_d + 0.1
    print(f"[3.3] y_inf_mode requires_grad : {y_inf_mode.requires_grad}")

# --- .item() — extract scalar, implicit detach ---
# [HOW]: When logging loss, always use .item() — it detaches and returns a Python float.
sample_loss = ((y_inference - labels_reg.unsqueeze(dim=1) / 100.0) ** 2).mean()
loss_as_float = sample_loss.item()   # detaches from graph, returns Python float
print(f"\n[3.3] loss.item() = {loss_as_float:.6f}  | type: {type(loss_as_float)}")

# [WATCH OUT]: Logging loss as loss_history.append(loss) — WITHOUT .item() — keeps
#              the entire computational graph alive in memory for every iteration.
#              In a training loop of 1000 steps, this creates a memory leak that
#              will crash your process. ALWAYS append loss.item(), never loss.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 4.1 — The nn.Module Base Class")
print("="*72)
# ==============================================================================

# [WHAT]: Define a neural network by subclassing nn.Module, establishing the OOP
#         pattern that every model in PyTorch (from ResNet to GPT) uses.
# [WHY]:  nn.Module isn't just convenience. It provides parameter registration,
#         .to(device) propagation, .state_dict() serialisation, training/eval
#         mode switching, and hook infrastructure — for free.

class SimpleNet(nn.Module):
    # [WHAT]: A two-layer MLP (Multi-Layer Perceptron) for regression/classification.
    #         Input: 4 features → Hidden: 16 neurons → Output: 1 neuron.
    # [WHY]:  Two layers are the minimum to demonstrate function composition
    #         f(g(x)) while keeping the output clean and readable.

    def __init__(self, in_features: int, hidden_size: int, out_features: int):
        # [HOW]: super().__init__() initialises nn.Module's internal registries.
        #        Without this line, NOTHING works — no parameter tracking, no
        #        .to(device), no .state_dict(). It's not optional boilerplate.
        super().__init__()

        self.hidden = nn.Linear(in_features=in_features, out_features=hidden_size)
        self.output = nn.Linear(in_features=hidden_size, out_features=out_features)
        self.dropout = nn.Dropout(p=0.3)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # [HOW]: forward() defines the computation. Call the module INSTANCE
        #        (model(x)), never model.forward(x) — __call__ wraps forward()
        #        with pre/post hooks that direct .forward() invocation skips.
        x = self.hidden(x)
        x = F.relu(input=x)
        x = self.dropout(input=x)
        x = self.output(x)
        return x


# Instantiate and move to device
model = SimpleNet(in_features=N_FEATURES, hidden_size=16, out_features=1)
model = model.to(device=DEVICE)

# Demonstrate that __call__ ≠ forward (hooks would fire if registered)
features_norm_dev = features_norm.to(device=DEVICE)
output_via_call   = model(features_norm_dev)     # correct — uses __call__

print(f"\n[4.1] Model class   : {model.__class__.__name__}")
print(f"[4.1] Input shape   : {features_norm_dev.shape}")
print(f"[4.1] Output shape  : {output_via_call.shape}")
print(f"[4.1] Model device  : {next(model.parameters()).device}")

# [WHAT ELSE]: nn.Sequential is a shorthand container for linear stacks of layers.
#              It's fine for simple architectures but cannot express skip connections,
#              multi-input/output, or any non-linear graph — use nn.Module for those.
#              nn.ModuleList and nn.ModuleDict are containers that register their
#              contents as submodules (unlike plain Python list/dict which don't).


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 4.2 — Parameters & Buffers")
print("="*72)
# ==============================================================================

# [WHAT]: Show the difference between nn.Parameter (learned, tracked by optimizer)
#         and register_buffer() (saved, moved with model, NOT trained).
# [WHY]:  Misclassifying a tensor as a plain attribute instead of a buffer is a
#         silent production bug: the value saves and loads fine in training, but
#         vanishes from state_dict() and resets to a wrong value in deployment.

class NetWithBuffer(nn.Module):
    # [WHAT]: A model that manually defines its own weight as nn.Parameter and
    #         stores a non-learnable normalisation constant as a buffer.

    def __init__(self, in_features: int, out_features: int):
        super().__init__()

        # nn.Parameter: explicitly learnable. Shows up in .parameters() and optimizer.
        self.weight = nn.Parameter(
            data=torch.randn(size=(out_features, in_features))
        )
        self.bias = nn.Parameter(
            data=torch.zeros(size=(out_features,))
        )

        # register_buffer: persisted in state_dict, moved by .to(device),
        # but EXCLUDED from .parameters() and optimizer updates.
        # Use case: running statistics, positional encodings, fixed masks.
        self.register_buffer(
            name='feature_scale',
            tensor=torch.tensor(data=[1.0, 2.0, 0.5, 1.5])   # non-learnable scaling
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x_scaled = x * self.feature_scale   # buffer used in computation
        return F.linear(input=x_scaled, weight=self.weight, bias=self.bias)


net_buf = NetWithBuffer(in_features=N_FEATURES, out_features=8)
net_buf = net_buf.to(device=DEVICE)

# Inspect what gets tracked
param_names   = [name for name, _ in net_buf.named_parameters()]
buffer_names  = [name for name, _ in net_buf.named_buffers()]
state_keys    = list(net_buf.state_dict().keys())

print(f"\n[4.2] Parameters (in optimizer) : {param_names}")
print(f"[4.2] Buffers    (not trained)  : {buffer_names}")
print(f"[4.2] state_dict keys (ALL)     : {state_keys}")
print(f"[4.2] feature_scale requires_grad: {net_buf.feature_scale.requires_grad}")
print(f"[4.2] weight       requires_grad: {net_buf.weight.requires_grad}")

# [WATCH OUT]: If you store a tensor as self.feature_scale = tensor (plain attribute,
#              not registered), it will NOT appear in state_dict(). Your model will
#              "save" and "load" successfully, but feature_scale will reset to its
#              __init__ value on load — a silent accuracy regression in production.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 4.3 — Inspecting Models")
print("="*72)
# ==============================================================================

# [WHAT]: Programmatically audit a model's architecture and count its parameters.
# [WHY]:  You should ALWAYS know your model's parameter count before training.
#         Unexpectedly large models blow VRAM. Unexpectedly small models underfit.
#         Named inspection is also how you implement differential learning rates.

print("\n[4.3] --- Full Model Architecture ---")
print(model)

# .named_children(): direct children only (1 level deep)
print("\n[4.3] --- Named Children (direct submodules) ---")
for child_name, child_module in model.named_children():
    print(f"  {child_name}: {child_module}")

# .named_modules(): ALL submodules recursively
print("\n[4.3] --- Named Modules (recursive) ---")
for mod_name, mod_obj in model.named_modules():
    if mod_name:   # skip the root module (empty string name)
        print(f"  '{mod_name}': {mod_obj.__class__.__name__}")

# Parameter counting: p.numel() returns number of elements in that tensor
total_params     = sum(p.numel() for p in model.parameters())
trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)

print("\n[4.3] --- Parameter Count ---")
for param_name, param in model.named_parameters():
    print(f"  {param_name:25s} | shape: {str(param.shape):20s} | count: {param.numel()}")

# Manual formula verification: Linear(4→16) = (4×16) + 16 = 80 params
hidden_expected = (N_FEATURES * 16) + 16   # (N×M) + M
output_expected = (16 * 1) + 1             # (N×M) + M
print(f"\n[4.3] Expected hidden layer params : ({N_FEATURES}×16)+16 = {hidden_expected}")
print(f"[4.3] Expected output layer params : (16×1)+1 = {output_expected}")
print(f"[4.3] Total trainable parameters   : {trainable_params}  (= {hidden_expected} + {output_expected})")

# [WHAT ELSE]: torchinfo (pip install torchinfo) provides a Keras-style model
#              summary with per-layer output shapes and parameter counts.
#              torchviz can render the actual computational graph as a PDF.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 5.1 — Linear (Dense) Layers")
print("="*72)
# ==============================================================================

# [WHAT]: Examine nn.Linear in detail — its internal weight shapes, the transpose
#         trick, and the geometric interpretation of affine transformation.
# [WHY]:  nn.Linear is the atom of deep learning. Understanding its exact mechanics
#         prevents the shape errors that plague every beginner (and many seniors).

# Standalone Linear layer for inspection
linear_layer = nn.Linear(in_features=N_FEATURES, out_features=8, bias=True)

print("\n[5.1] nn.Linear(in=4, out=8)")
print(f"[5.1] weight shape : {linear_layer.weight.shape}  ← stored as (out, in)")
print(f"[5.1] bias shape   : {linear_layer.bias.shape}")

# The affine transformation: Y = X @ W.T + b
# [HOW]: PyTorch stores weight as (out, in) but the math needs (in, out).
#        nn.Linear calls F.linear(x, weight, bias) which does: x @ weight.T + bias
batch_input     = features_norm[:5]                              # 5 samples, 4 features
manual_output   = batch_input @ linear_layer.weight.T + linear_layer.bias
layer_output    = linear_layer(batch_input)

print(f"\n[5.1] batch_input shape   : {batch_input.shape}")
print(f"[5.1] Manual Y=XW^T+b    : {manual_output.shape}")
print(f"[5.1] layer_output shape  : {layer_output.shape}")
print(f"[5.1] Manual == Layer     : {torch.allclose(input=manual_output, other=layer_output, atol=1e-6)}")

# Demonstrate projection: R^4 → R^8 (expanding the representation space)
print(f"\n[5.1] Input space  : R^{N_FEATURES} (4-dimensional)")
print(f"[5.1] Output space : R^{8} (8-dimensional — richer representation)")

# [WATCH OUT]: bias=True is the default. When using nn.Linear before BatchNorm,
#              set bias=False. BatchNorm subtracts the mean, which makes the bias
#              in the preceding Linear layer completely redundant — pure waste.

# [WHAT ELSE]: nn.Bilinear computes x1 @ W @ x2 + b, useful for interaction-based
#              models. nn.LazyLinear infers in_features from the first forward pass,
#              useful when the input size depends on runtime data shape.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 5.2 — Non-Linear Activations")
print("="*72)
# ==============================================================================

# [WHAT]: Apply ReLU, Sigmoid, and Softmax to the hidden layer output and verify
#         their mathematical properties empirically.
# [WHY]:  Without activations, stacking Linear layers collapses to one Linear layer.
#         Activations introduce the non-linearity that enables universal approximation.

# Get a clean hidden representation from our model
model.eval()    # disable dropout for clean output
with torch.no_grad():
    pre_activation = model.hidden(features_norm_dev)   # (200, 16), raw logits

# --- ReLU: f(x) = max(0, x) ---
# [HOW]: Zero out all negative values. Gradient = 1 for positives, 0 for negatives.
relu_out  = F.relu(input=pre_activation)
neg_count = (pre_activation < 0).sum().item()
dead_post = (relu_out == 0).sum().item()

print(f"\n[5.2] pre_activation shape    : {pre_activation.shape}")
print(f"[5.2] relu_out shape          : {relu_out.shape}")
print(f"[5.2] Negative pre-activations: {neg_count} / {pre_activation.numel()} ({100*neg_count/pre_activation.numel():.1f}%)")
print(f"[5.2] Zeroed by ReLU          : {dead_post} elements (potential dying ReLU if all come from same neuron)")

# --- Sigmoid: σ(x) = 1 / (1 + e^(-x)) ---
# [HOW]: Squashes all real numbers to (0, 1). Perfect for probability output.
sample_logits = torch.tensor(data=[-3.0, -1.0, 0.0, 1.0, 3.0])
sigmoid_out   = F.sigmoid(input=sample_logits)

print(f"\n[5.2] Sigmoid input  : {sample_logits.tolist()}")
print(f"[5.2] Sigmoid output : {[round(v, 4) for v in sigmoid_out.tolist()]}  ← all in (0, 1)")

# --- Softmax: exp(xi) / sum(exp(xj)) ---
# [HOW]: Converts logit vector to probability distribution summing to 1.
#        dim=-1 means normalise across the last dimension (the class dimension).
multi_class_logits = torch.randn(size=(5, 3))   # 5 samples, 3 classes
softmax_out        = F.softmax(input=multi_class_logits, dim=-1)
row_sums           = softmax_out.sum(dim=-1)     # should be all 1.0

print(f"\n[5.2] multi_class_logits (first row) : {[round(v,4) for v in multi_class_logits[0].tolist()]}")
print(f"[5.2] softmax_out (first row)        : {[round(v,4) for v in softmax_out[0].tolist()]}")
print(f"[5.2] Row sums (all must be 1.0)     : {[round(v,4) for v in row_sums.tolist()]}")

# [WATCH OUT]: nn.CrossEntropyLoss internally applies log_softmax before computing
#              the loss. If you apply softmax to your logits BEFORE passing them
#              to CrossEntropyLoss, you are double-applying it. The loss will be
#              numerically wrong and your model will train slowly or diverge.

# [WHAT ELSE]: F.gelu() (Gaussian Error Linear Unit) is the standard activation in
#              BERT, GPT, and most modern transformers — smoother than ReLU.
#              F.leaky_relu(negative_slope=0.01) addresses the dying ReLU problem
#              by allowing a small gradient for negative inputs.
#              F.silu() (Swish) is used in LLaMA and other modern architectures.

model.train()   # restore training mode


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 5.3 — Dropout & Regularization Layers")
print("="*72)
# ==============================================================================

# [WHAT]: Demonstrate the stochastic behaviour of Dropout in train mode and its
#         complete deactivation in eval mode. Verify the inverted scaling math.
# [WHY]:  Forgetting to switch modes is one of the most common PyTorch bugs.
#         Validation loss will appear artificially high if model.eval() is skipped.

dropout_layer = nn.Dropout(p=0.5)   # p=0.5: zero out 50% of neurons
demo_input    = torch.ones(size=(1, 10))   # all-ones to make the effect visible

# --- Train mode: stochastic zeroing + scaling ---
dropout_layer.train()
out_train_1 = dropout_layer(input=demo_input)
out_train_2 = dropout_layer(input=demo_input)   # different random mask each call

print(f"\n[5.3] Input (all ones)      : {demo_input.tolist()}")
print(f"[5.3] Dropout train call 1  : {out_train_1.tolist()}")
print(f"[5.3] Dropout train call 2  : {out_train_2.tolist()}  ← different mask!")
print(f"[5.3] Scaling factor 1/(1-p): {1/(1-0.5):.1f}x  (surviving neurons scaled up)")

# Verify: surviving elements should be 2.0 (1.0 * 1/(1-0.5) = 2.0)
non_zero_vals = out_train_1[out_train_1 != 0]
print(f"[5.3] Non-zero values in call 1: {non_zero_vals.tolist()}")

# --- Eval mode: deterministic, no dropout, no scaling ---
dropout_layer.eval()
out_eval = dropout_layer(input=demo_input)
print(f"\n[5.3] Dropout EVAL mode     : {out_eval.tolist()}  ← all ones, no dropout")

# Model-level train/eval switching
model.train()
print(f"\n[5.3] model.training flag   : {model.training}")
model.eval()
print(f"[5.3] After model.eval()    : {model.training}")
model.train()
print(f"[5.3] After model.train()   : {model.training}")

# [WATCH OUT]: model.eval() sets training=False on the module AND all its children
#              recursively. But if you have a module that's NOT a submodule (i.e.,
#              stored in a plain Python list instead of nn.ModuleList), model.eval()
#              will NOT reach it. Its dropout will still fire during validation.

# [WHAT ELSE]: nn.AlphaDropout normalises mean and variance post-drop to preserve
#              the self-normalising property of SELU activations.
#              nn.Dropout2d drops entire 2D feature map channels — appropriate after
#              conv layers because adjacent spatial pixels are highly correlated.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 6.1 — Loss Functions")
print("="*72)
# ==============================================================================

# [WHAT]: Compute MSELoss and CrossEntropyLoss on our dataset, verify the math,
#         and demonstrate why you'd choose one over the other.
# [WHY]:  The loss function IS the learning signal. A wrong loss function means
#         the model is optimising for the wrong thing — perfect code, wrong result.

model.eval()
with torch.no_grad():
    raw_predictions = model(features_norm_dev)   # shape (200, 1)

# --- MSELoss: regression ---
mse_criterion = nn.MSELoss(reduction='mean')
labels_norm   = (labels_reg_dev / 100.0).unsqueeze(dim=1)   # normalise targets to [0,1]

mse_loss = mse_criterion(input=raw_predictions, target=labels_norm)

# Verify manually: (1/N) * sum((y - y_hat)^2)
manual_mse = ((raw_predictions - labels_norm) ** 2).mean()
print(f"\n[6.1] MSE Loss (nn.MSELoss)  : {mse_loss.item():.6f}")
print(f"[6.1] MSE Loss (manual)      : {manual_mse.item():.6f}")
print(f"[6.1] Match                  : {torch.isclose(input=mse_loss, other=manual_mse).item()}")

# --- CrossEntropyLoss: classification ---
# Build a 2-class model for this demo (binary pass/fail)
clf_model = nn.Linear(in_features=N_FEATURES, out_features=2).to(device=DEVICE)
clf_model.eval()

with torch.no_grad():
    clf_logits = clf_model(features_norm_dev)   # shape (200, 2) — raw logits, NO softmax

# [WATCH OUT]: CrossEntropyLoss expects raw LOGITS (pre-softmax), not probabilities.
#              targets must be torch.long (int64), not float.
ce_criterion = nn.CrossEntropyLoss(reduction='mean')
ce_loss      = ce_criterion(input=clf_logits, target=labels_cls_dev)

print(f"\n[6.1] CrossEntropy Loss      : {ce_loss.item():.6f}")
print(f"[6.1] clf_logits shape       : {clf_logits.shape}  ← (N, num_classes) raw logits")
print(f"[6.1] labels_cls dtype       : {labels_cls_dev.dtype}  ← must be torch.long")

# Manually verify: L = -sum(y_i * log(softmax(logit_i))) for one sample
sample_logit = clf_logits[0]
sample_label = labels_cls_dev[0].item()
probs        = F.softmax(input=sample_logit, dim=-1)
manual_ce    = -torch.log(probs[sample_label])
print(f"\n[6.1] Sample 0 logits        : {[round(v,4) for v in sample_logit.tolist()]}")
print(f"[6.1] Sample 0 true label    : {sample_label}")
print(f"[6.1] Sample 0 manual CE     : {manual_ce.item():.6f}  (single sample, no batch avg)")

# [WHAT ELSE]: nn.BCEWithLogitsLoss is numerically preferred for binary classification
#              over manual Sigmoid + BCELoss, because it fuses them in one stable op.
#              nn.HuberLoss blends MSE (for small errors) with MAE (for large errors),
#              making it more robust to outliers in regression tasks.

model.train()


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 6.2 — The Optimizer (SGD / Adam)")
print("="*72)
# ==============================================================================

# [WHAT]: Run a single optimisation step with both SGD and Adam. Compare the
#         weight update magnitudes and demonstrate the mandatory zero_grad ritual.
# [WHY]:  The optimizer is the only thing that actually changes the model's weights.
#         Understanding its mechanics (especially Adam's adaptive scaling) determines
#         your ability to diagnose training instability.

# --- SGD ---
# [HOW]: W_new = W_old - lr * gradient
sgd_model     = SimpleNet(in_features=N_FEATURES, hidden_size=16, out_features=1).to(device=DEVICE)
sgd_optimizer = optim.SGD(params=sgd_model.parameters(), lr=0.01, momentum=0.9)

sgd_model.train()
sgd_optimizer.zero_grad()                          # Step 1: clear old gradients
sgd_out  = sgd_model(features_norm_dev)            # Step 2: forward pass
sgd_loss = mse_criterion(input=sgd_out, target=labels_norm)  # Step 3: compute loss
sgd_loss.backward()                                # Step 4: backward pass
sgd_optimizer.step()                               # Step 5: update weights

print(f"\n[6.2] SGD optimizer  | loss: {sgd_loss.item():.6f}")
print(f"[6.2] hidden.weight grad norm : {sgd_model.hidden.weight.grad.norm().item():.6f}")

# --- Adam ---
# [HOW]: Maintains first moment (mean gradient) and second moment (variance of gradient)
#        per parameter. Effective learning rate: lr / (sqrt(v_t) + ε)
adam_model     = SimpleNet(in_features=N_FEATURES, hidden_size=16, out_features=1).to(device=DEVICE)
adam_optimizer = optim.Adam(params=adam_model.parameters(), lr=0.001, betas=(0.9, 0.999), eps=1e-8)

adam_model.train()
adam_optimizer.zero_grad()
adam_out  = adam_model(features_norm_dev)
adam_loss = mse_criterion(input=adam_out, target=labels_norm)
adam_loss.backward()

# Inspect gradient BEFORE step
w_before = adam_model.hidden.weight.data.clone()
adam_optimizer.step()
w_after  = adam_model.hidden.weight.data.clone()

weight_delta = (w_after - w_before).abs().mean().item()
print(f"\n[6.2] Adam optimizer | loss: {adam_loss.item():.6f}")
print(f"[6.2] Mean absolute weight update (Adam): {weight_delta:.8f}")

# [WATCH OUT]: Adam maintains internal state (moment buffers) per parameter.
#              If you create a NEW optimizer mid-training (e.g., after reloading
#              a checkpoint without saving the optimizer state), Adam loses its
#              accumulated moments and the first few steps behave like vanilla SGD.
#              Always save AND load optimizer.state_dict() alongside model.state_dict().

# [WHAT ELSE]: optim.AdamW adds decoupled weight decay (L2 regularisation applied
#              directly to weights, not via gradient), and is the standard optimizer
#              for transformer pretraining (BERT, GPT). optim.RMSprop is Adam's
#              precursor, still used in some RL algorithms (DQN).


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 6.3 — Learning Rate Scheduling")
print("="*72)
# ==============================================================================

# [WHAT]: Attach a scheduler to the Adam optimizer and observe the LR decaying
#         across epochs. Verify the exponential decay formula numerically.
# [WHY]:  A fixed learning rate is almost always suboptimal. Scheduling gives you
#         fast early progress (large LR) and precise late convergence (small LR).

INITIAL_LR = 0.01
GAMMA      = 0.85   # decay factor: LR shrinks by 15% every epoch

sched_model     = SimpleNet(in_features=N_FEATURES, hidden_size=16, out_features=1).to(device=DEVICE)
sched_optimizer = optim.Adam(params=sched_model.parameters(), lr=INITIAL_LR)
scheduler       = optim.lr_scheduler.ExponentialLR(optimizer=sched_optimizer, gamma=GAMMA)

print(f"\n[6.3] Initial LR: {INITIAL_LR}")
print(f"[6.3] Decay gamma: {GAMMA}  (LR × {GAMMA} per epoch)")
print(f"\n[6.3] {'Epoch':>6} | {'LR (actual)':>14} | {'LR (formula)':>14} | {'Match':>6}")
print("       " + "-"*46)

sched_model.train()
for epoch in range(6):
    # Simulate one training iteration
    sched_optimizer.zero_grad()
    out_s  = sched_model(features_norm_dev)
    loss_s = mse_criterion(input=out_s, target=labels_norm)
    loss_s.backward()
    sched_optimizer.step()

    # Get actual current LR from optimizer param_groups
    current_lr  = sched_optimizer.param_groups[0]['lr']
    formula_lr  = INITIAL_LR * (GAMMA ** epoch)
    match       = abs(current_lr - formula_lr) < 1e-10

    print(f"       {epoch:>6} | {current_lr:>14.8f} | {formula_lr:>14.8f} | {str(match):>6}")

    # scheduler.step() must be called AFTER optimizer.step()
    scheduler.step()

# [WATCH OUT]: scheduler.step() in PyTorch < 1.1 was called BEFORE optimizer.step().
#              Since PyTorch 1.1, the correct order is optimizer.step() THEN
#              scheduler.step(). Swapping them throws a UserWarning and skips epoch 0.

# [WHAT ELSE]: lr_scheduler.CosineAnnealingLR gives a smooth cosine curve decay
#              which many practitioners prefer for its "soft landing" near the minimum.
#              lr_scheduler.OneCycleLR implements the 1-cycle superconvergence policy
#              (warmup → peak → anneal) and often trains in 1/3 the epochs.
#              lr_scheduler.ReduceLROnPlateau reduces LR when val loss stagnates —
#              the safest scheduler for experiments where you don't know the schedule.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 7.1 — The Custom Dataset Class")
print("="*72)
# ==============================================================================

# [WHAT]: Implement a proper map-style PyTorch Dataset that wraps our numpy arrays,
#         enforcing the __len__ / __getitem__ contract from torch.utils.data.Dataset.
# [WHY]:  The Dataset class is the universal abstraction that decouples storage
#         backends (numpy, SQL, S3, HDF5) from the training loop. Once you
#         implement this contract, the DataLoader handles batching and parallelism
#         automatically with zero changes to your training code.

class ExamScoreDataset(data.Dataset):
    # [WHAT]: Map-style dataset over our in-memory numpy arrays.
    #         Index i maps to the feature vector X_i and its labels.
    # [WHY]:  Using the abstract Dataset class means this can be swapped for a
    #         SQL-backed or S3-backed version without changing the training loop.

    def __init__(
        self,
        features_array: np.ndarray,
        scores_array:   np.ndarray,
        labels_array:   np.ndarray
    ):
        # [HOW]: Convert numpy arrays to tensors once in __init__, not per-sample.
        #        Doing the conversion in __getitem__ would re-allocate tensors on
        #        every call — multiplied by N_SAMPLES * N_EPOCHS = millions of allocs.
        self.features = torch.tensor(data=features_array, dtype=torch.float32)
        self.scores   = torch.tensor(data=scores_array,   dtype=torch.float32)
        self.labels   = torch.tensor(data=labels_array,   dtype=torch.long)

    def __len__(self) -> int:
        # [WHAT]: Return total number of samples in the dataset.
        # [WHY]:  DataLoader uses __len__ to build the index space [0, N-1] for
        #         shuffling and to know when an epoch is complete.
        return len(self.features)

    def __getitem__(self, index: int) -> tuple:
        # [WHAT]: Return the sample at position `index` as (features, score, label).
        # [WHY]:  Map-style datasets must support O(1) random access. The DataLoader
        #         calls this in parallel across multiple worker processes.
        # [WATCH OUT]: index can also be a LIST of integers (fancy indexing) when the
        #              DataLoader is in batch mode with a custom collate_fn. Tensor
        #              indexing handles both int and list transparently.
        return self.features[index], self.scores[index], self.labels[index]


# Instantiate and verify the contract
np_scores  = exam_score.astype(np.float32)
np_passed  = passed.astype(np.int64)

full_dataset   = ExamScoreDataset(
    features_array=np_features.astype(np.float32),
    scores_array=np_scores,
    labels_array=np_passed
)

# Verify __len__
print(f"\n[7.1] Dataset length (__len__)     : {len(full_dataset)}")

# Verify __getitem__
sample_feat, sample_score, sample_label = full_dataset[0]
print(f"[7.1] Sample 0 features           : {sample_feat.tolist()}")
print(f"[7.1] Sample 0 exam_score         : {sample_score.item():.2f}")
print(f"[7.1] Sample 0 passed label       : {sample_label.item()}")

# Verify index mapping: i → X_i
print("\n[7.1] Index mapping demo (i=42):")
feat_42, score_42, label_42 = full_dataset[42]
print(f"[7.1]   features[42]  : {feat_42.tolist()}")
print(f"[7.1]   score[42]     : {score_42.item():.2f}")
print(f"[7.1]   label[42]     : {label_42.item()}")

# Build DataLoader — wraps Dataset in batching + shuffling machinery
loader = data.DataLoader(
    dataset=full_dataset,
    batch_size=32,
    shuffle=True,
    num_workers=0   # 0 = run in main process (safe for this demo)
)
first_batch_feat, first_batch_score, first_batch_label = next(iter(loader))
print("\n[7.1] DataLoader first batch:")
print(f"[7.1]   features shape : {first_batch_feat.shape}   (batch_size=32, features=4)")
print(f"[7.1]   scores shape   : {first_batch_score.shape}  (32 scalar targets)")
print(f"[7.1]   labels shape   : {first_batch_label.shape}  (32 class indices)")

# [WHAT ELSE]: torch.utils.data.IterableDataset is for streaming datasets where
#              random access is impossible (e.g., Kafka streams, real-time sensors).
#              It implements __iter__ instead of __getitem__, and cannot shuffle.
#              torch.utils.data.random_split() splits a Dataset into non-overlapping
#              train/val/test subsets without copying data.


# ==============================================================================
print("\n\n" + "="*72)
print("  SEGMENT 7.2 — Integrating SQL with Datasets")
print("="*72)
# ==============================================================================

# [WHAT]: Build a production-style Dataset that fetches records from SQLite on
#         demand rather than holding all data in RAM. Demonstrate both per-row
#         and batch-prefetch query strategies.
# [WHY]:  In real MLOps, your dataset is a PostgreSQL table with 50 million rows.
#         You CANNOT load it into RAM. The SQLDataset pattern streams data from
#         the DB just-in-time, keeping memory flat regardless of dataset size.

class SQLExamDataset(data.Dataset):
    # [WHAT]: Map-style Dataset backed by a SQLite database.
    #         Each __getitem__ call issues a live SQL query to fetch one record.
    # [WHY]:  Decouples the training loop from storage backend entirely.
    #         Swap SQLite for PostgreSQL/BigQuery with only a connection string change.

    def __init__(self, db_path: str, table_name: str):
        self.db_path    = db_path
        self.table_name = table_name

        # [HOW]: Fetch total row count once at construction time for __len__().
        #        We don't materialise any feature data — only the count.
        # [WATCH OUT]: Do NOT hold a sqlite3.Connection as self.conn here.
        #              When DataLoader spawns multiple worker subprocesses, each worker
        #              inherits the parent's file descriptor via fork. SQLite connections
        #              are NOT safe to share across processes — you'll get database
        #              corruption or random errors. Create a fresh connection per
        #              __getitem__ call (or in a worker_init_fn for efficiency).
        conn         = sqlite3.connect(self.db_path)
        cursor       = conn.cursor()
        cursor.execute(f"SELECT COUNT(*) FROM {self.table_name}")
        self._length = cursor.fetchone()[0]
        conn.close()

    def __len__(self) -> int:
        return self._length

    def __getitem__(self, index: int) -> tuple:
        # [WHAT]: Fetch exactly one row by its integer index (treated as row id).
        # [HOW]:
        #   1. Open a fresh connection (safe for multiprocessing).
        #   2. Execute a parameterised SELECT with LIMIT 1 OFFSET index.
        #      O(1) complexity via ROWID lookup when fetching by primary key.
        #   3. Unpack the row tuple and cast to tensors.
        # [WATCH OUT]: Using OFFSET for large tables is O(n) in SQLite — it scans
        #              from the start. For production, always query by primary key:
        #              SELECT ... WHERE id = ? using a persistent ID-to-index map.
        conn   = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute(
            f"SELECT study_hours, sleep_hours, practice_probs, prev_gpa, exam_score, passed "
            f"FROM {self.table_name} WHERE id = ?",
            (index,)
        )
        row = cursor.fetchone()
        conn.close()

        # Unpack and cast
        study_h, sleep_h, prac_p, gpa, score, label = row

        features_t = torch.tensor(
            data=[study_h, sleep_h, prac_p, gpa],
            dtype=torch.float32
        )
        score_t = torch.tensor(data=score, dtype=torch.float32)
        label_t = torch.tensor(data=label, dtype=torch.long)

        return features_t, score_t, label_t


class SQLBatchPrefetchDataset(data.Dataset):
    # [WHAT]: Optimised SQL Dataset that fetches B rows per query instead of 1.
    # [WHY]:  Per-row queries at N=200 means 200 round-trips per epoch.
    #         At N=1M rows and 100 epochs, that's 100 million DB round-trips.
    #         Batch prefetching amortises connection latency across B rows:
    #         total queries = O(N/B) instead of O(N).

    def __init__(self, db_path: str, table_name: str, prefetch_size: int = 10):
        self.db_path       = db_path
        self.table_name    = table_name
        self.prefetch_size = prefetch_size

        conn         = sqlite3.connect(self.db_path)
        cursor       = conn.cursor()
        cursor.execute(f"SELECT COUNT(*) FROM {self.table_name}")
        self._length = cursor.fetchone()[0]
        conn.close()

    def __len__(self) -> int:
        return self._length

    def __getitem__(self, index: int) -> tuple:
        # [HOW]: Fetch a window of prefetch_size rows starting at index.
        #        Return only the item at position 0 of the fetched window.
        #        In a real implementation, cache the window to avoid redundant queries.
        batch_start = (index // self.prefetch_size) * self.prefetch_size
        batch_ids   = list(range(batch_start, min(batch_start + self.prefetch_size, self._length)))
        placeholders = ",".join(["?"] * len(batch_ids))

        conn   = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute(
            f"SELECT study_hours, sleep_hours, practice_probs, prev_gpa, exam_score, passed "
            f"FROM {self.table_name} WHERE id IN ({placeholders})",
            batch_ids
        )
        rows = cursor.fetchall()
        conn.close()

        # Return only the specific row requested
        local_index = index - batch_start
        study_h, sleep_h, prac_p, gpa, score, label = rows[local_index]

        return (
            torch.tensor(data=[study_h, sleep_h, prac_p, gpa], dtype=torch.float32),
            torch.tensor(data=score,  dtype=torch.float32),
            torch.tensor(data=label,  dtype=torch.long)
        )


# --- Instantiate and benchmark both strategies ---
sql_dataset         = SQLExamDataset(db_path=DB_PATH, table_name='students')
sql_batch_dataset   = SQLBatchPrefetchDataset(db_path=DB_PATH, table_name='students', prefetch_size=10)

print(f"\n[7.2] SQLExamDataset length            : {len(sql_dataset)}")
print(f"[7.2] SQLBatchPrefetchDataset length   : {len(sql_batch_dataset)}")

# Fetch and compare identical samples from both
feat_sql,   score_sql,   label_sql   = sql_dataset[5]
feat_batch, score_batch, label_batch = sql_batch_dataset[5]

print(f"\n[7.2] Single-row Dataset  sample[5] features : {feat_sql.tolist()}")
print(f"[7.2] Batch-fetch Dataset sample[5] features : {feat_batch.tolist()}")
print(f"[7.2] Results match : {torch.allclose(input=feat_sql, other=feat_batch)}")

# Query cost analysis
print("\n[7.2] --- Query Cost Analysis ---")
print(f"[7.2] Per-row strategy  (N=200)          : {N_SAMPLES} queries  — O(N)")
print(f"[7.2] Batch-fetch (B=10, N=200)          : {N_SAMPLES // 10} queries  — O(N/B)")
print(f"[7.2] Reduction factor                   : {N_SAMPLES // (N_SAMPLES // 10)}x fewer round-trips")

# Wrap SQL dataset in DataLoader to prove full pipeline works
sql_loader = data.DataLoader(
    dataset=sql_dataset,
    batch_size=16,
    shuffle=False,
    num_workers=0   # MUST be 0 for SQLite — see [WATCH OUT] above
)
sql_batch_feat, sql_batch_score, sql_batch_label = next(iter(sql_loader))
print("\n[7.2] SQL DataLoader first batch:")
print(f"[7.2]   features shape : {sql_batch_feat.shape}")
print(f"[7.2]   scores shape   : {sql_batch_score.shape}")
print(f"[7.2]   labels shape   : {sql_batch_label.shape}")

# [WHAT ELSE]: In production, SQLAlchemy (not raw sqlite3) is the standard —
#              create_engine() provides connection pooling, ORM mapping, and
#              cross-database compatibility (PostgreSQL, MySQL, BigQuery).
#              worker_init_fn in DataLoader(worker_init_fn=fn) is the hook to
#              create per-worker DB connections safely in multiprocessing mode.
#              For large datasets, consider WebDataset (tar-file streaming) or
#              NVIDIA DALI for GPU-accelerated data preprocessing pipelines.


# ==============================================================================
print("\n\n" + "="*72)
print("  MEGA-BATCH COMPLETE — All 20 Segments Executed")
print("="*72)
print("""
  SUMMARY OF CONCEPTS DEMONSTRATED:
  Phase 1 (Tensors)  : torch.tensor, device management, dtypes, memory math,
                       matmul, dot, element-wise ops
  Phase 1 (Manip)    : view, reshape, permute, transpose, contiguous,
                       boolean masking, torch.where, torch.gather, broadcasting
  Phase 1 (Autograd) : requires_grad, DAG, leaf/intermediate nodes,
                       backward, chain rule, grad accumulation, detach,
                       no_grad, inference_mode, .item()
  Phase 2 (nn.Module): class inheritance, super().__init__, __call__ vs forward,
                       nn.Parameter, register_buffer, state_dict,
                       named_parameters, named_children, param count formula
  Phase 2 (Layers)   : nn.Linear, affine transform Y=XW^T+b,
                       F.relu, F.sigmoid, F.softmax,
                       nn.Dropout, inverted scaling, train/eval modes
  Phase 2 (Training) : MSELoss, CrossEntropyLoss,
                       SGD + momentum, Adam + adaptive LR,
                       zero_grad + step ritual,
                       ExponentialLR scheduler
  Phase 3 (Data)     : Abstract Dataset class, __len__, __getitem__,
                       map-style indexing, DataLoader,
                       SQLite-backed Dataset, per-row vs batch-fetch query cost
""")
print("  Run successfully? Head back to Chijioke for The Crucible. 🔥")
print("="*72 + "\n")