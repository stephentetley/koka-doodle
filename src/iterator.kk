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

fun singleton(a: a): alloc<h> iterator<<read<h>, write<h>|e>, a>
  repeat(1, a)

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

fun range(startr : int, endr : int) : alloc<h> iterator<<read<h>, write<h>|e>, int>
  val ix = ref(startr)
  if (endr <= startr)
    then empty()
    else
      val iter1 = fn()
        val i = !ix
        match i 
          _ | i < endr -> {ix := i + 1; Ans(i)}
          _ -> Done
      Iterator(iter = iter1)

fun next(iter1 : iterator<<div|e>, a>) : <div|e> maybe<a>
  val iterF = iter1.iter
  fun loop() 
    match iterF()
      Ans(a) -> Just(a)
      Skip   -> loop()
      Done   -> Nothing
  loop()


fun foldLeft(f: (b, a) -> <div|e> b, s: b, iter1 : iterator<<div|e>, a>): <div|e> b 
  val iterF = iter1.iter
  fun loop(acc)
    match iterF()
      Skip   -> loop(acc)
      Ans(a) -> loop(f(acc, a))
      Done   -> acc
  loop(s)

fun toList<e, a>(iter1: iterator<<div|e>, a>) : <div|e> list<a>
  val iterF = iter1.iter
  fun loop(k) 
    match iterF()
      Ans(a) -> loop(fn(ks){k(Cons(a, ks))})
      Skip   -> loop(k)
      Done   -> k(Nil)
  loop(fn(x){x})

fun forEach(iter1 : iterator<<div|e>, a>, f : a -> <div|e> ()) : <div|e> ()
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
  forEach(tenIter, fn(c : char){println(c)})

fun run3() 
  val zeroIter = empty()
  forEach(zeroIter, fn(c : char){println(c)})

fun run4() 
  val rngIter = range(3, 7)
  forEach(rngIter, println)


fun main() : <console, div> ()
  run1()
  run2()
  run3()
  run4()
