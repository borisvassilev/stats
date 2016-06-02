commandArgs(trailingOnly=T) -> args
load(args[1])
cor.test(x[[1]], x[[2]], method="pearson")
svg(filename=args[2])
plot(x)
dev.off() -> foo
