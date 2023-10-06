// iterator.kk

type step<a>
  Ans(ans: a)
  Skip
  Done

struct iterator<e, a> 
  iter : () -> e step<a>

fun empty(): iterator<e, a>
  val iter1 = fn()
    Done
  Iterator(iter = iter1)

fun repeat(n : int, a : a) : alloc<h> iterator<<read<h>, write<h>|e>, a>
  val ix = ref(n)
  val iter1 = fn()
    val i = !ix
    if i < 1
      then Done
      else 
        ix := i - 1
        Ans(a)
  Iterator(iter = iter1)

fun toList<e, a>(iter1: iterator<<div|e>, a>) : <div|e> list<a>
  val iterF = iter1.iter
  fun loop(k) 
    match iterF()
      Ans(a) -> loop(fn(ks){k(Cons(a, ks))})
      Skip   -> loop(k)
      Done   -> k(Nil)
  loop(fn(x){x})

fun iterForEach(iter1 : iterator<<div|e>, a>, f : a -> <div|e> ()) : <div|e> ()
  val iterF = iter1.iter
  fun loop() 
    match iterF()
      Ans(a) ->
        f(a)
        loop()
      Skip  -> loop()
      Done  -> ()
  loop()

fun run1() 
  val tenIter = repeat(10, 'a')
  val xs = toList(tenIter)
  foreach(xs, println)

fun run2() 
  val tenIter = repeat(5, 'z')
  iterForEach(tenIter, fn(c : char){println(c)})

fun run3() 
  val zeroIter = empty()
  iterForEach(zeroIter, fn(c : char){println(c)})

fun main() : <console, div> ()
  run1()
  run2()
  run3()