// twoeffects.kk


// Note - the effect types are "different" at the call site in `printTwice`
// but the first call appears to be promoted to a common effect type with 
// the second type.
// Here we just state that we take two functions of a general (polymorphic)
// effect type.
fun twoeffects(f: a -> e (), g: a -> e (), a: a) : e () 
  f(a)
  g(a)

fun printPosInt(a: int) : <exn, console|e> () 
  if (a >= 0) then println(a) else throw("negative")
  

fun printTwice(a: int) : <exn, console|e> ()
  twoeffects(println, printPosInt, a)

fun main() : <console, exn> ()
  with finally 
    println("done")
  printTwice(10)

