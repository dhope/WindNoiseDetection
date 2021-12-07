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
#include <fstream>
#include <iterator>
#include <algorithm>
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
  int verbose=0;
    // directory of files
    std::string p = "/cygdrive/d/!_TEMP_AUDIO_SAMPLES/ARU_RecordingSample_P7-04/20210825_NapkenLk_duskdawn6462";
    std::string outdir = "/cygdrive/d/!_TEMP_AUDIO_SAMPLES/outputs/take3562/"; // output directory
    // std::string ext_wav ('wav');
    std::string outext = ".txt";
    std::string outjson = ".json";
    std::string wavext = ".wav";

    
    while ((opt = getopt(argc, argv, "i:o:v:h:")) != -1) {
        switch (opt) {
                        case 'h':{
                printf("\n mpirun windDet.exe -i wav_directory -o output_directory");
                printf("\n-i and -o are required parameters, they provide the input directory holding .wav files and the output directory respectively. ");
                break;}
            case 'i':{
                p = optarg;
                //printf("\nInput file =%s", in_fname);
                break;}
                case 'v':{
                verbose = atof(optarg);
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
    std::string pathlistname = p + "pathlist.txt";
    std::string filelistname = p + "filelist.txt";
    std::string sitelistname = p + "sitelist.txt";
    char *trees =(char *)"dectrees_10_5000";
    char *tr_char = (char *)"trees";
    int rank, numprocs;
    

  // Iterate through directory and create vector of file names, and output file names

  if (status == 1 )
  {   
      std::vector<std::string> paths;
      std::vector<std::string> filenames;
      std::vector<std::string> sites; 
      std::ifstream pathlist(pathlistname);// "pathlist.txt");
      std::ifstream filenameslist(filelistname);
      std::ifstream sitelist(sitelistname);

    if(!pathlist || !filenameslist || !sitelist) //Always test the file open.
    {
        std::cout<<"Error opening output file"<< std::endl;
        
        return -1;
    }
    
    // Read in paths, filenames and sites from files.
      std::copy(std::istream_iterator<string>(pathlist),
         std::istream_iterator<string>(),
         std::back_inserter(paths));
      std::copy(std::istream_iterator<string>(filenameslist),
         std::istream_iterator<string>(),
         std::back_inserter(filenames));
         std::copy(std::istream_iterator<string>(sitelist),
         std::istream_iterator<string>(),
         std::back_inserter(sites));

    int k = paths.size();
    int z = sites.size();
    printf("Files are %d and %d of length\n", k, z);
   
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);

    if(rank == 0)
        {
        //   printf("starting model %s out: %s\n",p.c_str(),outdir.c_str());
          printf("Running program with %d  processors\n", numprocs);
        }
    
     int j = 0 + rank;

      while (j < k){
        std::string in_fname = paths.at(j)+  "/" + filenames.at(j) + wavext;//paths[j] + filenames[j] + wavext;
        std::string out_fname =  outdir +   sites.at(j)  + "__" +  filenames.at(j) + outext;
        std::string json_fnames =  outdir +  sites.at(j) + "__" + filenames.at(j) + outjson;
        // cout<< in_fname << "\t" << out_fname <<"\t" << json_fnames << endl;
        loadWav(in_fname.c_str(), out_fname.c_str(),json_fnames.c_str(), trees, 
                   1, 43,25,verbose,tr_char);
              j+=numprocs;
      }
  }
  else cout << (std::filesystem::exists(p) ? "Found: " : "Not found: ") << p << '\n';

  MPI_Finalize();

  return 0;
  
}
