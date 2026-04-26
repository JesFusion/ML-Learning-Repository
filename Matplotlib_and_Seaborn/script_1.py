import os
import logging
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns

# matplotlib.use: Sets the backend used for rendering plots.
#   - backend (positional): The name of the backend ('TkAgg' is an interactive GUI backend).
matplotlib.use('TkAgg')

# os.system: Executes a command in a subshell.
#   - command (positional): The command to run as a string ('cls' for Windows, 'clear' for Unix).
os.system('cls' if os.name == 'nt' else 'clear')

# =====================================
# 1. LOGGER SETUP
# =====================================

# logging.getLogger: Returns a logger instance with the specified name.
#   - name (positional): The name of the logger ("PyTorch Learning").
log = logging.getLogger("PyTorch Learning")

# Logger.setLevel: Sets the threshold for this logger to determine which messages to output.
#   - level: The logging level threshold (logging.DEBUG captures all messages).
log.setLevel(logging.DEBUG)

# logging.StreamHandler: Returns a new handler that sends logging output to streams like sys.stdout (console).
#   (No parameters passed here; defaults to sys.stderr)
handler = logging.StreamHandler()

# Logger.setLevel (Already explained above)
#   - level: Set to logging.INFO here for the specific handler.
handler.setLevel(logging.INFO)

# logging.Formatter: Defines the text layout/format of the log records.
#   - fmt (positional): The format string ('%(message)s\n' prints the message followed by a newline).
# Handler.setFormatter: Sets the formatter for this specific handler.
#   - fmt (positional): The Formatter object to use.
handler.setFormatter(logging.Formatter('%(message)s\n'))

# Logger.addHandler: Attaches the specified handler to this logger.
#   - hdlr (positional): The handler object to attach.
log.addHandler(handler)

# =====================================
# 2. ENVIRONMENT & SEED SETTINGS
# =====================================

# sns.set_theme: Sets multiple Seaborn theme parameters in one step to style plots.
#   - style: The aesthetic style of the plots ('darkgrid' adds a dark background with gridlines).
#   - context: The scaling of plot elements ('notebook' scales appropriately for standard viewing).
sns.set_theme(style='darkgrid', context='notebook')

# np.random.seed: Seeds the random number generator to ensure reproducible random outputs.
#   - seed (positional): The integer seed value (20).
np.random.seed(20)

# =====================================
# 3. SEGMENT 3.2: LINE PLOTS & DATA GEN
# =====================================

# --- A. Sales Dataset Generation ---

# np.arange: Returns evenly spaced integer values within a given interval.
#   - start (positional): Start of the interval, inclusive (1).
#   - stop (positional): End of the interval, exclusive (53).
# np.tile: Constructs a new array by repeating an input array a specified number of times.
#   - A (positional): The input array to repeat.
#   - reps: The number of repetitions (15).
WEEKS = np.tile(np.arange(1, 53), reps=15)

# np.repeat: Repeats elements of an array individually.
#   - a (positional): The input array of elements to repeat (the region names).
#   - repeats: The number of repetitions for each element (52 * 5).
REGIONS = np.repeat(['North', 'South', 'West'], repeats=52 * 5)

def generate_regional_sales(start, stop, noise_scale):
    """Helper function to generate sales data with a trend and normal noise."""
    # np.linspace: Returns evenly spaced numbers over a specified continuous interval.
    #   - start (positional): The starting value of the sequence.
    #   - stop (positional): The end value of the sequence.
    #   - num: The number of samples to generate (52).
    # np.tile (Already explained)
    base_trend = np.tile(np.linspace(start, stop, num=52), reps=5)
    
    # np.random.normal: Draws random samples from a normal (Gaussian) distribution.
    #   - loc: The mean ("centre") of the distribution (0).
    #   - scale: The standard deviation or spread of the distribution (noise_scale).
    #   - size: Output shape / number of samples to draw (52 * 5).
    noise = np.random.normal(loc=0, scale=noise_scale, size=52 * 5)
    return base_trend + noise

sales_north = generate_regional_sales(200, 320, 20)
sales_south = generate_regional_sales(150, 280, 25)
sales_west = generate_regional_sales(180, 350, 30)

# np.concatenate: Joins a sequence of arrays along an existing axis.
#   - arrays (positional): A list or sequence of arrays to be joined.
SALES = np.concatenate([sales_north, sales_south, sales_west])

# pd.DataFrame: Creates a two-dimensional, size-mutable, tabular data structure.
#   - data (positional): A dictionary containing the column names as keys and arrays as values.
sales_table = pd.DataFrame({
    'week': WEEKS,
    'region': REGIONS,
    'sales': SALES
})

# Logger.debug: Logs a message with level DEBUG on this logger.
#   - msg (positional): The f-string message to log.
# DataFrame.sample: Returns a random sample of items from an axis of the DataFrame.
#   - n (positional): Number of random rows to return (11).
# DataFrame.to_markdown: Converts the DataFrame to a Markdown-formatted text table.
log.debug(f"Sales Dataset (Shape: {sales_table.shape}):\n{sales_table.sample(11).to_markdown()}\n")

# DataFrame.groupby: Groups DataFrame using a mapper or by a Series of columns.
#   - by (positional): The column names to group by (['week', 'region']).
# GroupBy.size: Computes the number of rows in each group.
# Series.unique: Returns unique values of the resulting Series object.
log.debug(f"Rows per week per region:\n{sales_table.groupby(['week', 'region']).size().unique()} stores\n")

# --- B. Profit Dataset Generation & Gap Logic ---

# pd.date_range: Generates a fixed frequency DatetimeIndex.
#   - start: Left bound for generating dates ('2024-01-09').
#   - end: Right bound for generating dates ('2024-06-05').
#   - freq: Frequency string indicating the step ('D' for daily).
full_dates = pd.date_range(start='2024-01-09', end='2024-06-05', freq='D')

# len: Built-in function that returns the number of items in an object.
#   - obj (positional): The object whose length is calculated (full_dates).
# np.cumsum: Returns the cumulative sum of the elements along a given axis.
#   - a (positional): Input array containing the randomly generated normal noise.
# np.random.normal (Already explained)
profit = 500 + np.cumsum(np.random.normal(loc=2, scale=15, size=len(full_dates)))

# pd.DataFrame (Already explained)
profit_table = pd.DataFrame({
    'date': full_dates,
    'revenue': profit
})

data_gap = ~((profit_table['date'] >= '2024-02-03') & (profit_table['date'] <= '2024-02-25'))

# DataFrame.loc: Accesses a group of rows and columns by label(s) or a boolean array.
#   - (indexer): Boolean array defining which rows to keep (data_gap).
# DataFrame.copy: Creates a deep copy of the object's indices and data.
gapped_profit_table = profit_table.loc[data_gap].copy()

# DataFrame.set_index: Sets the DataFrame index using one or more existing columns.
#   - keys (positional): The column name to use as the new index ('date').
# DataFrame.reindex: Conforms the DataFrame to a new index, introducing NaN for missing values.
#   - labels (positional): The new array-like index to conform to (full_dates).
# DataFrame.reset_index: Resets the index, moving the current index back into a standard column.
fixed_profit_table = (
    gapped_profit_table.set_index('date')
    .reindex(full_dates)
    .rename_axis('date')
    .reset_index()
)

log.debug(f"Gapped dataset rows: {len(gapped_profit_table)} (missing {len(full_dates) - len(gapped_profit_table)} days)")
log.debug(f"Fixed dataset rows: {len(fixed_profit_table)} (NaN fills the gap honestly)\n")

# =====================================
# 4. PLOTTING DASHBOARD
# =====================================

# plt.subplots: Creates a figure and a set of subplots (a grid of Axes).
#   - nrows: Number of rows in the subplot grid (3).
#   - ncols: Number of columns in the subplot grid (1).
#   - figsize: Tuple representing the width and height of the entire figure in inches (15, 18).
fig, (ax1, ax2, ax3) = plt.subplots(nrows=3, ncols=1, figsize=(15, 18))

# Figure.suptitle: Adds a centered overarching title to the entire figure.
#   - t (positional): The title text string.
#   - fontsize: Font size of the title text (16).
#   - fontweight: The weight/thickness of the font ('bold').
#   - y: The y-coordinate location of the text in figure coordinates (0.98, near the top).
fig.suptitle('Segment 3.2: Line Plots - Time Series & Trends', fontsize=16, fontweight='bold', y=0.98)

# -- Subplot 1: Auto-Aggregation + CI Band --

# sns.lineplot: Draws a line plot, optionally aggregating data and showing error bands.
#   - data: The input DataFrame containing the dataset (sales_table).
#   - x: The column name to use for the x-axis ('week').
#   - y: The column name to use for the y-axis ('sales').
#   - hue: The column name to group by, creating differently colored lines for each group ('region').
#   - estimator: Statistical function used to aggregate multiple observations at the same x (np.mean).
#   - errorbar: Statistical method to compute the error bands ('ci' calculates the confidence interval).
#   - ax: The specific matplotlib Axes object to draw the plot onto (ax1).
sns.lineplot(
    data=sales_table, x='week', y='sales', hue='region',
    estimator=np.mean, errorbar='ci', ax=ax1
)

# Axes.set_title: Sets a title for the specific subplot.
#   - label (positional): The title text string.
#   - fontsize: The font size of the title.
ax1.set_title('Auto-Aggregation + 95% CI Band (5 stores per region)', fontsize=12)

# Axes.set_xlabel: Sets the label text for the x-axis.
#   - xlabel (positional): The text label for the axis.
#   - fontsize: The font size of the label text.
ax1.set_xlabel('Week of Year', fontsize=10)

# Axes.set_ylabel: Sets the label text for the y-axis.
#   - ylabel (positional): The text label for the axis.
#   - fontsize: The font size of the label text.
ax1.set_ylabel('Sales ($)', fontsize=10)

# -- Subplot 2: Auto-Aggregation + SD Band --

# sns.lineplot (Already explained)
#   - errorbar ('sd'): New parameter value used here. Computes the standard deviation for the error band instead of the default confidence interval.
sns.lineplot(
    data=sales_table, x='week', y='sales', hue='region',
    estimator=np.mean, errorbar='sd', ax=ax2
)

# Axes.set_title, Axes.set_xlabel, Axes.set_ylabel (Already explained)
ax2.set_title('Same Data: errorbar = "sd" (Standard Deviation — wider bands)', fontsize=12)
ax2.set_xlabel('Week of Year', fontsize=10)
ax2.set_ylabel('Sales ($)', fontsize=10)

# -- Subplot 3: Gap Fix Demonstration --

# Axes.plot: Plots y versus x as lines and/or markers on the axes.
#   - x (positional): The x-coordinates (gapped_profit_table['date']).
#   - y (positional): The y-coordinates (gapped_profit_table['revenue']).
#   - color: The color of the line ('green').
#   - linestyle: The style of the line ('--' for dashed).
#   - linewidth: The width of the line in points (2).
#   - alpha: The transparency level, from 0.0 transparent to 1.0 opaque (0.8).
#   - label: The label used for the legend.
ax3.plot(
    gapped_profit_table['date'], gapped_profit_table['revenue'],
    color='green', linestyle='--', linewidth=2, alpha=0.8,
    label='Gapped (Fake Bridge - Wrong)'
)

# Axes.plot (Already explained)
ax3.plot(
    fixed_profit_table['date'], fixed_profit_table['revenue'],
    color='steelblue', linewidth=2, alpha=0.9,
    label='Reindexed (Honest Gap - Correct)'
)

# pd.Timestamp: Converts a string or datetime-like object into a pandas Timestamp object.
#   - ts_input (positional): The string value to convert ('2024-02-03').
# Axes.axvspan: Adds a vertical span (rectangle) across the Axes, often used to highlight regions.
#   - xmin: The lower x-coordinate of the span.
#   - xmax: The upper x-coordinate of the span.
#   - color: The fill color of the span.
#   - alpha: The transparency level.
#   - label: The label used for the legend.
ax3.axvspan(
    xmin=pd.Timestamp('2024-02-03'), xmax=pd.Timestamp('2024-02-25'),
    color='red', alpha=0.15, label='Missing Data Window'
)

# Axes.set_title, Axes.set_xlabel, Axes.set_ylabel (Already explained)
ax3.set_title('Time Series Gap: Fake Bridge vs. Honest Break (Reindex to full date range = honest NaN)', fontsize=12)
ax3.set_xlabel('Date', fontsize=10)
ax3.set_ylabel('Daily Revenue ($)', fontsize=10)

# Axes.legend: Places a legend on the Axes using the labels defined in previous plot calls.
#   - fontsize: The size of the text in the legend.
ax3.legend(fontsize=10)

# Axes.tick_params: Changes the appearance of ticks, tick labels, and gridlines.
#   - axis: Specifies which axis to apply the parameters to ('x').
#   - rotation: Rotates the tick labels by the specified degrees (15).
ax3.tick_params(axis='x', rotation=15)

# plt.tight_layout: Automatically adjusts subplot parameters to give specified padding and prevent overlap.
#   - pad: Padding between the figure edge and the edges of subplots, as a fraction of the font size (3.0).
plt.tight_layout(pad=3.0)

# plt.show: Displays all open matplotlib figures and blocks execution until the windows are closed.
#   (No parameters passed)
plt.show()