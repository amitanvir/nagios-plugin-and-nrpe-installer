#!/usr/bin/perl
use Getopt::Long;
use Switch;

%options = (
			'help' => 0,
			'cache' => 0,
			'backend' => 0,
			'bin' => '/usr/bin/varnishstat',
			'technique' => 'gt'
		);


if(!GetOptions(
			'h|help'	=> \$options{'help'},
			'a|cache'	=> \$options{'cache'},
			'd|backend=s'	=> \$options{'backend'},
			'b|bin=s'		=> \$options{'bin'},
			'w|warning=f'	=> \$options{'warning'},
			'c|critical=f' =>	\$options{'critical'},
			's|stats=s'		=> \$options{'stats'},
			't|technique=s' => \$options{'technique'}
		)) { print_help(); exit(3);}

print $options{'secret'};

%results;
$overallResult;

sub run_varnishstat_command {
	#$result = qx(/usr/bin/varnishstat -1 -f cache_hit,cache_hitpass,cache_miss \\| awk '{ print $2; }');
	$result = qx($options{'bin'} -1 -f $stats);
	@ans = split (/\n/s, $result);

	#print $result . " \n";

	foreach $line (@ans) {
		$line =~ /([^\s]+)/;
    	$resultname=$1;

    	$line =~ /(\d+)/;

    	$results{$resultname} = $1;
	}
}

sub get_hit_ratio {
	$allhits = $results{'cache_hit'} + $results{'cache_hitpass'} + $results{'cache_miss'};

	$cachehitratio = $results{'cache_hit'} / $allhits;

	return $cachehitratio;
}

sub check_is_running {
	$result = qx(ps aux | grep "varnishd" | grep -v "grep" -c);
	
	$result =~ /(\d)/;

	if(int($1) < 1) {
		print "CRITICAL: Varnishd not running";
		exit(2);
	}
	else {
		print "OK: Varnishd is running";
		exit(0);
	}
}

sub print_help {
	print "
check_varnish.pl - Monitor and report on varnish usage

check_varnish.pl [-c|--cache] [-b|--bin <varnishstatbinary>] 
	[-d|--backend <total|ratio>] [-s|--stats <varnish statfield>] 
	[-t|--technique <lt|gt>] [-w|--warning <number>] 
	[-c|--critical <number>] [-h|--help]

DESCRIPTION

This script will report on various varnish stats including:
varnish cache hit ratio
backend error count (Total or Ratio)
Any other counter in varnishstat
If no counters are required the script will ensure the varnish binary is running

OPTIONS

  -a --cache - this will make the script output cache_hit ratio perfdata
  -b --bin <varnishstat> - to specify a different location of the default 
                           varnishstat binary location. Default is 
                           '/usr/bin/varnishstat'
  -d --backend <all|success|unhealthy|busy|fail|reuse|toolate|recycle|retry> - 
                        specify script to output backend data you can 
                        output ratio, total or both	
  -h --help - output this message
  -w --warning <number> - specify the warning threshold. Required for cache and 
                          backend checks
  -c --critical <number> - specify the critical threshold. Required for cache and
                           backend checks
  -s --stats <varnishstat field> - specify a comma seperated list of all the stats 
                           you wish to check Critical and Warning can be specified 
                           and all values will be compared to these values. 
  -t --technique <lt|gt> - when specifying stats you can also specify what technique
                           you wish to use to compare the values to the thresholds.
                           specify lt for less than and gt for greater than.
                           Default is gt

EXAMPLES
  Check varnish is running
  ./check_varnish.pl

  Check varnish Cache Hit Ratio and warn if ratio is below 0.8
  ./check_varnish.pl -a -w 0.8 -c 0.6

  Check varnish Backends
  ./check_varnish.pl -d all 

  Check varnish client requests and drops
  ./check_varnish.pl -s client_drop,client_req
";
}

sub check_warn_crit {
	if($options{'warning'} eq '' || $options{'critical'} eq '') {
		print "Warning and critical must be specified \n";
		print_help();
		exit(3);
	}
}

sub check_thresholds {
	#print $_[0] . $options{'warning'} . $options{'critical'};
	if($_[1] eq "lt") {
		if($_[0] < $options{'warning'}) {
			if($_[0] < $options{'critical'}) {
				return 2;
			}
			else {
				return 1;
			}
		}
		else {
			return 0;
		}
	}
	else {
		if($_[0] > $options{'warning'}) {
			if($_[0] > $options{'critical'}) {
				return 2;
			}
			else {
				return 1;
			}
		}
		else {
			return 0;
		}
	}
}

sub exit_script {
	switch($overallresult) {
		case 0	{ print "OK: " . $_[0]; exit(0) }
		case 1	{ print "WARNING: " . $_[0]; exit(1) }
		case 2	{ print "CRITICAL: " . $_[0]; exit(2) }
		else	{ print "UNKNOWN: " . $_[0]; exit(3); }
	}
}

if($options{'help'}) {
	print_help();
	exit(3);
}

if($options{'cache'}) {
	check_warn_crit();
	$stats = "cache_hit,cache_hitpass,cache_miss";
	run_varnishstat_command();
	$hitratio = sprintf("%.2f", get_hit_ratio());
	$overallresult= check_thresholds($hitratio, "lt");
	exit_script("cache_hit_ratio=" . $hitratio . " | cache_hit_ratio=" . $hitratio . ";;;");
}

if($options{'backend'}) {
	#print $results{'backend_conn'}."\n";
	if($options{'backend'} eq "all") {
		$stats = "backend_conn,backend_unhealthy,backend_busy,backend_fail,backend_resuse,backend_toolate,backend_recycle,backend_retry";
		run_varnishstat_command();
		$result="";
		$perfdata="";
		foreach my $key ( keys %results ) {
			$result .= $key . "=" . $results{$key} . " ";
			$perfdata .= $key . "=" . $results{$key} . ";;;; ";
		}
		$overallresult=0;
		exit_script($result . "| " . $perfdata);
	}
	else {
		check_warn_crit();	
		$stats = "backend_".$options{'backend'};
		run_varnishstat_command();
		$overallresult=check_thresholds($results{$stats});
		exit_script($stats . "= " . $results{$stats} . " | " . $stats . "=" . $results{$stats} . ";" . $options{'warning'} . ";" . $options{'critical'} . ";;");
	}
	
}

if($options{'stats'}) {
	$stats = $options{'stats'};
	run_varnishstat_command();
	$result="";
	$perfdata="";
	$overallresult =0;
	foreach my $key ( keys %results ) {
		if($options{'critical'} && $options{'warning'}) {
			$thisresult = check_thresholds($results{$key}, $options{'technique'});

			if($thisresult > $overallresult) {
				$overallresult = $thisresult;
			}
		}
		$result .= $key . "=" . $results{$key} . " ";
		$perfdata .= $key . "=" . $results{$key} . ";;;; ";
	}
	exit_script($result . "| " . $perfdata);
}

check_is_running();
exit(3);

#print sprintf("%.2f", $cachehitratio) . "\n";
