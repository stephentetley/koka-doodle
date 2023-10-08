// iterator.kk
// Redoing Flix's Iterator.flix in Koka

type step<a>
  Ans(ans : a)
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

fun iterate(f: () -> e maybe<a>) : iterator<e, a>
  fun f1()
    match f()
      Just(a) -> Ans(a)
      Nothing -> Done
  Iterator(iter = f1)


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


fun drop(n : int, iter1 : iterator<<div, read<h>, write<h>|e>, a>) : alloc<h> iterator<<div, read<h>, write<h>|e>, a>
  val iterF = iter1.iter
  val ix = ref(n)
  fun loop()
    val i = !ix
    ix := i - 1
    match iterF()
      Ans(a)  -> if (i > 0) then loop() else Ans(a)
      Skip    -> loop()
      Done    -> Done
  Iterator(iter = loop)

fun take(n : int, iter1 : iterator<<div, read<h>, write<h>|e>, a>) : alloc<h> iterator<<div, read<h>, write<h>|e>, a>
  val iterF = iter1.iter
  val ix = ref(n)
  fun loop()
      val i = !ix;
      if i < 1
        then Done
        else
          match iterF()
            Ans(a) -> {ix := i - 1; Ans(a)}
            Skip   -> Skip
            Done   -> Done
  Iterator(iter = loop)
    
fun dropWhile(f : a -> <div|e> bool, iter1 : iterator<<div|e>, a>) : iterator<<div|e>, a>
  val iterF = iter1.iter
  fun loop()
    match iterF()
      Ans(a) -> if (f(a)) then loop() else Ans(a)
      Skip   -> loop()
      Done   -> Done
  Iterator(iter = loop)

fun takeWhile(f : a -> <div|e> bool, iter1 : iterator<<div|e>, a>) : iterator<<div|e>, a>
  val iterF = iter1.iter
  fun loop()
    match iterF()
      Ans(a) -> if (f(a)) then Ans(a) else Done
      Skip   -> loop()
      Done   -> Done
  Iterator(iter = loop)
        
fun foldLeft(iter1 : iterator<<div|e>, a>, f : (b, a) -> <div|e> b, s: b) : <div|e> b 
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

fun map(iter1 : iterator<<div|e>, a>, f : a -> <div|e> b) : iterator<<div|e>, b>
  val iterF = iter1.iter
  fun loop()
    match iterF()
      Ans(a) -> Ans(f(a))
      Skip   -> Skip
      Done   -> Done
  Iterator(iter = loop)

fun filter(iter1 : iterator<<div|e>, a>, f : a -> <div|e> bool) : iterator<<div|e>, a>
  val iterF = iter1.iter
  fun loop()
    match iterF()
      Ans(a) -> if (f(a)) then Ans(a) else Skip
      Skip   -> Skip
      Done   -> Done
  Iterator(iter = loop)

fun cons(x : a, iter1 : iterator<<write<h>,read<h>|e>, a>) : alloc<h> iterator<<read<h>,write<h>|e>, a>
  val iterF = iter1.iter
  val first = ref(True)
  fun loop()
    val isFirst = !first
    if isFirst then {first := False; Ans(x)} else iterF()
  Iterator(iter = loop)

fun append(iter1 : iterator<<div|e>, a>, iter2 : iterator<<div|e>, a>) : iterator<<div|e>, a>
  val iter1F = iter1.iter
  val iter2F = iter2.iter
  fun loop2()
    match iter2F()
      Ans(a) -> Ans(a)
      Skip   -> loop2()
      Done   -> Done
  fun loop1() 
    match iter1F()
      Ans(a) -> Ans(a)
      Skip   -> loop1()
      Done   -> loop2()
  Iterator(iter = loop1)
    
fun sum(iter : iterator<<div|e>, int>) : <div|e> int
  sumwith(iter, id)

fun sumwith(iter: iterator<<div|e>, a>, f : a -> <div|e> int) : <div|e> int
  foldLeft(iter, fn(acc, x){acc + f(x)}, 0)

fun zip(iter1 : iterator<<div|e>, a>, iter2 : iterator<<div|e>, b>) : iterator<<div|e>, (a,b)>
  zipwith(iter1, iter2, fn(a,b){(a,b)})

fun zipwith(iter1 : iterator<<div|e>, a>, iter2 : iterator<<div|e>, b>, f : (a, b) -> <div|e> c) : iterator<<div|e>, c>
  val iter1F = iter1.iter
  val iter2F = iter2.iter
  fun loop()
    match (iter1F(), iter2F())
      (Ans(a), Ans(b)) -> Ans(f(a, b))
      (Ans(a), Skip)   -> zipWithGoRight(iter2F, fn(b){f(a, b)})
      (Skip, Ans(b))   -> zipWithGoLeft(iter1F, fn(a){f(a, b)})
      (Skip, Skip)     -> Skip
      (_, _)           -> Done
  Iterator(iter = loop)

fun zipWithGoLeft(iterF : () -> e step<a>, f : a -> e c) : e step<c>
  match iterF()
    Ans(a) -> Ans(f(a))
    Skip   -> zipWithGoLeft(iterF, f)
    Done   -> Done

fun zipWithGoRight(iterF : () -> e step<b>, f : b -> e c) : e step<c>
  match iterF()
    Ans(b) -> Ans(f(b))
    Skip   -> zipWithGoRight(iterF, f)
    Done   -> Done

fun filtermap(iter1 : iterator<e, a>, f: a -> e maybe<b>) : iterator<e, b>
  val iterF = iter1.iter
  fun loop()
    match iterF()
      Ans(a) -> 
        match (f(a))
          Just(a1) -> Ans(a1)
          Nothing  -> Skip
            }
      Skip   -> Skip
      Done   -> Done
  Iterator(iter = loop)

fun flatmap(iter1 : iterator<<div,read<h>,write<h>|e>, a>, f : (a) -> <div,read<h>,write<h>|e> iterator<<div,read<h>,write<h>|e>, b>) : alloc<h> iterator<<div,read<h>,write<h>|e>, b>
  val iterF = iter1.iter
  val innerIter = ref(empty())
  val inside = ref(False)
  fun innerloop()
    val inner1 = !innerIter
    val innerF = inner1.iter
    match innerF()
      Ans(b) -> Ans(b)
      Skip   -> innerloop()
      Done   -> Done
  fun outerloop()
    val inside1 = !inside
    if inside1
      then 
        match innerloop()
          Done -> {inside := False; outerloop()}
          ans  -> ans
      else
        match iterF()
          Ans(a) -> {inside := True; innerIter := f(a); outerloop()}
          Skip   -> outerloop()
          Done   -> Done
  Iterator(iter = outerloop)


fun intersperse(iter1 : iterator<<div,read<h>,write<h>,alloc<h>|e1>,a>, sep : a) : <alloc<h>|e> iterator<<div,read<h>,write<h>,alloc<h>|e1>, a>
  val iterF = iter1.iter
  val start = ref(True)
  fun step(x)
    if !start 
      then 
        start := False 
        singleton(x)
      else 
        cons(sep, singleton(x))
  flatmap(iter1, step)

fun flatten(iter1 : iterator<<div,read<h>,write<h>|e>, iterator<<div,read<h>,write<h>|e>, a>>) : alloc<h> iterator<<div,read<h>,write<h>|e>, a>
  flatmap(iter1, id)

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

fun run5()   
  val iter1 = range(1, 15)
  val iter2 = takeWhile(fn(x){x < 10}, iter1)
  println("run5 takeWhile...")
  forEach(iter2, println)


fun run6()
  val iter1 = range(1, 15)
  val iter2 = dropWhile(fn(x){x < 10}, iter1)
  println("run6 dropWhile...")
  forEach(iter2, println)

fun main() : <console, div> ()
  run1()
  run2()
  run3()
  run4()
  run5()
  run6()
