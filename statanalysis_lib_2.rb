# encoding: UTF-8


######################################################################################
#dArray[x][y][z] 
# x is different files e.g. x == 0 is file 10_hist.csv
# y is different columns i.e. 0: hist diameters 1: diameter frequency 2: total volume
# z is different elements within the column
######################################################################################
#                                INPUT FILES
#*_hist :  3 Columns are diameter bins, frequency, total volume
#raw    :  3 Columns are x, y, diameters
#####################################################################################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Neatly exit w/ ctrl+c
trap("SIGINT") {abort("  ....Aborting program....")} #{ exit! }

def continue?
  print "Would you like to continue analyzing data? [y]/[n]): "
  continue = gets.chomp.downcase
  abort("Aborting program NOW") if continue == "n" 
end

#Changing this method requires you to fix save_results? method
def initialize_data_arrays_for_multiple_runs
  hist_results = Array.new([["Filename"],["Volume_Sum"]])   
  raw_results = Array.new([["Filename"],["Avg._Diameter"],["Avg._Volume"]]) 
  return hist_results,raw_results
end 
  

def newfilename?(fname,verb="new")
  print "Filename for #{verb} file? ([return] for #{fname}): "
  temp = gets.chomp; fname = temp unless temp == ""; return fname
end

def open_file(filename)
  system("open #{filename}")
end


def read_columns(filename)
  File.open(filename, 'r') do |infile|
	begin
	  infile.lines.map(&:split).transpose
	rescue
	  abort("You do not have the same number of items on each line in your data file OR you may have an empty line. Please fix.  Aborting now!")
	end     
  end
end



def save_results?(hist_results,raw_results)
  puts "Would you like to write hist or raw results to file?"
  print "[h]ist, [r]aw, [b]oth, [n]one :"
  sel = gets.chomp.downcase
  
  #METHODS save_hist and save_raw must be changed
  #if you change the initialize_data_arrays_for_multiple_runs method
  #Just change the f.write line in each method to match initialized arrays
  def save_hist(hist_results,filename="results.hist.log")
    f = File.open(filename,'w')
    (0...hist_results[0].length).each do |x|
      f.write("#{hist_results[0][x]} #{hist_results[1][x]} \n")
    end
    f.close
  end 
  
  if sel == "h" 
    save_hist(hist_results)
  end
  
  def save_raw(raw_results,filename="results.raw.log")
    f = File.open(filename,'w')
    (0...raw_results[0].length).each do |x|
      f.write("#{raw_results[0][x]}, #{raw_results[1][x]}, #{raw_results[2][x]} \n")
    end
    f.close
  end  
  
  if sel == "r" 
    save_raw(raw_results)
  end
  
  if sel == "b" 
    save_hist(hist_results)
    save_raw(raw_results)
  end
  
end


def volume_from_diameter(d)
  volume = lambda{|d| (4.0/3.0)*Math::PI*((d/2.0)**3.0)}
  volume.(d)
end


def sep(n=1,s="************************************************************************")
  n.times {puts s}
end


def wtd #What to do?
  print "Work with histograms or raw data? [h]/[r]: "
  s = gets.chomp

  if s == "h"
    puts "[1] Make an 'added' histogram from multiple _hist files."
  elsif s == "r"
    puts "[1] Concatenate files."
  end
  
  puts   "[2] Get stats for single file."
  print "What would you like to do? [1] or [2]: "
  w = gets.chomp.to_i
  return s,w
end


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class PrintArrays < Array

  def print_file_array #Prints array with numbers for selection 
    (0...self.length).each {|x| puts "[#{x+1}] #{self[x]}"}
  end
  
end


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class OneDArray < Array  #Get rid of class name and just extend Array?
  def sum
    inject(0) { |result, element| result + element }
  end
  
  def average
    sum / length
  end
  
  def variance
    avg = average 
    s = inject(0){|result, element| result + (element-avg)**2}
    s / length
  end 
  
  def sd
    avg = average
    s = inject(0){|result, element| result + (element-avg)**2}
    Math.sqrt( s / (length - 1) ) 
  end 
  
  def printstats_w_Sum
    puts "Sum: #{sum} \nAvg: #{average} \nSD : #{sd} \n" 
  end  
  
  def printstats
    puts "Avg: #{average} \nSD : #{sd} \nVariance: #{variance} \n" 
  end  

end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Hist 
  @@hist_results = Array.new([["Filename"],["Volume_Sum"]])
  
  def initialize
         
  end
  
  def get_hist_data(dArray)
    sep; puts "Histogram files to be read:"; hist_list = Dir.glob "*_hist.csv"
    a = PrintArrays.new(hist_list); a.print_file_array; sep
    hist_list.each {|i| dArray << read_columns(i)}  #READS ALL FILES TO 3D ARRAY
    return hist_list,dArray
  end
  
  def sh1(hist_list,dArray)  #selections histogram and 1
    puts "Will concat raw data csv files"
    puts "Enter index number of all files to read in, separated by spaces."
    puts "e.g. $1 2 3 4 "
    print "Files to concat? $"
    selections = gets.chomp.split(" ").each.map{|x| x.to_i - 1}
    puts "#{ selections.each.map{|x| hist_list[x]} }"
    fname = newfilename?("Added_hist.csv","added")
    labels = dArray[selections[0]][0]; diameters = []; volumes = []
    diameters = selections.each.map{|x| dArray[x][1]}
    volumes   = selections.each.map{|x| dArray[x][2]}
    
    def xyloop(xmin,xmax,ymin,ymax,arrayname) 
      newcolumn = [0.0]*arrayname[0].length
      (xmin...xmax).each do |x|
        (ymin...ymax).each do |y|
          newcolumn[y] += arrayname[x][y].gsub(/\,/,"").to_f
        end
      end
      return newcolumn
    end
    
    newdiametercol = xyloop(0,diameters.length,0,diameters[0].length,diameters)
    newvolcol      = xyloop(0,volumes.length,0,volumes[0].length,volumes)

    f = File.open(fname,'w')
    #(0...labels.length).to_a.each{|i| f.write "#{labels[i].gsub(/\,/,"")}, #{newdiametercol[i]}, #{newvolcol[i]} \n"}
    (0...labels.length).to_a.each{|i| f.write "#{labels[i]} #{newdiametercol[i]}, #{newvolcol[i]} \n"}
    puts "Created #{fname} file"
    f.close #this is necessary!
    print "Do you want to open new file (Unix only)? [y]/[n] :"; openit = gets.chomp
    open_file(fname) if openit == "y"
  end
  
  def sh2(dArray,fileselection,hist_list) #selections histogram and 2
    filename = hist_list[fileselection]
    dataArray = dArray[fileselection]
    puts "Will calculate average for the third column (i.e. Total Volumes)"
    puts "Using file #{filename}"

    return(dataArray[2].collect{|i| i.to_f}) #dataArray[2] is total volumes
  end
  
  def print_h_stats(dArray,fileselection,hist_list,hist_results)
    a = OneDArray.new(Hist.new.sh2(dArray,fileselection,hist_list))
    puts "Stats: "; puts "Sum: #{a.sum} um^3"
    hist_results[0] << hist_list[fileselection]; hist_results[1] << a.sum
    print hist_results
  end
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Raw 

  def get_raw_data(dArray)
    sep; puts "Raw data files to be read:"; 
    raw_list = Dir.glob "*.csv";
    #Remove _hist files from raw_list
    raw_list.find_all{|i| i =~ /_hist/}.each {|del| raw_list.delete_at(raw_list.index(del))}
    a = PrintArrays.new(raw_list); a.print_file_array; sep
    raw_list.each {|i| dArray << read_columns(i)}  #READS ALL FILES TO 3D ARRAY
    return raw_list,dArray
  end
  
  def sr1(raw_list,dArray)  #selections raw and 1
    puts "Will concat raw data csv files"
    puts "Enter index number of all files to read in, separated by spaces."
    puts "e.g. $1 2 3 4 "
    print "Files to concat? $"
    selections = gets.chomp.split(" ").each.map{|x| x.to_i - 1}.each.map{|x| raw_list[x]}
    print "#{selections} \n"
    #print "Filename of concat'd file? (e.g. Added_raw.csv): "; fname = gets.chomp
    fname = newfilename?("Added_raw.csv","concat'd")
    File.open(fname,"w"){|f|
      f.puts selections.sort.map{|s| IO.read(s)} }
    puts "Successfully wrote new file, #{fname}"
    print "Do you want to open new file (Unix only)? [y]/[n] :"; openit = gets.chomp
    open_file(fname) if openit == "y"
  end
  
  def sr2(dArray,fileselection,raw_list)  #selections raw and 2
    filename = raw_list[fileselection]
    dataArray = dArray[fileselection]
    puts "Using file #{filename}"
    return(dataArray[2].collect{|i| i.to_f}) #dataArray[2] is raw diameters
  end  
  
  def print_r_stats(dArray,fileselection,raw_list,raw_results) #extension of sr2
    subArrayZ = Raw.new.sr2(dArray,fileselection,raw_list)
    a = OneDArray.new(subArrayZ)
    puts "Raw Diameter Stats: "; a.printstats
    puts "Number of data points: #{a.length}"
    volume = lambda{|d| (4.0/3.0)*Math::PI*((d/2.0)**3.0)}
    b = OneDArray.new(subArrayZ.each.map{|d| volume.(d)})
    puts "Raw Volume Stats: "; b.printstats_w_Sum
    
    raw_results[0] << raw_list[fileselection] 
    raw_results[1] << a.average
    raw_results[2] << b.average
    print raw_results, "\n"
  end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~