# encoding: UTF-8

load "/Users/Joe/Documents/scripts/statanalysis_lib.rb"

############################################################################

hist_results,raw_results = initialize_data_arrays_for_multiple_runs

while ((1.0/0)+1) #Start of infinite loop

sep(3)
dArray = Array.new

#Populate control variables s and whattodo with user input
s,whattodo = wtd()
 
#Get data: It gets read in differently depending on whether it is raw data 
#or has already been histogram-ized 
hist_list,dArray = Hist.new.get_hist_data(dArray) if s == "h"
raw_list,dArray  = Raw.new.get_raw_data(dArray)   if s == "r"


#"Combine file" operations
if whattodo == 1
  Hist.new.sh1(hist_list,dArray) if s == "h"   #Add hist files together
  Raw.new.sr1(raw_list,dArray)   if s == "r"   #Concat raw files
end


#"Do Statistics" operations
if whattodo == 2
  print "File selection to calculate stats [number]?: "
  fileselection = gets.chomp.to_i - 1
  
  if s == "h"
    Hist.new.print_h_stats(dArray,fileselection,hist_list,hist_results)
  elsif s == "r"
    Raw.new.print_r_stats(dArray,fileselection,raw_list,raw_results)
  end
  
end

sep
save_results?(hist_results,raw_results)
sep
continue?

end #End of infinite loop



