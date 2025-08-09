set terminal pngcairo enhanced font "sans,10" size 900,450
set output 'insight10_Barchart.png'

set title "Sentiment Analysis of Email Subjects"
set xlabel "Number of Emails"
set ylabel ""
set key off

set style fill solid 1.0 border -1
set boxwidth 0.6
set grid x
set xtics rotate by -45

# Let gnuplot assign default colors automatically
plot 'plot_output_of_insight10.tsv' using 2:xtic(1) with boxes notitle

