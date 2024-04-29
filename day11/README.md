
# Reflection 

having now solved problem we have chance to look back at why we struggled the first time
with this problem

possible hexagon math threw me  off

guile/fun.scm has correct solution

chicken/bar.scm has the failed incorrect solution 

so we can look back at our mistakes , can we see where we went wrong ?

## hexagon math

producing a visual hexagonal grid is a bit confusing

hexagon can be thought of a circle , evenly divided into six pieces
six pieces of pie

each slice ( 360 / 6 ) or 60 degrees

computer math - sin cosine use angles are radians
pi 3.1415926535898  is 180 degrees
radians = angle / 180 * pi

more about this later

hexagon grid can be generated from two rows 
ROW 1 
row 2 say , could be north-east of row1 locations
row 3 is south-east of row2 locations ...

