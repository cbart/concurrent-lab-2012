/**
 * To nativly use a queue in Promela .
 * Written by Bernard van Gastel , < b v g a s t e l @ b i t p o w d e r . com >
 * Usage :
 * - decleration of a queue :
 * queue ([ queuename ] , [ max size ] , [ type of elements ]);
 * e . g . queue ( intqueue , 10 , int );
 * - enqueue
 * enqueue ([ queuename ] , [ item ]);
 * e . g . enqueue ( intqueue , 10);
 * - dequeue
 * dequeue ([ queuename ] , [ variable name ]);
 * e . g . dequeue ( intqueue , x ); ( with the result in x )
 */
#ifndef QUEUE_H
#define QUEUE_H

#define mk_queue(name, size, elements) chan name = [size] of {elements}

#define enqueue(queue, elem) queue!elem

#define dequeue(queue, elem) queue?elem

#endif
