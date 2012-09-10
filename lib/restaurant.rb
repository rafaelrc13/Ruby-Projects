require 'support/number_helper.rb'
class Restaurant

	include NumberHelper
	@@filepath = nil

	def self.filepath=(path=nill)
		@@filepath = File.join(APP_ROOT, path)
	end


	def self.file_exists?
		if @@filepath && File.exists?(@@filepath)
			return true
		else
			return false
		end
		# class should know if the restaurant file exists		
	end

	def self.file_usable?	
		return false unless @@filepath
		return false unless File.exists?(@@filepath)
		return false unless File.readable?(@@filepath)
		return false unless File.writable?(@@filepath)
		return true
	end

	def self.create_file
		# create the restaurant file
		File.open(@@filepath, 'w') unless file_exists?
		return file_usable?
	end

	def self.build_using_questions
		args ={}
		print	"Restaurant name: "
		args[:name] = gets.chomp.strip
		
		print	"Cuisine type: " 
		args[:cuisine] = gets.chomp.strip
	
		print	"Average price: "
		args[:price] = gets.chomp.strip
		
		return self.new(args)
	end

	def self.saved_restaurants
		restaurants = []
		if file_usable?
			file = File.new(@@filepath, 'r')
			file.each_line do |line| 
				restaurants << Restaurant.new.import_line(line.chomp)
			end
			file.close
		end
		return restaurants
	end

	def self.update(restaurants)
		return false unless Restaurant.file_usable?
		File.open(@@filepath,'w') do |file|
			restaurants.each do |rest|
				file.puts "#{[rest.name, rest.cuisine, rest.price].join("\t")}\n"
			end
		end
	end

	attr_accessor :name, :cuisine, :price

	def initialize(args={})
		@name 	= args[:name] 	  || ""
		@cuisine = args[:cuisine] || ""
		@price 	= args[:price]   || ""
	end

	def save
		return false unless Restaurant.file_usable?
		File.open(@@filepath,'a') do	|file|
			file.puts "#{[@name, @cuisine, @price].join("\t")}\n"
		end
		return true
	end

	def formatted_price
		number_to_currency(@price)
	end

	def import_line(line)
		line_array = line.split("\t")
		@name, @cuisine, @price = line_array
		return self
	end

end