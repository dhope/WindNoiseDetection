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
//#include <stdio.h>
extern "C" {
#include <unistd.h>
#include <stdio.h>
// #include <mpi.h> // Boost to use mpi
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
    // std::string ext_wav ('wav');
    std::string outext = ".txt";
    std::string outjson = ".json";
    std::string p(argc <= 1 ? "." : argv[1]);
    // char *in_fname = (char *)"iphone1.wav";
    // char *out_fname = (char *)"iphone1.txt";
    // const char *json_fname = (char *)"iphone1.json";
    char *trees =(char *)"dectrees_10_5000";

  if (std::filesystem::is_directory(p))
  {
    for (std::filesystem::directory_iterator itr(p); itr!=std::filesystem::directory_iterator(); ++itr)
    {
    //   cout << itr->path().filename() << ' ' ; // display filename only
      std::string extension_tmp = itr->path().extension() ;
    //   if (std::filesystem::is_regular_file(itr->status())) cout << " [" << file_size(itr->path()) << ']';
      if( extension_tmp.compare(1,3, "wav") == 0 ) {
                std::string fullname = itr->path().filename();
                std::string rawname = fullname.substr(0, fullname.find_last_of("."));
                // const char *out_fname =  (rawname + outext).c_str();
                std::string out_fname =  (rawname + outext);
                // const char *json_fname =  (rawname + outjson).c_str();
                std::string json_fname =  (rawname + outjson);
                // printf("in name: %s\n outname: %s\n json: %s\n", itr->path().string().c_str(), out_fname.c_str(), json_fname.c_str());
                loadWav(itr->path().string().c_str(), out_fname.c_str(),json_fname.c_str(), trees, 
                   1, 43,25,1,"trees");
      }
        cout << '\n';


    }
  }
  else cout << (std::filesystem::exists(p) ? "Found: " : "Not found: ") << p << '\n';

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

