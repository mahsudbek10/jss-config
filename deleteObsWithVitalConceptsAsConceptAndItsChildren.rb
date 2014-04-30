require 'rubygems' 
require 'mysql'  

# Required Gems : ruby-mysql - sudo gem install ruby-mysql
if(ARGV.length < 1) 
	puts('give atleast one concept name as the parameter')
else 
	con = Mysql.new('localhost', 'openmrs-user', 'password', 'openmrs',nil,'/var/lib/mysql/mysql.sock')  

	ARGV.each do |concept_name|
		puts "deleting concept_set #{concept_name}"
		rs = con.query('delete from concept_set where concept_set in (select concept_id from concept_name where name like \'' + concept_name + '\');')  

		queue = Queue.new

		rs = con.query('select * from obs where concept_id in (select concept_id from concept_name where name like \'' + concept_name + '\');')  
		rs.each_hash { |h| queue << h['obs_id']}  

		until queue.length() <= 0  do
		   val = queue.pop
		   rs = con.query('select * from obs where obs_group_id = ' + val + ';')
			if rs.size == 0
		   		del = con.query('delete from obs where obs_id = ' + val + ';')
		   else
		   	queue << val
		   	rs.each_hash { |h| queue << h['obs_id']}
		   end
		end

		puts "deleted concept_set #{concept_name}"
	end
	con.close
end