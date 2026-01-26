import os
import matplotlib
import numpy as np
import pandas as pd
import seaborn as sns
matplotlib.use('TkAgg')
from scipy import stats
from dotenv import load_dotenv
import matplotlib.pyplot as plt
from sqlalchemy import create_engine
load_dotenv()

array_1 = np.array([2, 1, 3, 0, 233])

array_mean = np.mean(array_1) # mean is very sensitive to outliers

array_median = np.median(array_1) # median is robust to outliers, because it evaluates values based on their rank, not their size

array_variance = np.var(array_1) # finds the average of the squared differences between data-points and their mean

array_std = np.std(array_1) # standard deviation is the square-root of the variance


print(f'''
Orginal Data: {array_1}

Mean (Skewed by outlier): {array_mean:.2f}

Median (robust to outlier): {array_median}

Variance: {array_variance:.2f}

Standard Deviation: {array_std:.3f}
''')


# ======================================== Matplotlib & Seaborn ========================================


figure, axes = plt.subplots(figsize = (10, 6))

axes.plot(array_1, label = "Numpy Array", marker = "o", linestyle = "-") # notice we used axes.plot, not plt.plot (we plot on the axes, not the figure)

# Visualizing Mean vs. Median

axes.axhline(array_mean, c = "r", linestyle = "--", label = f"Mean ({array_mean:.2f})")

axes.axhline(array_median, c = "green", linestyle = "-", label = f"Median ({array_median:.2f})")

axes.set_title("Array, Mean vs. Median")

axes.set_xlabel("X-Axis")

axes.set_ylabel("Y-Axis")

axes.legend()

print(f"Figure Object {type(figure)}")

print(f"Axes Object {type(axes)}")

plt.show()










































































"""
We will demonstrate the Object-Oriented approach (Segment 1.2)
while enforcing the Hierarchy concepts (Segment 1.1).
"""

print("\n===================================== Visualizing Data (The Architect Way) =====================================\n")

# let's create fake data to work with
t_x = np.linspace(0, 10, 100)

t_y1 = np.sin(t_x)

t_y2 = np.cos(t_x)

"""
Matplotlib Hierachy:
1. The figure: This is the wall, or picture stand we're working on. It's job is to hold every drawing you create
2. The Axes: This is the canvas we place on the figure. You can have 1 or multiple canvases
"""

figure, (axes1, axes2) = plt.subplots(nrows = 2, ncols = 1, figsize = (8, 6))

print(f'''
Type of "figure": {type(figure)}

Type of "axes1": {type(axes1)}
''')

# ===================================== Plotting on canvas 1 (axes1) =====================================

# we use the axes to plot, not plt
# not plt.plot(), but axes1.plot()

axes1.plot(t_x, t_y1, c = "b", label = "Sine Wave")

axes1.set_title("The Sine Wave (Canvas 1)") # Note: it's .set_title(), not .title()

axes1.set_ylabel("Amplitude (h)")
axes1.legend(loc = "upper left")
axes1.grid(True, alpha = 0.3)

# ===================================== Plotting on Canvas 2 (axes2) =====================================

axes2.plot(t_x, t_y2, c = "r", linestyle = "--", label = "Cosine Wave")

# setting titles and labels...
axes2.set_title("The Cosine Wave (Canvas 2)")
axes2.set_xlabel("Time (s)")
axes2.set_ylabel("Amplitude")


axes2.legend(loc = "upper right")

axes2.grid(True, alpha = 0.4)

# we use .tight_layout() to adjust the layout so the Wall doesn't look crowded

plt.tight_layout()

print("Plot generated successfully using OO approach.")
plt.show()









































































np.random.seed(199)

# generating sample data with noise using np.random
x_axis = np.linspace(0, 10, 100)

y_axis = np.sin(x_axis) + np.random.normal(0, 0.1, 100) # we're creating a sine wave and adding a bit of noise



# ===================================== LOW RESOLUTION =====================================

# extracting figure and axes
low_res_figure, low_res_axes = plt.subplots(
    figsize = (8, 4),

    dpi = 80
)


# Plotting on low resolution axes
low_res_axes.plot(x_axis, y_axis, c = "orange", linestyle = '--')

# setting title and labels for x & y axis...
low_res_axes.set_title("Web Preview (Low DPI)", fontsize = 13)

low_res_axes.set_xlabel("Time (s)")

low_res_axes.set_ylabel("Amplitude")



# ===================================== HIGH RESOLUTION =====================================

high_res_figure, high_res_axes = plt.subplots(figsize = (10, 7), dpi = 150)

high_res_axes.plot(x_axis, y_axis, c = 'crimson', linewidth = 2, linestyle = '--')


high_res_axes.set_title("Print Quality (High DPI)")

high_res_axes.set_xlabel("Time (s)")

high_res_axes.set_ylabel("Amplitude")

# ===================================== SAVING LOW RES IMAGE =====================================

# saving low_res_figure as low resolution png Raster image...
low_res_figure.savefig("sine_wave_low_pic.png", bbox_inches = "tight")


# ===================================== SAVING HIGH RES IMAGE =====================================

# saving high_res_figure as high resolution svg Vector image...
high_res_figure.savefig("sine_wave_high_pic.svg", format = "svg", bbox_inches = "tight")


# saving high_res_figure as high resolution pdf Vector...
high_res_figure.savefig("sine_wave_high_pic.pdf", format = "pdf", bbox_inches = "tight")

plt.show()

# cleaning up memory (very Important in large scale production)
plt.close(low_res_figure)
plt.close(high_res_figure)













































































entries = 300

server_logs = pd.DataFrame({
    "latency_ms": np.random.normal(loc = 150, scale = 30, size = entries), # Normal dist
    "throughput_mb": np.random.uniform(low = 10, high = 100, size = entries), # Uniform dist
    "server_region": np.random.choice(['US-East', 'EU-West'], size = entries), # Categorical
    "status": np.random.choice(['Healthy', 'Warning'], size = entries, p = [0.8, 0.2]) # Categorical
})



# ===================================== AXES-LEVEL APPROACH =====================================

# creating canvas

figure, (axes_1, axes_2, axes_3) = plt.subplots(1, 3, figsize = (16, 5))

# Plotting a Scatterplot on axes_1
sns.scatterplot(data = server_logs, x = "throughput_mb", y = "latency_ms", hue = 'status', ax = axes_1)

# setting the title for axes_1...
axes_1.set_title("Network Latency vs. Throughput")


# setting the content for axes_2
sns.boxplot(
    data = server_logs,
    x = 'server_region',
    y = 'latency_ms',
    ax = axes_2
)

# setting the title for axes_2 and axes_3...
axes_2.set_title("Latency Distribution by Region")
axes_3.set_title("Testing on axes_3 with Scatterplot of sample")



# setting the content for axes_3
axes_3.scatter(
    server_logs["throughput_mb"].sample(25),
    server_logs["latency_ms"].sample(25),    
    c = 'orange'
)


figure.suptitle("Axes-Level Functions",
    fontsize = 19,
    color = 'red',
    fontweight = 'bold'
)

figure.tight_layout()

plt.close(figure)




# ===================================== FIGURE-LEVEL APPROACH =====================================

fig_level = sns.relplot(
    data = server_logs,
    x = 'throughput_mb',
    y = 'latency_ms',
    hue = 'status',
    col = 'server_region',
    kind = 'scatter',
    height = 4,
    aspect = 5
)

# plt.tight_layout()

fig_level.fig.suptitle('Latency Analysis Faceted by Region', y = 1.03)

plt.show()





















































































# creating dataset to be used
dataset = pd.DataFrame({
    'Epoch': list(range(1, 51)) * 2,

    'Loss': np.concatenate([
        np.linspace(2.0, 0.5, 50) + np.random.normal(0, 0.1, 50),
        np.linspace(1.5, 0.2, 50)
    ]),

    'Model': np.random.choice(['Model A', 'Model B'], size = 100, p = [0.67, 0.33])
})



# ===================================== ANALYSIS =====================================

sns.set_theme(style = 'darkgrid')

sns.set_context('notebook')

# plt.figure(figsize = (8, 5))

figure, axes = plt.subplots(figsize = (8, 5))


"""
sns.lineplot() is used to visualize the relationship between two variables by drawing a line across data points


Parameters:
- data: The dataset (typically a pandas DataFrame) containing the variables to plot.

- x, y: The names of the columns in data to be plotted on the horizontal and vertical axes.

- hue: A grouping variable that produces lines with different colors to represent different categories (e.g., different models).

- ax: The specific matplotlib Axes object where the plot will be drawn, useful for placing plots in a grid or subplots. 


- style: Assigns different line patterns (e.g., dashed vs. solid) to categories. Using the same variable for both hue and style makes the plot more accessible for colorblind users.

- markers: Adds distinct dots/shapes at each data point to make specific values easier to identify.

- errorbar: Controls how uncertainty is displayed (e.g., standard deviation sd or confidence interval ci).

- palette: Specifies a custom color scheme for the hue groups. 


sns.lineplot(
    data = dataset,
    x = 'Epoch',
    y = 'Loss',
    hue = 'Model',
    style = 'Model',     # Adds different line styles (solid/dashed) for each model
    markers = True,      # Adds dots at each data point
    errorbar = 'sd',     # Shows standard deviation instead of 95% CI
    palette = 'viridis', # Uses a specific color theme
    ax = axes
)

"""


sns.lineplot(
    data = dataset,
    x = 'Epoch',
    y = 'Loss',
    hue = 'Model',
    ax = axes,
)

# adding a title on the figure
figure.suptitle("Analyst View (Darkgrid)")

# saving the figure...
# figure.savefig('theme_analyst.svg', format = 'svg', bbox_inches = 'tight')


plt.clf() # this clears the figure (w white screen is shown, with nothing plotted inside)



# ===================================== PRESENTATION =====================================


# White looks better for slides/presentations
sns.set_theme(style = 'whitegrid')

# context = 'talk' makes lines thicker and fonts bigger so that everyone including those at the back can see it when you're making a presentation
sns.set_context(context = 'talk', font_scale = 1.1)

"""
You can change the figure size after it has been created by using the set_size_inches() method on your figure object.

1. figure.set_size_inches(width, height): 
This is the most common way to change both dimensions at once

2. figure.set_figwidth(value):
Use this to change only the width.

3. figure.set_figheight(value):
Use this to change only the height.
"""

figure.set_size_inches(w = 8, h = 5)

sns.lineplot(
    data = dataset,
    x = 'Epoch',
    y = 'Loss',
    hue = 'Model',
    palette = 'viridis',
    # ax = axes,
    style = 'Model'
)

sns.despine() # this is used to remove axes lines, to provide a more modern look!

# adding an over-head title...
figure.suptitle("Executive View (Clean)")

# saving the figure...
# figure.savefig('theme_executive.svg', format = 'svg', bbox_inches = 'tight')


# displaying the figure
plt.show()














































































































array_1 = np.array([2, 1, 3, 0, 233])

array_mean = np.mean(array_1) # mean is very sensitive to outliers

array_median = np.median(array_1) # median is robust to outliers, because it evaluates values based on their rank, not their size

array_variance = np.var(array_1) # finds the average of the squared differences between data-points and their mean

array_std = np.std(array_1) # standard deviation is the square-root of the variance


print(f'''
Orginal Data: {array_1}

Mean (Skewed by outlier): {array_mean:.2f}

Median (robust to outlier): {array_median}

Variance: {array_variance:.2f}

Standard Deviation: {array_std:.3f}
''')


# ======================================== Matplotlib & Seaborn ========================================


figure, axes = plt.subplots(figsize = (10, 6))

axes.plot(array_1, label = "Numpy Array", marker = "o", linestyle = "-") # notice we used axes.plot, not plt.plot (we plot on the axes, not the figure)

# Visualizing Mean vs. Median

axes.axhline(array_mean, c = "r", linestyle = "--", label = f"Mean ({array_mean:.2f})")

axes.axhline(array_median, c = "green", linestyle = "-", label = f"Median ({array_median:.2f})")

axes.set_title("Array, Mean vs. Median")

axes.set_xlabel("X-Axis")

axes.set_ylabel("Y-Axis")

axes.legend()

print(f"Figure Object {type(figure)}")

print(f"Axes Object {type(axes)}")

plt.show()










































































"""
We will demonstrate the Object-Oriented approach (Segment 1.2)
while enforcing the Hierarchy concepts (Segment 1.1).
"""

print("\n===================================== Visualizing Data (The Architect Way) =====================================\n")

# let's create fake data to work with
t_x = np.linspace(0, 10, 100)

t_y1 = np.sin(t_x)

t_y2 = np.cos(t_x)

"""
Matplotlib Hierachy:
1. The figure: This is the wall, or picture stand we're working on. It's job is to hold every drawing you create
2. The Axes: This is the canvas we place on the figure. You can have 1 or multiple canvases
"""

figure, (axes1, axes2) = plt.subplots(nrows = 2, ncols = 1, figsize = (8, 6))

print(f'''
Type of "figure": {type(figure)}

Type of "axes1": {type(axes1)}
''')

# ===================================== Plotting on canvas 1 (axes1) =====================================

# we use the axes to plot, not plt
# not plt.plot(), but axes1.plot()

axes1.plot(t_x, t_y1, c = "b", label = "Sine Wave")

axes1.set_title("The Sine Wave (Canvas 1)") # Note: it's .set_title(), not .title()

axes1.set_ylabel("Amplitude (h)")
axes1.legend(loc = "upper left")
axes1.grid(True, alpha = 0.3)

# ===================================== Plotting on Canvas 2 (axes2) =====================================

axes2.plot(t_x, t_y2, c = "r", linestyle = "--", label = "Cosine Wave")

# setting titles and labels...
axes2.set_title("The Cosine Wave (Canvas 2)")
axes2.set_xlabel("Time (s)")
axes2.set_ylabel("Amplitude")


axes2.legend(loc = "upper right")

axes2.grid(True, alpha = 0.4)

# we use .tight_layout() to adjust the layout so the Wall doesn't look crowded

plt.tight_layout()

print("Plot generated successfully using OO approach.")
plt.show()






































































# we create a function for Extracting data. This is pure software Engineering because it makes data Extraction flexible
# ie, we can rewrite the entire data_extraction_and_loading() function to Extract data a diffrent way without affecting the main codebase
def data_extraction_and_loading():

    data = sns.load_dataset("diamonds")

    return data


# Initializing the data
diamonds_dataset = data_extraction_and_loading()

# we set up our figure and axes
figure, canvas_axes = plt.subplots(ncols = 3, nrows = 1, figsize = (19, 7), constrained_layout = True) # constrained_layout = True automatically adjusts the spacing between subplots, labels, titles, and tick labels to prevent overlaps.



# ===================================== PLOT A: HIGH BIAS (UNDERFITTING) =====================================

canvas_axes[0].set_title("High Bias: Too few bins (10)\nHides Details")

sns.histplot(
    data = diamonds_dataset, x = 'price',
    bins = 10, # we're setting bins to 10, too few for a 53940 entry dataset
    ax = canvas_axes[0], color = 'skyblue',
    edgecolor = 'black'
)



# ===================================== PLOT B: HIGH VARIANCE (OVERFITTING) =====================================

canvas_axes[1].set_title("High Variance: Too Many Bins (2000)\n(Visualizes Noise)")

sns.histplot(
    data = diamonds_dataset, x = 'price',
    bins = 2000, # too many bins for a 54k dataset
    ax = canvas_axes[1], color = 'salmon',
    edgecolor = None # remove edges, otherwise it's just a black blob
)



# ===================================== PLOT C: THE 'BEST' ZONE + NORMALIZATION =====================================

# Here, Seaborn uses algorithms like "Sturges" or "Freedman-Diaconis" which calculate the optimal bin width based on the data's Interquartile Range (IQR) and sample size (N).


canvas_axes[2].set_title("Optimal: Auto Bins + Density Norm\n(True Distribution)")

sns.histplot(
    bins = 'auto', # Optimal approach: Algorithms calculate best width based on IQR.
    data = diamonds_dataset, x = 'price',
    stat = 'density', # NORMALIZATION: Y-axis is now Probability Density, not Count.
    # This allows us to compare this dataset with another of diff size.
    ax = canvas_axes[2], color = 'green',
    alpha = 0.6 # Transparency makes the grid lines to show through
)


plt.show()




































































































# ===================================== BIMODAL DISTRIBUTION =====================================

np.random.seed(20)

the_students = np.random.normal(loc = 20, scale = 2, size = 1000)

professionals = np.random.normal(loc = 35, scale = 5, size = 1000)

career_age_dataset = pd.DataFrame(
    data = np.trunc(
        np.concatenate([
            the_students,
            professionals
            ])
        ), # here we combine the 'the_students' and 'professionals' array (using np.concatenate()), strip the decimal part (using np.trunc()) and feed it to our pandas DataFrame

    columns = ['age'] # set the column name
)


# ===================================== BANDWIDTH AND SMOOTHING =====================================

figure, axes = plt.subplots(
    nrows = 2, ncols = 2,
    figsize = (17, 7), 
    constrained_layout = True
)

axes = axes.flatten()

# ===================================== LAYER 1: THE RAW DATA =====================================

sns.histplot(
    data = career_age_dataset, x = 'age',
    stat = 'density', bins = 30,
    alpha = 0.3, # this puts the histogram in the background for ground truth
    ax = axes[0],
    color = 'orange', label = "Raw Histogram"
)



# ===================================== HIGH BANDWIDTH (OVERSMOOTHED) =====================================

# kdeplot is used to visualize the distribution of data through Kernel Density Estimation (KDE).
sns.kdeplot(
    data = career_age_dataset, x = 'age',
    bw_adjust = 2, # 2 = very Smooth
    color = 'blue', linestyle = '--',
    linewidth = 2, label = "High Bandwidth (Oversmoothed)",
    ax = axes[1]
)



# ===================================== LOW BANDWIDTH: (UNDERSMOOTHED) =====================================

sns.kdeplot(
    data = career_age_dataset, x = 'age',
    bw_adjust = 0.2, # 0.2 = very Spiky
    color = 'green', linestyle = ':',
    linewidth = 2, ax = axes[2],
    label = "Low Bandwidth (Undersmoothed)"
)



# ===================================== OPTIMAL KDE =====================================


sns.kdeplot(
    data = career_age_dataset, x = 'age',
    bw_adjust = 1, # we set bw_adjust to 1
    color = 'red', ax = axes[3],
    fill = True, # This fills area under curve for visual weight
    alpha = 0.1, label = "Optimal KDE (Bimodal Discovery)"
)

figure.suptitle(
    "KDE Bandwidth Analysis: Detecting Multimodal Distributions",
    fontsize=16
)


for axes_num in range(4):

    axes[axes_num].set_xlabel("User Age")
    
    axes[axes_num].set_ylabel("Probability Density")

    axes[axes_num].legend()

    axes[axes_num].grid(True, alpha = 0.3)

figure.savefig("Bandwidth_Analysis.svg", format = 'svg', bbox_inches = 'tight')

plt.show()


















































































































iris_flower_dataset = sns.load_dataset('iris') # small dataset perfect for rugplots


# ===================================== RUG PLOT (THE TRUTH LAYER) =====================================

figure, axes = plt.subplots(figsize = (11, 7))

sns.kdeplot(
    data = iris_flower_dataset, x = 'sepal_length',
    color = 'green', fill = True,
    alpha = 0.2, ax = axes,
    bw_adjust = 1, label = "Smooth KDE Approximation"
)


# the rugplot draws a tick for every single observation. ticks can take up 10% of the y-axis height

sns.rugplot(
    data = iris_flower_dataset, x = 'sepal_length', ax = axes,
    height = 0.1, # Controls length of ticks
    color = 'black', # for contrast
    alpha = 0.5 # transparency helps visualize stacking overlap.
)

figure.suptitle("Rug Plot: Auditing the KDE for Hidden Gaps", fontsize = 14)

axes.set_xlabel("Sepal Length (cm)")
axes.set_ylabel("Density")


plt.close()

# ===================================== ADVANCED: MARGINAL PLOTS =====================================


# Initialize the JointGrid object with the dataset and specify axes
joint_grid = sns.JointGrid(
    data = iris_flower_dataset, 
    x = 'sepal_length', 
    y = 'sepal_width', 
    height = 7 # Sets the figure size to 7x7 inches
)

# Add a scatterplot to the central joint axis to show individual data points
joint_grid.plot_joint(
    sns.scatterplot, 
    s = 51,          # Set marker size
    alpha = 0.6,     # Set transparency to handle overlapping points
    color = 'gray'   # Use a neutral color for the main distribution
)

# Add rug plots to the marginal axes (top and right) to show data density along edges
joint_grid.plot_marginals(
    sns.rugplot, 
    color = 'black', 
    height = 0.1,    # Set the length of the rug lines
    alpha = 0.2      # Set transparency for the rug lines
)

# Layer Kernel Density Estimate (KDE) plots on the marginal axes for a smooth distribution view
joint_grid.plot_marginals(
    sns.kdeplot, 
    color = 'blue', 
    fill = True,     # Fill the area under the KDE curve
    alpha = 0.1      # Set a light transparency for the fill
)

# Adjust the top margin to prevent the title from overlapping with the marginal plots
plt.subplots_adjust(top = 0.9)

# Set the main title for the entire figure
joint_grid.fig.suptitle("JointGrid with Marginal Rugs: 2D Distribution Audit")


plt.show()




































































































class IngestAndExtract:

    """
    A class for sourcing data, uploading to database and extracting it
    """

    def __init__(self,
        database_engine,
        table_name = str
    ):

        self.engine = database_engine

        self.table = table_name

        self.data_url = "https://raw.githubusercontent.com/mwaskom/seaborn-data/master/diamonds.csv"

    def ingest(self):

        raw_data = pd.read_csv(self.data_url)

        raw_data.to_sql(
            con = self.engine,
            if_exists = 'replace',
            index = False,
            name = self.table
        )

    def extract(self):

        if self.engine:

            dataset = pd.read_sql_query(
                sql = f"SELECT * FROM {self.table} LIMIT 8500",

                con = self.engine
            )

            return dataset
        
        else:
            return None



inst = IngestAndExtract(
    database_engine = create_engine(os.getenv("POSTGRE_CONNECT")),
    table_name = "diamonds_sales"
)



if False:

    inst.ingest()

    print(f"Data successfully ingested into PostgreSQL database as '{inst.table}'")

if True:

    diamonds_dataset = inst.extract()

    print(diamonds_dataset.head().to_markdown())


sns.set_theme(style = "darkgrid", context = 'talk')

figure, axes = plt.subplots(
    ncols = 2, nrows = 1,
    figsize = (12, 7), 
    # constrained_layout = True
)

axes = axes.flatten() # flattening the axes from 2D to 1D


axes[0].set_title("KDE")

sns.kdeplot(
    data = diamonds_dataset, ax = axes[0],
    bw_adjust = 1, x = 'carat',
    fill = True, color = 'orange',
    alpha = 0.3, linewidth = 2
)


sns.rugplot(
    data = diamonds_dataset,
    x = 'carat',
    height = 0.13, # height of the ticks relative to the y-axis
    color = 'gray', ax = axes[1],
    alpha = 0.1 # this helps us effectively identify regions with high density (Clumping)
)

axes[1].set_title("Rug Plot")

figure.suptitle("Distribution of Diamond Carats (KDE + Rug Plot)")

for i in range(2):

    axes[i].set_xlabel("Carat Weight")
    
    axes[i].set_ylabel("Density")

plt.subplots_adjust(top = 0.85)

plt.close(fig = figure)




# ===================================== MARGINAL DISTRIBUTIONS (JOINTGRID) =====================================

joint_axes = sns.JointGrid(
    data = diamonds_dataset,
    x = 'carat',
    y = 'price',
    height = 8
)

joint_axes.plot_joint( # plot a scatterplot at the graph on the axes
    sns.scatterplot,
    s = 10,
    alpha = 0.3, color = 'gray'
)


# plot a scatterplot and rigplot on the mergins of the axes
joint_axes.plot_marginals(
    sns.rugplot,
    height = 0.26,
    color = 'violet',
    alpha = 0.1
)

joint_axes.plot_marginals(
    sns.kdeplot,
    bw_adjust = 1,
    color = 'blue',
    linewidth = 1, fill = True, alpha = 0.1
)

plt.subplots_adjust(top = 0.87)

joint_axes.fig.suptitle(
    "Scatter with Marginal Rugs and KDE Plot (Clumping Detection)",
    fontsize = 15,
    color = 'blue'
)


plt.show()















































































































def extract_and_save():

    dataset = pd.read_sql_query(
        sql = "SELECT * FROM diamonds_sales",

        con = os.environ.get("POSTGRE_CONNECT")
    )

    dataset.to_parquet(path = "Saved_Datasets_and_Models/Datasets/diamonds.parquet", index = False)

    print("Done saving dataset as parquet file in Datasets folder")


if False:
    extract_and_save()


# ===================================== Extracting the Dataset =====================================

diamonds_dataset = pd.read_parquet("Saved_Datasets_and_Models/Datasets/diamonds.parquet")

# print(diamonds_dataset.head().to_markdown(tablefmt = "grid"))

sns.set_theme(
    style = 'whitegrid',
    context = 'notebook'
)


figure, axes = plt.subplots(
    nrows = 2, ncols = 2,
    figsize = (16, 11),
    constrained_layout = True
)


figure.suptitle("Feature Engineering: Transforming Skewed Data", fontsize = 16)

# ===================================== Diagnozing the skew =====================================

"""
.skew() is used to calculate the skewness of a feature

.kurt() is used to calculate the kurtosis of a feature
"""
p_skew = diamonds_dataset["price"].skew()

p_kurtosis = diamonds_dataset['price'].kurt()


# visualizing the 'price' column...
sns.histplot(
    data = diamonds_dataset,
    bins = 'auto',
    x = 'price',
    kde = True,
    color = "#DF4001",
    ax = axes[0, 0]
)

# we insert an annotation box to show the statistics...

text_0_0 = f"""Skew: {p_skew:.2f} (Right)
Kurtosis: {p_kurtosis:.2f} (High)"""





"""
The .text() function adds a text label to a specific location on a plot. Here, we used it to create a formatted annotation box relative to the subplot's dimensions.


1. x & y are the coordinates where the text starts. Because of the transform parameter, these are not data values (like 'price'); instead, they represent percentages of the plot area.


2. s is the string content to display


3. transform tells Matplotlib how to translate the (x,y) numbers into actual pixel positions on the screen or image.

transform = axes.transAxes: This is a critical setting. It tells Matplotlib to use the Axes coordinate system (0 to 1) instead of the data coordinate system.

Benefit: If your data range changes (e.g., from 0–100 to 0–1000), the text will stay in the same visual spot relative to the box rather than moving with the data.


4. bbox = dict(...): This creates a Bounding Box (background box) around the text.

facecolor sets the background color of the box

alpha sets the transparency of the box (0 is invisible, 1 is opaque). 
"""



axes[0, 0].text(
    x = 0.62, y = 0.8,
    s = text_0_0, transform = axes[0, 0].transAxes, # Coordinates relative to the axes (0-1), not data values
    bbox = dict(facecolor = "#B3AFAF", alpha = 0.7)
)

axes[0, 0].set_title("Original Price Distribution (Right Skewed)")


# ===================================== Performing Log Transformation =====================================

# log transformation squishes values, large values more than small ones. It's a good way to overcome right skewness as it draws the long tail in

diamonds_dataset['log_of_price'] = np.log1p(diamonds_dataset['price']) # log1p [log(1 + x)] is better than normal log as it is flexible at log(0), which would return an error (negative infinity) if you use normal log

p_log_skew = diamonds_dataset['log_of_price'].skew()


sns.histplot(
    data = diamonds_dataset,
    bins = 'auto',
    x = 'log_of_price',
    kde = True,
    color = "#9C41A8",
    ax = axes[0, 1]
)

text_0_1 = f"Skew: {p_log_skew:.2f} (Normal-ish)"

axes[0, 1].text(
    x = 0.75, y = 0.9,
    s = text_0_1,
    
    transform = axes[0, 1].transAxes,
    
    bbox = dict(facecolor = "#B3AFAF", alpha = 0.8)
)

axes[0, 1].set_title("Log Transformed price (Closer to Normal)")



# ===================================== Box-Cox Transformation (The power Tool) =====================================

"""
Box-Cox optimizes the power parameter (lambda) to make data as normal as possible

Data must be strictly positive (> 0)

Of course price is always greater than 0!
"""


diamonds_dataset["boxcox_of_price"], calc_lambda = stats.boxcox(diamonds_dataset["price"]) # stats.boxcox returns the transformed data and the lambda used


p_boxcox_skew = diamonds_dataset['boxcox_of_price'].skew()


sns.histplot(
    data = diamonds_dataset,
    bins = 'auto',
    x = 'boxcox_of_price',
    kde = True,
    color = "#F30B45",
    ax = axes[1, 0]
)

text_1_0 = f"Skew: {p_boxcox_skew:.2f}"

axes[1, 0].text(
    x = 0, y = 0.8,
    s = text_1_0,
    transform = axes[1, 0].transAxes,
    bbox = dict(facecolor = '#B3AFAF', alpha = 0.7)
)


axes[1, 0].set_title(f"Box-Cox Transformed (Lambda = {calc_lambda:.2f})")




"""
HOW DO WE TEST FOR NORMALITY?

BY USING THE PROBABILITY PLOT
"""

# ===================================== Probability Plot (QQ Plot) =====================================

# This is the ultimate test for normality.
# If dots fall on the red line, the data is normal

stats.probplot(
    x = diamonds_dataset['log_of_price'],

    dist = 'norm',

    plot = axes[1, 1]
)

axes[1, 1].set_title('QQ Plot (Log Transformed Data)')

plt.show()
























































































try:

    diamonds_data = pd.read_sql(
        sql = "SELECT * FROM diamonds_sales",

        con = create_engine(os.environ.get("POSTGRE_CONNECT"))
    )

except Exception:

    diamonds_data = pd.read_parquet("Saved_Datasets_and_Models/Datasets/diamonds.parquet")



# we create a new column 'is_fraud?', splitting prices into Normal and Suspicious
# if price > 18000 label as Fraud
diamonds_data["is_fraud?"] = np.where(
    diamonds_data['price'] > 18000, "Suspicious", "Normal"
)

sns.set_theme(
    style = 'darkgrid',

    context = 'talk'
)


figure, axes = plt.subplots(ncols = 2, nrows = 1,
    figsize = (17, 7),
    
    # constrained_layout = True
)



# ===================================== VISUALIZING THE IMBALANCE (RARE CLASSES) =====================================

"""
A countplot is a Axes-level function used to visualize the frequency (distribution) of observations in a categorical variable.


While a histogram groups continuous numbers into bins, a countplot automatically counts how many times each unique category (like "Fraud" vs. "Not Fraud" or "Class A" vs. "Class B") appears and represents that count with a bar. 

We use countplots when we want to quickly see which categories are the most or least common in our dataset.
"""


sns.countplot(
    data = diamonds_data,

    x = 'is_fraud?', # This is the categorical column being analyzed.
    # Seaborn will automatically count how many "Yes" and "No" (or 1 and 0) entries are in this column and plot them on the x-axis.
    
    hue = 'is_fraud?', # assigning the x-variable to hue allows you to apply a color palette across the bars without triggering a deprecation warning.

    palette = 'mako', # Applies a sequential color scheme. 
    # This gives each bar a distinct color from the theme

    legend = False, # Disables the color legend.
    # Since the x-axis labels already explain what each bar represents, a separate legend is redundant.

    ax = axes[0]
)

axes[0].set_title("Class Imbalance (The Fraud Trap)")

axes[0].set_ylabel("Count of Transactions")

axes[0].set_xlabel("Diamond Price Classes")


for bar in axes[0].patches:

    bar_height = bar.get_height() # bar.get_height() retrieves the count of the bar

    axes[0].text(
        x = bar.get_x() + bar.get_width()/2, # calculates the horizontal center of the bar.

        y = bar_height + 50, # places the text exactly 50 units above the top of the bar

        s = f"{bar_height}", # converts the numeric height into a string to be displayed.

        ha = 'center' #  ensures the text is centered over the calculated x coordinate.
    )

"""
If you train a model here, it will ignore the 'Suspicious' class entirely.

You MUST use SMOTE or Class Weights to fix this before training.
"""






# ===================================== SORTING AND ORDERING (PARETO PRINCIPLE) =====================================

# Seaborn sorts categories alphabetically by default.
# We prevent this by inputing our own custom order in .countplot(), calculated through using .value_counts() to obtain the sorting of categories by count descending


cut_order = diamonds_data['cut'].value_counts().index

sns.countplot(
    data = diamonds_data,
    x = "cut",
    hue = 'cut',
    legend = False,
    palette = 'Spectral',
    ax = axes[1],
    order = cut_order # this forces the x-axis to follow our custom sorted list.
    # You can immediately see the most common category
    # using alphabetical sorting would bury insights
)

axes[1].set_title("Diamond Cuts (Sorted by Frequency)")

plt.tight_layout()

plt.show()







































































































































figure_title = "Matplotlib/Seaborn Assignment"


# ===================================== TASK 1 =====================================

class ETL:

    engine = create_engine(os.environ.get("POSTGRE_CONNECT"))

    def ingest_data(self, table_name: str):

        df = sns.load_dataset('taxis')

        df.to_sql(
            name = table_name,
            if_exists = 'replace',
            con = ETL.engine,
            index = False
        )

        print(f"Data successfully uploaded to PostgreSQL database as '{table_name}'")

    def extract_data(self, table_name: str) -> pd.DataFrame:

        raw_data = pd.read_sql_query(
            sql = f"SELECT * FROM {table_name}",

            con = ETL.engine
        )

        return raw_data



nyc = ETL()

t_name = 'nyc_taxis'

if False: # we run this only once, then change it from True to False

    nyc.ingest_data(table_name = t_name)


# extracting the dataset...
if True:

    nyc_dataset = nyc.extract_data(table_name = t_name)


# ===================================== TASK 2 =====================================


sns.set_context(context = 'poster')

sns.set_theme(style = 'darkgrid')

# i need to visualize the things I need to see so i'll use my own custom rows and columns
figure, axes = plt.subplots(nrows = 2, ncols = 3, figsize = (15, 8), constrained_layout = True)



# ===================================== TASK 3 =====================================


# Plotting Histograms...

sns.histplot(
    data = nyc_dataset,
    x = 'fare',
    bins = 5, # using 5 bins is bad because it smooths out fluctuations in the data
    color = "#F72C47",
    edgecolor = "#CC0A13",
    ax = axes[0, 0]
)

axes[0, 0].set_title("Histogram with 5 bars")


sns.histplot(
    data = nyc_dataset,
    bins = 45, # using 45 bins is bad because it's too sensitive, and responds to the slightest fluctuation
    x = 'fare',
    color = "#096F97",
    edgecolor = "#1438AD",
    ax = axes[1, 0]
)

sns.rugplot(
    data = nyc_dataset,
    x = 'fare',
    height = 0.08,
    color = "#252525",
    alpha = 0.1,
    ax = axes[1, 0]
)

"""
Analysis showed that people frequently pay between $1 - $20 in fares

Something else seemed surprising: I also noticed that people also are more likely to pay ~$52 in fares, due to the clumping of rugplots there
"""


axes[1, 0].set_title("Histogram with 40 bars\n(with Rugplot for clarity)")







# ===================================== TASK 4 =====================================


distance_skew = nyc_dataset['distance'].skew()

distance_kurtosis = nyc_dataset['distance'].kurt()


# visualizing right skew...

sns.kdeplot(
    data = nyc_dataset,
    bw_adjust = 1,
    x = 'distance',
    color = "#EC4C02",
    fill = True,
    ax = axes[0, 1]
)

axes[0, 1].set_title("Distance Column with Right-Skeweness")



# performing log transformation to fix Right-Skeweness...

nyc_dataset['distance_log_transformed'] = np.log1p(nyc_dataset['distance'])

sns.kdeplot(
    data = nyc_dataset,
    bw_adjust = 1,
    x = 'distance_log_transformed',
    color = "#0958CF",
    fill = True,
    ax = axes[1, 1],
)

axes[1, 1].set_xlabel("Log Transformed Distance")

axes[1, 1].set_title("Distance after applying\nLog Transformation")



stats.probplot(
    x = nyc_dataset['distance_log_transformed'],

    dist = 'norm',

    plot = axes[0, 2]
)


# changing the color of the lines...
axes[0, 2].get_lines()[0].set_color("#475A4FB5")

axes[0, 2].get_lines()[1].set_color("#7FFF00")
axes[0, 2].get_lines()[1].set_linewidth(2) # changing linewidth


axes[0, 2].set_title("Verifying if log transformed data follows\nNormnal distribution using probplot")



# ===================================== TASK 5 =====================================

sns.countplot(
    data = nyc_dataset,
    x = 'payment', hue = 'payment',

    order = nyc_dataset['payment'].value_counts().index, # we refuse to let Seaborn order bars alphabetically.
    #  We give Seaborn our own custom order, which was calculated by category count sizes

    legend = False, palette = 'Spectral',
    ax = axes[1, 2]
)

figure.suptitle(figure_title)

figure.savefig(
    "Matplotlib_and_Seaborn/images/figure1.svg",

    format = 'svg',

    bbox_inches = 'tight'
)

plt.close()


# ===================================== TASK 6 =====================================


figure2, axes2 = plt.subplots(
    nrows = 2, ncols = 1, figsize = (15, 9),
    constrained_layout = True
)

# noisy KDE
sns.kdeplot(
    data = nyc_dataset,
    x =  'tip',
    bw_adjust = 0.1,
    color = "#09F198",
    ax = axes2[0],
    fill = True
)

# smooth KDE
sns.kdeplot(
    data = nyc_dataset,
    x =  'tip',
    bw_adjust = 2.0,
    fill = True,
    color = "#060C5C",
    ax = axes2[0]
)

# Optimal KDE
sns.kdeplot(
    data = nyc_dataset,
    x =  'tip',
    fill = True,
    bw_adjust = 1,
    color = "#F12C09",
    ax = axes2[1]
)

figure2.suptitle(figure_title)


# saving figure2...
figure2.savefig(
    "Matplotlib_and_Seaborn/images/figure2.svg",

    format = 'svg',

    bbox_inches = 'tight'
)


plt.show()






























































































































sns.set_theme(style = 'darkgrid')
sns.set_context(context = 'talk')

dataset = pd.DataFrame({

    'Group': ['A', 'B', 'C'],

    'Mean_Score': [85, 92, 78],

    'Std_Dev': [5, 3, 8] # This represents the variability/uncertainty
})


figure, axes = plt.subplots(figsize = (10, 6))


"""

.bar() parameters:

- x: The categories

- height: The bar height (Mean)

- yerr: The error bars (Standard Deviation). This draws the "whiskers".

- capsize: The width of the horizontal line at the top of the whisker.

- color: Custom hex codes for professional look

"""

bar_chart = axes.bar(
    x = dataset['Group'],

    height = dataset['Mean_Score'],

    yerr = dataset['Std_Dev'], # this adds the vertical error-lines

    capsize = 8, # this adds the T-shape top to the error-lines

    color = ["#e01111", "#fc2fda", "#1cd34a"],

    alpha = 0.9,

    edgecolor = "#140C0C",

    linewidth = 1.2,

    # width = 0.4, # 0.8 is the default Value
)

# placing text at the top of each bar...
for bbr in bar_chart:

    b_height = bbr.get_height()

    axes.text(
        x = bbr.get_x() + (bbr.get_width() / 1.534), # Center x

        y = b_height + 1,

        s = f" h: {b_height}", # The text to be placed

        ha = 'center', # ha = Horizontal Align
        
        va = 'bottom', # va = Vertical Align

        fontsize = 12,

        color = "#222021",

        fontweight = 'bold'
    )




# ===================================== styling the Chart =====================================

axes.set_title('Team Performance: Means with Standard Deviation Error Bars')

axes.yaxis.grid(
    visible = True,

    linestyle = '--',

    alpha = 0.7
)

# we set a label on only the y-axis for readability
axes.set_ylabel('Performance Score')

axes.set_axisbelow(b = True) # this puts Gridlines behind the bars


plt.show()










