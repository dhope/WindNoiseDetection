CXX      = mpic++
CXXFLAGS = -Wall  -O3#-g -ansi or -std=c++11
CC       = mpicc
CCFLAGS  = -O3 #-g
OBJS     = src/main_multi.o src/processInWindows.o src/DecisionTreeClass.o src/aweighting.o src/featureExtraction.o src/kiss_fft130/kiss_fft.o
OBJS2     = src/main_readfile.o src/processInWindows.o src/DecisionTreeClass.o src/aweighting.o src/featureExtraction.o src/kiss_fft130/kiss_fft.o

windDet : $(OBJS)
	$(CXX) -o  $@ $(OBJS)
	
windDetFile : $(OBJS2)
	$(CXX) -o  $@ $(OBJS2)

OBJ/%.o : %.cpp
	$(CXX) -c  $(CXXFLAGS) $<

OBJ/%.o : %.c
	$(CC) -c  $(CCFLAGS) $<


clean:
	rm $(OBJS2)
