/* 
 * File:   main.cpp
 * Author: ags056
 *
Copyright (c) <2014> <Paul Kendrick>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */
//http://www.thegeekstuff.com/2013/01/c-argc-argv/

//#include <cstdlib>
#include "processInWindows.hpp"
#include <string>
#include <iostream>
#include <filesystem>
#include <vector>
#include <mpi.h> // Boost to use mpi
//#include <stdio.h>
extern "C" {
#include <unistd.h>
#include <stdio.h>
#include <mpi.h> // Boost to use mpi
}
using namespace std;
// using std::string;
// using std::cout;
void replaceExt(string& s, const string& newExt) {
   string::size_type i = s.rfind('.', s.length());
   if (i != string::npos) {
      s.replace(i+1, newExt.length(), newExt);
   }
}


//void loadWav();

/*
 * 
 */
int main(int argc, char* argv[]) {
  int testForIO = 0;
  int opt = 0;
  int status;
    // directory of files
    std::string p = "/cygdrive/d/!_TEMP_AUDIO_SAMPLES/ARU_RecordingSample_P7-04/20210825_NapkenLk_duskdawn6462";
    std::string outdir = "/cygdrive/d/!_TEMP_AUDIO_SAMPLES/outputs/take3562/"; // output directory
    // std::string ext_wav ('wav');
    std::string outext = ".txt";
    std::string outjson = ".json";
    
       while ((opt = getopt(argc, argv, "i:o:h:")) != -1) {
        switch (opt) {
                        case 'h':{
                printf("\n mpirun windDet.exe -i wav_directory -o output_directory");
                printf("\n-i and -o are required parameters, they provide the input directory holding .wav files and the output directory respectively. ");
                break;}
            case 'i':{
                p = optarg;
                //printf("\nInput file =%s", in_fname);
                break;}
            case 'o':{
                outdir = optarg;
                //printf("\nOutput file=%s", out_fname);
//                std::string Str = std::string(optarg);
//                replaceExt(Str, "json");
//                json_fname= Str.c_str();
//                printf("\nOutput file=%s", json_fname);

                break;}
            
        }
        testForIO = 1;
    } 
    // cout << outdir.c_str() << endl;
      if (testForIO == 0 || !std::filesystem::is_directory(outdir)) {
        printf("\nIncorrect or missing input parameters");
        printf("\nwindDet.exe -i wav_directory -o output_directory");
        printf("\n-i and -o are required parameters, they provide the input .wav dirctory and the output directory respectively.\n");
        status=0;
    } else{status=1;}



    if (status==0)    {
        printf("\nError!");
        exit (EXIT_FAILURE);
        
        }
//        //printf("\nError!");
    // std::string p(argc <= 1 ? "." : argv[1]);
    // char *in_fname = (char *)"iphone1.wav";
    // char *out_fname = (char *)"iphone1.txt";
    // const char *json_fname = (char *)"iphone1.json";
    char *trees =(char *)"dectrees_10_5000";
    char *tr_char = (char *)"trees";
    int rank, numprocs;
    
    
  int i = 1;

  // Iterate through directory and create vector of file names, and output file names

  if (status == 1 )
  {
      std::vector<std::string> paths;
      std::vector<std::string> out_fnames;
      std::vector<std::string> json_fnames;
    for (std::filesystem::recursive_directory_iterator itr(p); itr!=std::filesystem::recursive_directory_iterator(); ++itr)
    {
    //   cout << itr->path().filename() << ' ' ; // display filename only
    if(std::filesystem::is_directory(itr -> path())){
      continue;
    }
      std::string extension_tmp = itr->path().extension() ;
    //   if (std::filesystem::is_regular_file(itr->status())) cout << " [" << file_size(itr->path()) << ']';
      if( extension_tmp.compare(1,3, "wav") == 0 ) {
                std::string fullname = itr->path().filename();
                
                std::string rawname = fullname.substr(0, fullname.find_last_of("."));
                // const char *out_fname =  (rawname + outext).c_str();
                std::string out_fname =  outdir + (rawname + outext);
                // const char *json_fname =  (rawname + outjson).c_str();
                std::string json_fname =  outdir + (rawname + outjson);
                paths.emplace_back(itr->path().string());
                out_fnames.emplace_back(out_fname);
                json_fnames.emplace_back(json_fname);
                // printf("in name: %s\n outname: %s\n json: %s\n", itr->path().string().c_str(), out_fname.c_str(), json_fname.c_str());
                // loadWav(itr->path().string().c_str(), out_fname.c_str(),json_fname.c_str(), trees, 
                //    1, 43,25,1,"trees");
                i++;
      }
     
    

    }

    MPI_Init(&argc, &argv);
	  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);

    if(rank == 0)
        {
          printf("starting model %s out: %s\n",p.c_str(),outdir.c_str());
          printf("Running program with %d  processors\n", numprocs);
        }
    


     int k = paths.size();
     int j = 0 + rank;
      while (j < k){
        printf("Process %d running: %d of %d\n",rank, j, k);
              loadWav(paths[j].c_str(), out_fnames[j].c_str(),json_fnames[j].c_str(), trees, 
                   1, 43,25,0,tr_char);
              j+=numprocs;
      }
      // for (auto k: paths)
      //         std::cout << k << '\n';
  }
  else cout << (std::filesystem::exists(p) ? "Found: " : "Not found: ") << p << '\n';

  MPI_Finalize();

  return 0;
//     int size;
//     int rank;

//     getopt(argc, argv, "d")
//     MPI_Init(&argc, &argv);

//     MPI_Comm_size(MPI_COMM_WORLD, &size); // think size = 4 for this example
//     MPI_Comm_rank(MPI_COMM_WORLD, &rank);


//     {    
//         //
//        status= loadWav(in_fname, out_fname,json_fname, treeDir, gain, frameAve,thresh,verbose,treeFileLoc);
//     }
//    if (status==1)
//            exit (EXIT_FAILURE);
//        //printf("\nError!");
//      if (status==0)
//          exit(status);
//       //printf("\nSuccess!");

//     return status;
}

