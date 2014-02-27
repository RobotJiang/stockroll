# run rspec 
require "spec_helper"
require 'stockroll/commands'
require 'stockroll/utils'

describe Stockroll do

	it 'stock code is valid' do 
		Stockroll::Utils.is_valid_stock_code('shabc').should == false
		Stockroll::Utils.is_valid_stock_code('sz000100').should == true
	end
	describe "Stock Config Operation" do
		path = Stockroll::Commands::CONF_FILE_PATH
		before(:each) do
			File.open(path,'w'){|f| f.write('')} if File.exists?(path)
		end
		it 'read and write stock code is fine' do
			cmd = Stockroll::Commands.new
			cmd.send :add_codes, "sz001"
			cmd.send :add_codes, "sz001,sz002"
			cmd.send :add_codes, "sz003"
			(cmd.send :get_stock_codes).should == "sz001,sz002,sz003"
		end
		it 'remove stock code is fine' do
			cmd = Stockroll::Commands.new
			cmd.send :add_codes, "sz001"
			cmd.send :add_codes, "sz001,sz002"
			cmd.send :remove_code, "sz002"
			(cmd.send :get_stock_codes).should == "sz001"
		end
		after(:each) do
			File.open(path,'w'){|f| f.write('')} if File.exists?(path)
		end
	end

end
