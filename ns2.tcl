

#New simulator instance
set ns [new Simulator]


#Validate input arguements
if {$argc!=2} {
puts "Please enter correct arguements"
exit 0
}

#Output files 
set nf [open out.nam w]
set tf [open out.tr w]
set output1 [open src1_output.tr w]
set output2 [open src2_output.tr w]
set output3 [open ratio_output.tr w]

#Trace enabling
$ns trace-all $tf
$ns namtrace-all $nf

#Initial value
set sum1 0
set sum2 0
set counter 0

#calculate{} procedure to calculate throughput
proc calculate {} {

#Variables
global ns tcpsink1 tcpsink2 output1 output2 output3 sum1 sum2 counter

set bw0 [$tcpsink1 set bytes_]
set bw1 [$tcpsink2 set bytes_]


#Step time
set time 0.5

#Current time
set now [$ns now]


#Initialization

if {$now == 100} {
	$tcpsink1 set bytes_ 0
	$tcpsink2 set bytes_ 0
	
}

#Throughput between 100 and 400 seconds
if {$now > 100 && $now<= 400 } {
	set throughput1 [expr $bw0/$time *8/1000000]
	set throughput2 [expr $bw1/$time *8/1000000]
	set sum1 [expr $sum1 + $throughput1]
	set sum2 [expr $sum2 + $throughput2]
	set counter [expr $counter + 1]
	set ratio [expr $throughput1/$throughput2]

	#Write values to output files
	#puts "Time: $now Throughput1: $throughput1"
	puts $output1 "$now $throughput1"
	#puts "Time: $now Throughput2: $throughput2"
	puts $output2 "$now $throughput2"
	#puts "Throughput1/ Throughput2: $ratio"
	puts $output3 "$ratio"
	$tcpsink1 set bytes_ 0
	$tcpsink2 set bytes_ 0
}

if { $now == 400.5 } {
	set averagethroughput1 [ expr $sum1/$counter]
	set averagethroughput2 [ expr $sum2/$counter]
	puts "Average throughput for src1 : $averagethroughput1"
	puts "Average throughput for src2 : $averagethroughput2"
	set ratio [expr $averagethroughput1/$averagethroughput2]
	puts "Ratio of throughputs : $ratio"
	
}	

#Recursion call
$ns at [expr $now + $time] "calculate"
}



#Set nodes in the system
set R1 [$ns node]
set R2 [$ns node]
set src1 [$ns node]
set src2 [$ns node]
set rcv1 [$ns node]
set rcv2 [$ns node]

#Link between R1 R2 - DropTail chosen
$ns duplex-link $R1 $R2 1Mb 5ms DropTail

#Setup based on the input arguements

if {[lindex $argv 0] eq "VEGAS"} {
	puts "TCP version : VEGAS"
	set tcp1 [new Agent/TCP/Vegas]
	set tcp2 [new Agent/TCP/Vegas]
}


if {[lindex $argv 0] eq "SACK"} {
	puts "TCP version : SACK"
	set tcp1 [new Agent/TCP/Sack1]
	set tcp2 [new Agent/TCP/Sack1]
}


if {[lindex $argv 1] eq "1"} { #Case 1 - Black receivers
	puts "Case 1: end to end delay/RTT ratio 1:2"
	$rcv1 color black
	$rcv2 color black
	$src1 color black
	$src2 color black

	$ns duplex-link $src1 $R1 10Mb 5ms DropTail
	$ns duplex-link $src2 $R1 10Mb 12.5ms DropTail
	$ns duplex-link $R2 $rcv1 10Mb 5ms DropTail
	$ns duplex-link $R2 $rcv2 10Mb 12.5ms DropTail

}

if {[lindex $argv 1] eq "2"} { #Case 2 - Red receivers
	puts "Case 2: end to end delay/RTT ratio 1:3"
	$rcv1 color red
	$rcv2 color red
	$src1 color red
	$src2 color red

	$ns duplex-link $src1 $R1 10Mb 5ms DropTail
	$ns duplex-link $src2 $R1 10Mb 20ms DropTail
	$ns duplex-link $R2 $rcv1 10Mb 5ms DropTail
	$ns duplex-link $R2 $rcv2 10Mb 20ms DropTail

}

if {[lindex $argv 1] eq "3"} { #Case 3 - Yellow receivers
	puts "Case 3: end to end delay/RTT ratio 1:4"
	$rcv1 color yellow
	$rcv2 color yellow
	$src1 color yellow
	$src2 color yellow
	
	$ns duplex-link $src1 $R1 10Mb 5ms DropTail
	$ns duplex-link $src2 $R1 10Mb 27.5ms DropTail
	$ns duplex-link $R2 $rcv1 10Mb 5ms DropTail
	$ns duplex-link $R2 $rcv2 10Mb 27.5ms DropTail
}



#TCP Sinks initialization
set tcpsink1 [new Agent/TCPSink]
set tcpsink2 [new Agent/TCPSink]

#Attach and connect
$ns attach-agent $src1 $tcp1
$ns attach-agent $src2 $tcp2
$ns attach-agent $rcv1 $tcpsink1
$ns attach-agent $rcv2 $tcpsink2
$ns connect $tcp1 $tcpsink1
$ns connect $tcp2 $tcpsink2

#Setting up FTP Agents and attaching over TCP
set ftp1 [new Application/FTP]
set ftp2 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp2 attach-agent $tcp2

#Layout

$R1 shape circle
$R2 shape circle
$R1 color brown
$R2 color brown

$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $src1 $R1 orient 320deg
$ns duplex-link-op $src2 $R1 orient 80deg
$ns duplex-link-op $rcv1 $R2 orient 260deg
$ns duplex-link-op $rcv2 $R2 orient 140deg

#Complete{} Procedure
proc Complete {} {

	global ns nf tf
	$ns flush-trace

	close $nf
	close $tf

	#exec <nam folder> out.nam &
	exit 0
}

#Activity
$ns at 0.5 "$ftp1 start"
$ns at 0.5 "$ftp2 start"

#Call calculate
$ns at 100 "calculate"

$ns at 401 "$ftp1 stop"
$ns at 401 "$ftp2 stop"


#Call Complete
$ns at 405 "Complete"
$ns run



