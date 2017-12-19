README
Network Simulation 1
This code was submitted as a part of ECEN 602 Assignment at Texas A&M University.
Team 21: Akshay Gajanan Hasyagar and Karthikeyan Kathiresan

Simulator used : NS2

Usage:

ns <filename.tcl> <TCP version> <Case Number>

TCP version: VEGAS or SACK
Case Number: 1 or 2 or 3

Example usage: 

ns ns2.tcl VEGAS 2
ns ns2.tcl SACK 3

Simulation:

FTP sources start at 0.5 seconds.

Procedure ‘calculate’ called at 100 seconds. The calculated throughput values for source1, source2 and ratio of throughputs, at every step time (0.5 seconds) starting at 100.5 seconds till 400 seconds are put in the files src1_output.tr, src2_output2.tr and ratio_output.tr

At 400.5, the average throughputs and throughputs are calculated and displayed. To get outputs, go to folder and gedit src1_output.tr, src2_output2.tr and ratio_output.tr

At 401 seconds, the FTP sources stop. 

And at 405 seconds, the simulation completes by calling the procedure ‘complete’

To get graphs, go to folder and then xgraph src1_output.tr, src2_output2.tr and ratio_output.tr
To view animation, uncomment the following line and enter the appropriate NAM folder name.
#exec <nam folder> out.nam &




Errata:
Giving improper inputs in the command line will throw console message on terminal.
After each case and its TCP type is implemented, messages are thrown on the terminal for user knowledge.



