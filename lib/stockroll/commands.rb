require "thor"
require 'find'
require 'erb'
require 'colorize'
require 'stockroll/utils'

module Stockroll 
	class Commands < Thor
		include Thor::Actions
		CONF_FILE_PATH = File.expand_path("~/.stock_roll_codes_config",__FILE__)

		desc "start", "start stock roll"
		def start
			codes = self.get_stock_codes
			if codes.nil? or codes.strip.size == 0
				isOk, cs = self.init_config
				Stockroll::Utils.run(cs) if isOk
			else
				Stockroll::Utils.run(codes)
			end
		end

		desc "add", "add a stock code, if you want add multiple CODE please separated by commas."
		def add(codes)
			is_valid , err_msg = self.check_codes(codes)
			if is_valid
				self.add_codes(codes)
				puts "Info: add code successfully.".yellow
			else
				err_msg.each do |msg|
					puts msg.red
				end
			end
		end

		desc "delete", "delete a stock code"
		def delete(code)
			self.remove_code(code)
			puts "Info: delete is ok.".yellow
		end

		desc "clear", "clear all stock codes"
		def clear()
			self.remove_all_codes()
			puts "Info: clear all codes is successed.".yellow
		end

		default_task :start

		protected
		def get_stock_codes
			return nil unless File.exists?(CONF_FILE_PATH)
			return IO.read(CONF_FILE_PATH)
		end
		def add_codes(codes)
			raise 'Please input stock codes.' if codes.nil? or codes.strip.size == 0
			codes = codes.gsub(/(^\s+)|(\s+$)/,'')
			unless File.exists?(CONF_FILE_PATH)
				File.open(CONF_FILE_PATH,'w') do |f|
					f.write(codes)
				end
			else
				content = self.get_stock_codes
				if content.nil? or content.strip.size == 0
					File.open(CONF_FILE_PATH,'w') do |f|
						f.write(codes)
					end
				else
					old_codes = content.split(',')
					added_codes = codes.split(',')
					new_codes = old_codes.concat(added_codes).uniq
					File.open(CONF_FILE_PATH,'w') do |f|
						f.write(new_codes.join(','))
					end
				end
				
			end
		end
		def remove_code(code)
			old_codes = self.get_stock_codes
			unless old_codes.nil?
				n = []
				old_codes.split(',').each do |c|
					if c.strip != code.strip
						n << c
					end
				end
				File.open(CONF_FILE_PATH,'w') do |f|
					f.write(n.join(','))
				end
			end
		end
		def remove_all_codes()
			File.open(CONF_FILE_PATH,'w') do |f|
				f.write('')
			end
		end
		def check_codes(codes)
			is_valid = true
			err_msg = []
			c_a = codes.split(',')
			c_a.each do |c|
				unless Stockroll::Utils.is_valid_stock_code(c)
					err_msg << "Error: invalid stock code: #{c}"
					is_valid = false
				end
			end
			[is_valid, err_msg]
		end
		def init_config
			print "Please input your stock codes: ".yellow
			cs = gets.chomp
			is_valid, err_msg = self.check_codes(cs)
			unless is_valid
				err_msg.each do |msg|
					puts msg.red
				end
				[false, '']
			else
				self.add_codes(cs)
				[true, cs]
			end
		end
	end

end
