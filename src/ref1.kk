// ref1.kk

fun incr(cell: ref<h, int>): <read<h>, write<h>> () 
  val i = !cell
  cell := i + 1

fun main() : console ()
  println("Whatever")  
  val cell1 = ref(0)
  incr(cell1)
  incr(cell1)
  incr(cell1)
  val ans = !cell1
  println(ans)

