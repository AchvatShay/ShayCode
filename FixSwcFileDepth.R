library(nat)

tracesFilePath = "//jackie-analysis/F/Layer II-III/Imaging/Bas-M2-Sa1/08.18.22-reconstructure/08.18.22-reconstructure2.traces"
depthFilePath = "//jackie-analysis/F/Layer II-III/Imaging/Bas-M2-Sa1/08.18.22-reconstructure/depth.txt"
outputPath = "//jackie-analysis/F/Layer II-III/Imaging/Bas-M2-Sa1/08.18.22-reconstructure/"

x =  read.neuron.fiji(tracesFilePath, simplify = FALSE)
d = as.vector(read.table(depthFilePath, header=FALSE)[,1])
nameNeuronFile = "M2-Sa1"

#for (i in 1:length(x)) {
  i = 2
  x[[i]]$d$Z = d[x[[i]]$d$Z+1]
  x[[i]]$d$Y = x[[i]]$d$Y*0.8484
  x[[i]]$d$X = x[[i]]$d$X*0.8484
  x[[i]]$d$W = 1
  
  
  
  # smooth out little jumps and steps (in z-axis mostly)
  x = as.neuronlist(lapply( x, smooth_neuron, sigma=20))
  plot3d(x[[i]])
  write.neuron(x[[i]],file = sprintf("%s_N%d",nameNeuronFile, i),dir = outputPath, format = 'swc',ext = NULL,Force = TRUE,MakeDir = TRUE)
#}