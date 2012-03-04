all:
	gcc -O0 -pthread -o peterson peterson.c
	gcc -O0 -pthread -o no_peterson no_peterson.c
test:
	for i in `seq 200`; do taskset -c 0,1,2,3 ./peterson; done | sort | uniq -c
clean:
	rm peterson no_peterson
