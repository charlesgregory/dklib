module dklib.kalloc;

import core.stdc.stdio;
import core.stdc.stdlib;
import core.stdc.string;
// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
// #include "kalloc.h"

/* In kalloc, a *core* is a large chunk of contiguous memory. Each core is
 * associated with a master header, which keeps the size of the current core
 * and the pointer to next core. Kalloc allocates small *blocks* of memory from
 * the cores and organizes free memory blocks in a circular single-linked list.
 *
 * In the following diagram, "@" stands for the header of a free block (of type
 * header_t), "#" for the header of an allocated block (of type size_t), "-"
 * for free memory, and "+" for allocated memory.
 *
 * master        This region is core 1.          master           This region is core 2.
 *      |                                             |
 *      *@-------#++++++#++++++++++++@--------        *@----------#++++++++++++#+++++++@------------
 *       |                           |                 |                               |
 *       p=p.ptr.ptr.ptr.ptr     p.ptr            p.ptr.ptr                     p.ptr.ptr.ptr
 */

// enum MIN_CORE_SIZE =0x80000;

// struct header_t {
// 	size_t size;
// 	header_t *ptr;
// }

// struct kmem_t{
// 	header_t base;
// 	header_t *loop_head, core_head; /* base is a zero-sized block always kept in the loop */
// }
// struct km_stat_t{
// 	size_t capacity, available, n_blocks, n_cores, largest;
// }

// void panic(const(char) *s) @nogc
// {
// 	fprintf(stderr, "%s\n", s);
// 	abort();
// }

// void *km_init() @nogc
// {
// 	return calloc(1, kmem_t.sizeof);
// }

// void km_destroy(void *_km) @nogc
// {
// 	kmem_t *km = cast(kmem_t*)_km;
// 	header_t *p, q;
// 	if (km == null) return;
// 	for (p = km.core_head; p != null;) {
// 		q = p.ptr;
// 		free(p);
// 		p = q;
// 	}
// 	free(km);
// }

// header_t *morecore(kmem_t *km, size_t nu) @nogc
// {
// 	header_t *q;
// 	size_t bytes;
// 	size_t *p;
// 	nu = (nu + 1 + (MIN_CORE_SIZE - 1)) / MIN_CORE_SIZE * MIN_CORE_SIZE; /* the first +1 for core header */
// 	bytes = nu * header_t.sizeof;
// 	q = cast(header_t*)malloc(bytes);
// 	if (!q) panic("[morecore] insufficient memory");
// 	q.ptr = km.core_head, q.size = nu, km.core_head = q;
// 	p = cast(size_t*)(q + 1);
// 	*p = nu - 1; /* the size of the free block; -1 because the first unit is used for the core header */
// 	kfree(km, p + 1); /* initialize the new "core"; NB: the core header is not looped. */
// 	return km.loop_head;
// }

// void kfree(void *ap) @nogc
// {
// 	kfree(null, ap);
// }

// void kfree(void *_km, void *ap) @nogc /* kfree() also adds a new core to the circular list */
// {
// 	header_t *p, q;
// 	kmem_t *km = cast(kmem_t*)_km;
	
// 	if (!ap) return;
// 	if (km == null) {
// 		free(ap);
// 		return;
// 	}
// 	p = cast(header_t*)(cast(size_t*)ap - 1);
// 	p.size = *(cast(size_t*)ap - 1);
// 	/* Find the pointer that points to the block to be freed. The following loop can stop on two conditions:
// 	 *
// 	 * a) "p>q && p<q.ptr": @------#++++++++#+++++++@-------    @---------------#+++++++@-------
// 	 *    (can also be in    |      |                |        . |                       |
// 	 *     two cores)        q      p           q.ptr           q                  q.ptr
// 	 *
// 	 *                       @--------    #+++++++++@--------    @--------    @------------------
// 	 *                       |            |         |         . |            |
// 	 *                       q            p    q.ptr            q       q.ptr
// 	 *
// 	 * b) "q>=q.ptr && (p>q || p<q.ptr)":  @-------#+++++   @--------#+++++++     @-------#+++++   @----------------
// 	 *                                       |                |        |         . |                |
// 	 *                                  q.ptr                q        p       q.ptr                q
// 	 *
// 	 *                                       #+++++++@-----   #++++++++@-------     @-------------   #++++++++@-------
// 	 *                                       |       |                 |         . |                         |
// 	 *                                       p  q.ptr                 q       q.ptr                         q
// 	 */
// 	for (q = km.loop_head; !(p > q && p < q.ptr); q = q.ptr)
// 		if (q >= q.ptr && (p > q || p < q.ptr)) break;
// 	if (p + p.size == q.ptr) { /* two adjacent blocks, merge p and q.ptr (the 2nd and 4th cases) */
// 		p.size += q.ptr.size;
// 		p.ptr = q.ptr.ptr;
// 	} else if (p + p.size > q.ptr && q.ptr >= p) {
// 		panic("[kfree] The end of the allocated block enters a free block.");
// 	} else p.ptr = q.ptr; /* backup q.ptr */

// 	if (q + q.size == p) { /* two adjacent blocks, merge q and p (the other two cases) */
// 		q.size += p.size;
// 		q.ptr = p.ptr;
// 		km.loop_head = q;
// 	} else if (q + q.size > p && p >= q) {
// 		panic("[kfree] The end of a free block enters the allocated block.");
// 	} else km.loop_head = p, q.ptr = p; /* in two cores, cannot be merged; create a new block in the list */
// }

// pragma(inline,true)
// void *kmalloc(size_t n_bytes) @nogc
// {
// 	return kmalloc(null, n_bytes);
// }

// void *kmalloc(void *_km, size_t n_bytes) @nogc
// {
// 	kmem_t *km = cast(kmem_t*)_km;
// 	size_t n_units;
// 	header_t *p, q;

// 	if (n_bytes == 0) return null;
// 	if (km == null) return malloc(n_bytes);
// 	n_units = (n_bytes + size_t.sizeof + header_t.sizeof - 1) / header_t.sizeof + 1;
// 	q = km.loop_head;
// 	if (!(q)) /* the first time when kmalloc() is called, intialize it */
// 		q = km.loop_head = km.base.ptr = &km.base;
// 	for (p = q.ptr;; q = p, p = p.ptr) { /* search for a suitable block */
// 		if (p.size >= n_units) { /* p.size if the size of current block. This line means the current block is large enough. */
// 			if (p.size == n_units) q.ptr = p.ptr; /* no need to split the block */
// 			else { /* split the block. NB: memory is allocated at the end of the block! */
// 				p.size -= n_units; /* reduce the size of the free block */
// 				p += p.size; /* p points to the allocated block */
// 				*cast(size_t*)p = n_units; /* set the size */
// 			}
// 			km.loop_head = q; /* set the end of chain */
// 			return cast(size_t*)p + 1;
// 		}
// 		if (p == km.loop_head) { /* then ask for more "cores" */
// 			if ((p = morecore(km, n_units)) == null) return null;
// 		}
// 	}
// }

// pragma(inline,true)
// void *kcalloc(size_t count, size_t size) @nogc
// {
// 	return kcalloc(null,count,size);
// }

// void *kcalloc(void *_km, size_t count, size_t size) @nogc
// {
// 	kmem_t *km = cast(kmem_t*)_km;
// 	void *p;
// 	if (size == 0 || count == 0) return null;
// 	if (km == null) return calloc(count, size);
// 	p = kmalloc(km, count * size);
// 	memset(p, 0, count * size);
// 	return p;
// }

// pragma(inline,true)
// void *krealloc(void *ap, size_t n_bytes) @nogc
// {
// 	return krealloc(null, ap, n_bytes);
// }

// void *krealloc(void *_km, void *ap, size_t n_bytes) @nogc // TODO: this can be made more efficient in principle
// {
// 	kmem_t *km = cast(kmem_t*)_km;
// 	size_t n_units; 
// 	size_t *p, q;

// 	if (n_bytes == 0) {
// 		kfree(km, ap); return null;
// 	}
// 	if (km == null) return realloc(ap, n_bytes);
// 	if (ap == null) return kmalloc(km, n_bytes);
// 	n_units = (n_bytes + size_t.sizeof + header_t.sizeof - 1) / header_t.sizeof;
// 	p = cast(size_t*)ap - 1;
// 	if (*p >= n_units) return ap; /* TODO: this prevents shrinking */
// 	q = cast(size_t*)kmalloc(km, n_bytes);
// 	memcpy(q, ap, (*p - 1) * header_t.sizeof);
// 	kfree(km, ap);
// 	return q;
// }

// void km_stat(const void *_km, km_stat_t *s) @nogc
// {
// 	kmem_t *km = cast(kmem_t*)_km;
// 	header_t *p;
// 	memset(s, 0, km_stat_t.sizeof);
// 	if (km == null || km.loop_head == null) return;
// 	for (p = km.loop_head;; p = p.ptr) {
// 		s.available += p.size * header_t.sizeof;
// 		if (p.size != 0) ++s.n_blocks; /* &kmem_t::base is always one of the cores. It is zero-sized. */
// 		if (p.ptr > p && p + p.size > p.ptr)
// 			panic("[km_stat] The end of a free block enters another free block.");
// 		if (p.ptr == km.loop_head) break;
// 	}
// 	for (p = km.core_head; p != null; p = p.ptr) {
// 		size_t size = p.size * header_t.sizeof;
// 		++s.n_cores;
// 		s.capacity += size;
// 		s.largest = s.largest > size? s.largest : size;
// 	}
// }