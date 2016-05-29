commandArgs(trailingOnly=T) -> args
read.table(args[1]) -> data
svg(filename=args[2])
plot(data)
dev.off()
