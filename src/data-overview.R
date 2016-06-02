commandArgs(trailingOnly=T) -> args
read.table(args[1]) -> x
save(x, file=args[2])
str(x)
