# plot_of_insight9.gp
set terminal pngcairo size 800,600 enhanced font 'Verdana,10'
set output 'insight9_heatmap.png'

set title "Email Activity Heatmap (Hour vs Day)"
set xlabel "Hour of Day"
set ylabel "Day of Week"
set zlabel "Email Count"
set view map
set pm3d at b
set palette defined (0 "white", 1 "yellow", 2 "orange", 3 "red")
unset key

# This part preprocesses data: sorts by day/hour and adds blank lines for pm3d
input_file = 'plot_output_of_insight9.tsv'
processed_file = 'plot_output_of_insight9_formatted.tsv'
system sprintf("sort -k2,2n -k1,1n %s | awk 'NR==1 {prev=$2} $2!=prev {print \"\"; prev=$2} {print}' > %s", input_file, processed_file)

# Plot the processed file
splot processed_file using 1:2:3 with pm3d

