promela:
	spin -a readersWritersProm.pml && gcc -o pan_promela -O3 -DSAFETY -DREACH pan.c
dijkstra:
	spin -DDIJKSTRA -a readersWriters.pml && gcc -o pan_dijkstra -O3 -DSAFETY -DREACH pan.c
strong:
	spin -DSTRONG -a readersWriters.pml && gcc -o pan_strong -O3 -DSAFETY -DREACH pan.c
fair:
	spin -DFAIR -a readersWriters.pml && gcc -o pan_fair -O3 -DSAFETY -DREACH pan.c

dijkstra_reader_reads:
	spin -DDIJKSTRA -DREADER_WILL_READ -a readersWriters.pml && gcc -o pan_dijkstra_reader_reads -O3 -DREACH pan.c
strong_reader_reads:
	spin -DSTRONG -DREADER_WILL_READ -a readersWriters.pml && gcc -o pan_strong_reader_reads -O3 -DREACH pan.c
fair_reader_reads:
	spin -DFAIR -DREADER_WILL_READ -a readersWriters.pml && gcc -o pan_fair_reader_reads -O3 -DREACH pan.c

dijkstra_writer_writes:
	spin -DDIJKSTRA -DWRITER_WILL_WRITE -a readersWriters.pml && gcc -o pan_dijkstra_writer_writes -O3 -DREACH pan.c
strong_writer_writes:
	spin -DSTRONG -DWRITER_WILL_WRITE -a readersWriters.pml && gcc -o pan_strong_writer_writes -O3 -DREACH pan.c
fair_writer_writes:
	spin -DFAIR -DWRITER_WILL_WRITE -a readersWriters.pml && gcc -o pan_fair_writer_writes -O3 -DREACH pan.c
