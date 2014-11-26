#!/usr/bin/env python
import re
import sys
import operator
import math

def meanstdv(x): 
    n, mean, std = len(x), 0, 0 
    for a in x: 
        mean = mean + a 
    mean = mean / float(n) 
    variance = 0
    for a in x: 
        variance = variance + (a - mean)**2 
    variance = variance / float(n)
    std = math.sqrt(variance) 
    rsd = std / mean * 100
    return mean, variance, std, rsd

class ycsb_output:
    iteration_partitioner = r"cs>> start(.*)"
    iteration_parser = r"\s*cs>> iteration : (?P<iteration>\d+)\s*cs>> threads : (?P<threads>\d+)\s*.*\[OVERALL\], Throughput\(ops/sec\), (?P<overall_throughput_ops_sec>\d+\.\d+)\s*.*"
    operation_partitioner = r"\[[a-zA-Z]*\], Operations"
    operation_parser = r", (?P<op_operations>\d+)\s*\[(?P<op>[a-zA-Z]*)], AverageLatency\(us\), (?P<op_average_latency_us>\d+\.\d+)\s*\[[a-zA-Z]*\], MinLatency\(us\), (?P<op_min_latency_us>\d+)\s*\[[a-zA-Z]*\], MaxLatency\(us\), (?P<op_max_latency_us>\d+)\s*\[[a-zA-Z]*\], 95thPercentileLatency\(ms\), (?P<op_95th_percentile_latency_ms>\d+)\s*\[[a-zA-Z]*\], 99thPercentileLatency\(ms\), (?P<op_99th_percentile_latency_ms>\d+)\s*.*"
    threads_data = {}

    def __init__(self, text):
        self.m = re.split(self.iteration_partitioner, text,re.DOTALL)
        ip_re = re.compile(self.iteration_parser,re.DOTALL)
        op_re = re.compile(self.operation_parser,re.DOTALL)
        for iteration_str in self.m:
            if len(iteration_str) > 0:
               iteration = ip_re.match(iteration_str);
               if not iteration:
                  return
                  raise Exception('Input does not match')
               threads = int(iteration.group('threads'))
               self.add(threads,iteration.group('iteration'),'overall_throughput_ops_sec',float(iteration.group('overall_throughput_ops_sec')))
               o = re.split(self.operation_partitioner,iteration_str,re.DOTALL)
               for operation_str in o:
                   operation = op_re.match(operation_str)
                   if operation:
                      self.add(threads,iteration.group('iteration'),operation.group('op').lower()+"_operations",int(operation.group('op_operations')))
                      self.add(threads,iteration.group('iteration'),operation.group('op').lower()+"_average_latency_us",float(operation.group('op_average_latency_us')))
                      self.add(threads,iteration.group('iteration'),operation.group('op').lower()+"_min_latency_us",int(operation.group('op_min_latency_us')))
                      self.add(threads,iteration.group('iteration'),operation.group('op').lower()+"_max_latency_us",int(operation.group('op_max_latency_us')))
                      self.add(threads,iteration.group('iteration'),operation.group('op').lower()+"_95th_percentile_latency_ms",int(operation.group('op_95th_percentile_latency_ms')))
                      self.add(threads,iteration.group('iteration'),operation.group('op').lower()+"_99th_percentile_latency_ms",int(operation.group('op_99th_percentile_latency_ms')))
                   
    def add(self,threads,iteration,attr,val):
        if threads not in self.threads_data:
           self.threads_data[threads] = {}
        if attr not in self.threads_data[threads]:
           self.threads_data[threads][attr] = []
        self.threads_data[threads][attr].append(val)
    
    def get_threads(self):
        return self.threads_data.keys()    
            
    def get_threads_attrs(self,threads):
        return self.threads_data[threads].keys()    

    def get_threads_attr_val(self,threads,attr):
        return self.threads_data[threads][attr]    

def print_table(data):
    formats = []

    for header, value in data:
        formats.append('%%%ds' % (max(len(str(value)), len(header))))

    format = ' '.join(formats)

    print format % tuple(map(operator.itemgetter(0), data))
    print format % tuple(map(str, map(operator.itemgetter(1), data)))

def read(filename):
    with open(filename) as file:
        return ycsb_output(file.read())

if __name__ == "__main__":
    attrs = ['overall_throughput_ops_sec','read_operations','update_operations','write_operations','delete_operations','scan_operations','read_average_latency_us','update_average_latency_us','write_average_latency_us','delete_average_latency_us','scan_average_latency_us','read_min_latency_us','update_min_latency_us','write_min_latency_us','delete_min_latency_us','scan_min_latency_us','read_max_latency_us','update_max_latency_us','write_max_latency_us','delete_max_latency_us','scan_max_latency_us','read_95th_percentile_latency_ms','update_95th_percentile_latency_ms','write_95th_percentile_latency_ms','delete_95th_percentile_latency_ms','scan_95th_percentile_latency_ms','read_99th_percentile_latency_ms','update_99th_percentile_latency_ms','write_99th_percentile_latency_ms','delete_99th_percentile_latency_ms','scan_99th_percentile_latency_ms']
    summary = read(sys.argv[1])
    for threads in summary.get_threads():
        print "threads: ",threads
        for attr in attrs:
            if attr in summary.get_threads_attrs(threads):
               mean, variance, stddev, rsd = meanstdv(summary.get_threads_attr_val(threads,attr))
               print attr,": ",mean,",",variance,",",stddev,",",rsd
