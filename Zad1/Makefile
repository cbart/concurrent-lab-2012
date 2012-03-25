dijkstra:
	spin -DDIJKSTRA -a readersWriters.pml && gcc -o pan -O3 -DSAFETY -DREACH pan.c
strong:
	spin -DSTRONG -a readersWriters.pml && gcc -o pan -O3 -DSAFETY -DREACH pan.c
fair:
	spin -DFAIR -a readersWriters.pml && gcc -o pan -O3 -DSAFETY -DREACH pan.c
promela:
	spin -a readersWritersProm.pml && gcc -o pan -O3 -DSAFETY -DREACH pan.c
