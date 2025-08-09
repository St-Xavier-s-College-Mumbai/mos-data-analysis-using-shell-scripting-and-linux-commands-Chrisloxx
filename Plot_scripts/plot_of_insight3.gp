# --- Gnuplot script to create a multi-series line chart (self-contained) ---

# 1. Set the output format and file name
set terminal pngcairo enhanced font "sans,10" size 1000,600
set output 'insight3_linechart.png'

# 2. Define the name of the data file to use
datafile = 'plot_output_of_insight3.tsv'

# 3. Automatically determine the number of columns (N)
#    This uses the system() function to run a shell command. It gets the
#    first line of the data file (head -n 1), and awk counts the number
#    of columns (NF). The result is converted to an integer.
N = int(system("head -n 1 ".datafile." | awk -F'\t' '{print NF}'"))

# 4. Set chart styles and labels
set title "Monthly Email Volume by Category"
set ylabel "Email Count"
set key top left # Position the legend

# 5. Configure the x-axis to handle time data
set xdata time
set timefmt "%Y-%m" # Tell gnuplot how to read the date format
set format x "%b %Y" # Tell gnuplot how to display the date on the axis
set xtics rotate by -45

# 6. Plot the data
#    The loop now uses the N variable we defined within the script.
plot for [i=2:N] datafile using 1:i with linespoints title columnhead
