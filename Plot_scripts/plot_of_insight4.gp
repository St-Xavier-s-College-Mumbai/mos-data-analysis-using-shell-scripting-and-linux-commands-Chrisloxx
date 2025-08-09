# --- Gnuplot script to create a colored bar chart with data labels ---

# 1. Set the output format and file name
set terminal pngcairo enhanced font "sans,10" size 800,600
set output 'insight4_barchart.png'

# 2. Set chart styles and labels
set title "Total Number of Emails per Category"
set ylabel "Email Count"
set style data histograms
set style histogram clustered gap 1
set style fill solid 0.8
set boxwidth 0.8
set key off # Turn off the legend/key

# Add some padding to the top of the chart so labels don't get cut off
set offset 0,0,graph 0.1,0 

# Rotate x-axis labels for readability
set xtics rotate by -45

# 3. Plot the data
#    The plot command now has two parts, separated by a comma:
#    - The first part draws the colored bars.
#    - The second part reads the file again to draw the text labels.
plot 'output_of_insight4.tsv' using 2:xtic(1) with boxes linecolor rgb "#4e79a7" notitle, \
     '' using 0:($2):2 with labels font ",9" textcolor rgb "#333333" offset 0,0.5 notitle
