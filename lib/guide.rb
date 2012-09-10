require 'restaurant'
require 'support/string_extend'
class Guide

	class Config
		@@actions = ['list','find','add','delete','update','quit']
		def self.actions; @@actions; end
	end

	def initialize(path=nil)
		# locate the restaurant text file at path
		Restaurant.filepath = path
		if Restaurant.file_usable?
			puts "Found restaurant file."
		elsif Restaurant.create_file
			puts "Created restaurant file."
		# or create a new file
		else
			puts "Exiting.\n\n"
			exit!
		# exit if create fails
		end
	end

	def launch!
		introduction
		# action loop
		result = nil
		until result == :quit
			action, args = get_action
			result = do_action(action, args)
		end
		conclusion
	end

	def get_action
		action = nil
		#Keep asking for user input until we get a valid action
		until  Guide::Config.actions.include?(action)
			puts "Actions: " + Guide::Config.actions.join(", ") if action
			print "> "
			user_response = gets.chomp
			args = user_response.downcase.strip.split(' ')
			action = args.shift
		end
		return [action,args]
	end

	def do_action(action, args=[])
		case action
		when 'list'
			list(args)
		when 'find'
			find(args)
		when 'add'
			add
		when 'update'
			update_price(args)
		when 'delete'
			delete(args)
		when 'quit'
			return :quit
		else
			puts "\nI don't understand that command.\n"
		end
	end

	def sort_order(restaurants=[], args=[])
		sort_order = args.shift
		sort_order = args.shift if sort_order == "by"
		sort_order ||= "name" unless ["name","cuisine","price"].include?(sort_order) 
		restaurants.sort! do |r1, r2|
			case sort_order
			when "name"
				r1.name.downcase <=> r2.name.downcase
			when "cuisine"
				if r1.cuisine.downcase == r2.cuisine.downcase
					r1.name.downcase <=> r2.name.downcase
				else
					r1.cuisine.downcase <=> r2.cuisine.downcase
				end
			when "price"
				if r1.price.to_i == r2.price.to_i
					r1.name.downcase <=> r2.name.downcase
				else
					r1.price.to_i <=> r2.price.to_i
				end
			end
		end
	end

	def add
		output_action_header("Add a restaurant")
		restaurant = Restaurant.build_using_questions
		if restaurant.save
			puts "\nRestaurant Added\n\n"
		else
			puts "\nSave Error: Restaurant not added"
		end
	end

	def update_price(args=[])
		output_action_header("Update a restaurant price")
		name_rest = complete_name(args)
		restaurants = Restaurant.saved_restaurants
		restaurant = restaurants.find {|rest| rest.name.downcase.strip.squeeze(" ") == name_rest.downcase.strip}
		if restaurant != nil
			print "New Price: " 
			restaurant.price = gets.chomp.strip
			puts "\n"
			Restaurant.update(restaurants)
		else
			puts "Enter a restaurant's name belonging to the following list:"
		end
		output_restaurant_table(sort_order(restaurants))
	end

	def delete(args=[])
		output_action_header("Delete a restaurant")
		name_rest = complete_name(args)
		restaurants = Restaurant.saved_restaurants
		restaurants = restaurants.delete_if {|rest| rest.name.downcase.strip == name_rest.downcase.strip}
		Restaurant.update(restaurants)
		output_restaurant_table(sort_order(restaurants)) 
	end

	def complete_name(args=[])
		name = ""
		until args == []
			name += args.shift + ' '			
		end
		return name
	end
	
	def list(args=[])
		output_action_header("Listing restaurants")
		restaurants = Restaurant.saved_restaurants
		sort_order(restaurants, args)
		output_restaurant_table(restaurants)
		puts "Sort using: 'list cuisine' or 'list by cuisine'"
	end

	def find(args=[])
		keyword = args.shift || ""
		output_action_header("Find a restaurant")
		if keyword
			restaurants = Restaurant.saved_restaurants
			found = restaurants.select do |rest|
				rest.name.downcase.include?(keyword.downcase) ||
				rest.cuisine.downcase.include?(keyword.downcase) ||
				rest.price.to_i <= keyword.to_i
			end
			output_restaurant_table(sort_order(found, args))
			# search
		else
			puts "Find using a key phrase to search the restaurant list."
			puts "Examples: 'find tomale', 'find tomale', 'find mex'\n\n"
		end
		return found
	end


	def introduction
		puts "\n\n<<< Welcome to the Food Finder >>>\n\n"
		puts "This is an interactive guide to help you find the food you crave.\n\n"
	end

	def conclusion
		puts "\n<<< Goodbye and Bon Appetit! >>>\n\n\n"
	end

	private

	def output_action_header(text)
		puts "\n#{text.upcase.center(60)}\n\n"
	end

	def output_restaurant_table(restaurants=[])
		print " " + "Name".ljust(30)
		print " " + "Cuisine".ljust(20)
		print " " + "Price".rjust(5) + "\n"
		puts "-" * 61
		restaurants.each do |rest|
			line = " " << rest.name.titleize.ljust(30)
			line << " " + rest.cuisine.titleize.ljust(20)
			line << " " + rest.formatted_price.rjust(6)
			puts line
		end
		puts "No listing found" if restaurants.empty?
		puts "-" * 61
	end

end

	
