# hpc-mpip
Docker image based on [`gtomscs/hpc`](https://hub.docker.com/r/gtomscs/hpc/) with `OpenMPI 1.6.5` and added `mpiP 3.4.1` for profiling support. 
Read more about mpiP [here](http://llnl.github.io/mpiP/#Introduction).

### Building and Running Image

To build and tag the image:
```
git clone <this-repo-url>
cd hpc-mpip
docker build -t hpc:mpip .
```

To run locally.

Example of running locally with enabled volume in Windows (assumes C: drive is configured for sharing in docker settings)
```
docker run -it --entrypoint=/bin/bash -v c:/users/parkerm/oms-hpc-labs:/hpc hpc:mpip

root@f6f0fa466bc7:/# cd /hpc
root@f6f0fa466bc7:/hpc# ls -lha
total 14K
drwxrwxrwx 2 root root 4.0K Mar 20 03:18 .
drwxr-xr-x 1 root root 4.0K Mar 23 19:52 ..
-rwxr-xr-x 1 root root 1.3K Mar 11 09:32 Vagrantfile
drwxrwxrwx 2 root root    0 Mar 20 03:18 lab0
drwxrwxrwx 2 root root    0 Mar 20 03:18 lab1
drwxrwxrwx 2 root root    0 Mar 20 03:18 lab2
drwxrwxrwx 2 root root    0 Mar 23 20:19 lab3
root@f6f0fa466bc7:/hpc#
```

### Enable profiling
To enable mpiP profiling on `mpirun` commands, link the following libraries while compiling with `mpicc`.
```
-L/usr/local/tools/mpiP/lib -lmpiP -lm -lbfd -liberty -lunwind
``` 

##### Example run *without* linked mpiP:
```
root@f6f0fa466bc7:/hpc/lab3# make clean && make COLLECTIVE=reduce IMPL=tree driver && mpirun -np 8 ./driver
rm -f *.o driver
mpicc -std=c99 -O2 -g -Wall -DDRIVEREDUCE -o driver driver.c reduce_tree.c reduce_test.c test_utils.c
#P      Bytes   Seconds Trials
8       4       1.36346e-06     196608
8       8       1.34588e-06     196608
8       16      1.22203e-06     196608
8       32      1.15614e-06     196608
...
8       268435456       1.12447 3
root@f6f0fa466bc7:/hpc/lab3#
```

##### Example run *with* linked mpiP
```
root@f6f0fa466bc7:/hpc/lab3# make clean && make COLLECTIVE=reduce IMPL=tree driver && mpirun -np 8 ./driver
rm -f *.o driver
mpicc -std=c99 -O2 -g -Wall -DDRIVEREDUCE -o driver driver.c reduce_tree.c reduce_test.c test_utils.c -L/usr/local/tools/mpiP/lib -lmpiP -lm -lbfd -liberty -lunwind
mpiP:
mpiP: mpiP: mpiP V3.4.1 (Build Mar 22 2019/05:11:21)
mpiP: Direct questions and errors to mpip-help@lists.sourceforge.net
mpiP:
#P      Bytes   Seconds Trials
8       4       1.67817e-05     12288
8       8       1.66444e-05     12288
8       16      1.69306e-05     12288
8       32      1.68455e-05     12288
...
8       268435456       0.971793        3
mpiP:
mpiP: Storing mpiP output in [./driver.8.253.1.mpiP].
mpiP:
root@f6f0fa466bc7:/hpc/lab3#
```


Profiling results:
```
root@f6f0fa466bc7:/hpc/lab3# cat ./driver.8.253.1.mpiP
```

```
@ mpiP
@ Command : ./driver
@ Version                  : 3.4.1
@ MPIP Build date          : Mar 22 2019, 05:11:21
@ Start time               : 2019 03 23 20:01:17
@ Stop time                : 2019 03 23 20:01:38
@ Timer Used               : PMPI_Wtime
@ MPIP env var             : [null]
@ Collector Rank           : 0
@ Collector PID            : 253
@ Final Output Dir         : .
@ Report generation        : Single collector task
@ MPI Task Assignment      : 0 f6f0fa466bc7
@ MPI Task Assignment      : 1 f6f0fa466bc7
@ MPI Task Assignment      : 2 f6f0fa466bc7
@ MPI Task Assignment      : 3 f6f0fa466bc7
@ MPI Task Assignment      : 4 f6f0fa466bc7
@ MPI Task Assignment      : 5 f6f0fa466bc7
@ MPI Task Assignment      : 6 f6f0fa466bc7
@ MPI Task Assignment      : 7 f6f0fa466bc7

---------------------------------------------------------------------------
@--- MPI Time (seconds) ---------------------------------------------------
---------------------------------------------------------------------------
Task    AppTime    MPITime     MPI%
   0       20.4       9.91    48.52
   1       20.4       17.2    84.40
   2       20.4       14.2    69.71
   3       20.4       16.6    81.63
   4       20.4       12.3    60.23
   5       20.4       17.2    84.12
   6       20.4         14    68.55
   7       20.4       16.8    82.41
   *        163        118    72.44
---------------------------------------------------------------------------
@--- Callsites: 9 ---------------------------------------------------------
---------------------------------------------------------------------------
 ID Lev File/Address        Line Parent_Funct             MPI_Call
  1   0 0x405b76                 [unknown]                Irecv
  2   0 0x405893                 [unknown]                Allreduce
  3   0 0x405e59                 [unknown]                Allreduce
  4   0 0x40586e                 [unknown]                Barrier
  5   0 0x405b82                 [unknown]                Wait
  6   0 0x405d80                 [unknown]                Reduce
  7   0 0x40582b                 [unknown]                Barrier
  8   0 0x405c12                 [unknown]                Wait
  9   0 0x405c08                 [unknown]                Isend
---------------------------------------------------------------------------
@--- Aggregate Time (top twenty, descending, milliseconds) ----------------
---------------------------------------------------------------------------
Call                 Site       Time    App%    MPI%     COV
Wait                    8    5.4e+04   33.13   45.74    0.32
Barrier                 4    2.3e+04   14.11   19.47    0.65
Wait                    5   1.58e+04    9.66   13.33    0.56
Reduce                  6   7.49e+03    4.59    6.34    0.18
Allreduce               3   6.22e+03    3.82    5.27    0.62
Isend                   9   5.87e+03    3.60    4.97    0.03
Irecv                   1   5.73e+03    3.51    4.85    0.55
Allreduce               2       21.2    0.01    0.02    0.16
Barrier                 7       14.9    0.01    0.01    0.08
---------------------------------------------------------------------------
@--- Aggregate Sent Message Size (top twenty, descending, bytes) ----------
---------------------------------------------------------------------------
Call                 Site      Count      Total       Avrg  Sent%
Isend                   9    2444442   5.03e+10   2.06e+04  92.13
Reduce                  6        216   4.29e+09   1.99e+07   7.87
Allreduce               2       1976   1.58e+04          8   0.00
Allreduce               3        216        864          4   0.00
---------------------------------------------------------------------------
@--- Callsite Time statistics (all, milliseconds): 62 ---------------------
---------------------------------------------------------------------------
Name              Site Rank  Count      Max     Mean      Min   App%   MPI%
Allreduce            2    0    247    0.077    0.013    0.004   0.02   0.03
Allreduce            2    1    247    0.081   0.0118    0.004   0.01   0.02
Allreduce            2    2    247    0.082   0.0122    0.004   0.01   0.02
Allreduce            2    3    247    0.055  0.00932    0.003   0.01   0.01
Allreduce            2    4    247    0.076   0.0116    0.005   0.01   0.02
Allreduce            2    5    247    0.077   0.0101    0.004   0.01   0.01
Allreduce            2    6    247    0.076   0.0103    0.003   0.01   0.02
Allreduce            2    7    247    0.054  0.00769    0.003   0.01   0.01
Allreduce            2    *   1976    0.082   0.0107    0.003   0.01   0.02

Allreduce            3    0     27    0.022    0.009    0.004   0.00   0.00
Allreduce            3    1     27      662     47.6    0.021   6.31   7.47
Allreduce            3    2     27      318     23.2    0.013   3.08   4.42
Allreduce            3    3     27      573     42.7     0.04   5.66   6.93
Allreduce            3    4     27      126     9.66    0.006   1.28   2.13
Allreduce            3    5     27      567     43.6    0.048   5.77   6.86
Allreduce            3    6     27      285     21.9     0.06   2.89   4.22
Allreduce            3    7     27      569     41.9    0.096   5.54   6.72
Allreduce            3    *    216      662     28.8    0.004   3.82   5.27

Barrier              4    0    247    0.024  0.00551    0.003   0.01   0.01
Barrier              4    1    247      433     16.2    0.014  19.63  23.25
Barrier              4    2    247      245     8.91    0.008  10.80  15.49
Barrier              4    3    247      785     18.4    0.018  22.28  27.30
Barrier              4    4    247     98.1     2.45    0.003   2.98   4.94
Barrier              4    5    247      551     16.6    0.015  20.13  23.93
Barrier              4    6    247      334     9.93    0.009  12.02  17.54
Barrier              4    7    247      931     20.7     0.02  25.03  30.37
Barrier              4    *   1976      931     11.6    0.003  14.11  19.47

Barrier              7    0    247    0.205  0.00807    0.003   0.01   0.02
Barrier              7    1    247    0.033  0.00701    0.003   0.01   0.01
Barrier              7    2    247    0.204  0.00773    0.002   0.01   0.01
Barrier              7    3    247     0.07  0.00706    0.003   0.01   0.01
Barrier              7    4    247    0.205  0.00847    0.003   0.01   0.02
Barrier              7    5    247    0.031  0.00689    0.003   0.01   0.01
Barrier              7    6    247    0.201  0.00813    0.003   0.01   0.01
Barrier              7    7    247     0.07  0.00708    0.003   0.01   0.01
Barrier              7    *   1976    0.205  0.00756    0.002   0.01   0.01

Irecv                1    0 1047618    0.277  0.00235    0.001  12.06  24.86
Irecv                1    2 349206     1.13  0.00237    0.001   4.06   5.83
Irecv                1    4 698412    0.237  0.00232    0.001   7.96  13.22
Irecv                1    6 349206    0.059  0.00233    0.001   4.00   5.83
Irecv                1    * 2444442     1.13  0.00234    0.001   3.51   4.85

Isend                9    1 349206    0.189  0.00233    0.001   3.99   4.72
Isend                9    2 349206    0.166  0.00248    0.001   4.26   6.11
Isend                9    3 349206    0.207  0.00233    0.001   3.99   4.89
Isend                9    4 349206    0.464  0.00235    0.001   4.02   6.68
Isend                9    5 349206      0.9  0.00245    0.001   4.20   4.99
Isend                9    6 349206    0.229  0.00245    0.001   4.19   6.12
Isend                9    7 349206    0.171  0.00243    0.001   4.16   5.05
Isend                9    * 2444442      0.9   0.0024    0.001   3.60   4.97

Reduce               6    0     27      281       21    0.005   2.78   5.73
Reduce               6    1     27      539     37.9    0.003   5.03   5.96
Reduce               6    2     27      538       38    0.004   5.03   7.22
Reduce               6    3     27      545       38    0.003   5.03   6.16
Reduce               6    4     27      528       38    0.006   5.03   8.36
Reduce               6    5     27      534     37.1    0.003   4.91   5.84
Reduce               6    6     27      545     37.9    0.004   5.02   7.33
Reduce               6    7     27      438     29.5    0.003   3.90   4.74
Reduce               6    *    216      545     34.7    0.003   4.59   6.34

Wait                 5    0 1047618      144  0.00656    0.001  33.65  69.35
Wait                 5    2 349206      170  0.00657    0.001  11.26  16.15
Wait                 5    4 698412      143  0.00623    0.001  21.35  35.45
Wait                 5    6 349206      140  0.00641    0.001  10.98  16.02
Wait                 5    * 2444442      170  0.00645    0.001   9.66  13.33

Wait                 8    1 349206      912   0.0288    0.001  49.43  58.56
Wait                 8    2 349206      520   0.0182    0.001  31.19  44.75
Wait                 8    3 349206      734   0.0261    0.001  44.65  54.70
Wait                 8    4 349206      214   0.0103    0.001  17.58  29.18
Wait                 8    5 349206      778   0.0287    0.001  49.09  58.35
Wait                 8    6 349206      403   0.0172    0.001  29.42  42.92
Wait                 8    7 349206      576   0.0256    0.001  43.76  53.10
Wait                 8    * 2444442      912   0.0221    0.001  33.13  45.74
---------------------------------------------------------------------------
@--- Callsite Message Sent statistics (all, sent bytes) -------------------
---------------------------------------------------------------------------
Name              Site Rank   Count       Max      Mean       Min       Sum
Allreduce            2    0     247         8         8         8      1976
Allreduce            2    1     247         8         8         8      1976
Allreduce            2    2     247         8         8         8      1976
Allreduce            2    3     247         8         8         8      1976
Allreduce            2    4     247         8         8         8      1976
Allreduce            2    5     247         8         8         8      1976
Allreduce            2    6     247         8         8         8      1976
Allreduce            2    7     247         8         8         8      1976
Allreduce            2    *    1976         8         8         8 1.581e+04

Allreduce            3    0      27         4         4         4       108
Allreduce            3    1      27         4         4         4       108
Allreduce            3    2      27         4         4         4       108
Allreduce            3    3      27         4         4         4       108
Allreduce            3    4      27         4         4         4       108
Allreduce            3    5      27         4         4         4       108
Allreduce            3    6      27         4         4         4       108
Allreduce            3    7      27         4         4         4       108
Allreduce            3    *     216         4         4         4       864

Isend                9    1  349206 2.684e+08 2.056e+04         4 7.181e+09
Isend                9    2  349206 2.684e+08 2.056e+04         4 7.181e+09
Isend                9    3  349206 2.684e+08 2.056e+04         4 7.181e+09
Isend                9    4  349206 2.684e+08 2.056e+04         4 7.181e+09
Isend                9    5  349206 2.684e+08 2.056e+04         4 7.181e+09
Isend                9    6  349206 2.684e+08 2.056e+04         4 7.181e+09
Isend                9    7  349206 2.684e+08 2.056e+04         4 7.181e+09
Isend                9    * 2444442 2.684e+08 2.056e+04         4 5.026e+10

Reduce               6    0      27 2.684e+08 1.988e+07         4 5.369e+08
Reduce               6    1      27 2.684e+08 1.988e+07         4 5.369e+08
Reduce               6    2      27 2.684e+08 1.988e+07         4 5.369e+08
Reduce               6    3      27 2.684e+08 1.988e+07         4 5.369e+08
Reduce               6    4      27 2.684e+08 1.988e+07         4 5.369e+08
Reduce               6    5      27 2.684e+08 1.988e+07         4 5.369e+08
Reduce               6    6      27 2.684e+08 1.988e+07         4 5.369e+08
Reduce               6    7      27 2.684e+08 1.988e+07         4 5.369e+08
Reduce               6    *     216 2.684e+08 1.988e+07         4 4.295e+09
---------------------------------------------------------------------------
@--- End of Report --------------------------------------------------------
---------------------------------------------------------------------------
root@f6f0fa466bc7:/hpc/lab3#
```

### Oddities:

Why do I see the following output when running stuff in this docker image?
```
Unexpected end of /proc/mounts line ... [MPI/docker noise]
Unexpected end of /proc/mounts line ... [MPI/docker noise]
```
This is an issue for OpenMPI versions prior to 2.0 printing some warnings/noise on `mpirun` and can be ignored.
