module Stockroll
	class Service
		include Singleton
		def initialize
		end

		def create(code)
			@code = code
			rt = nil
			case code
				when /^sh[\d]+|^sz[\d]+/i
					rt = ChinaStock.instance
				else
					rt = USStock.instance
			end
			rt
		end
		def 
		def generate_url

		end
		def process_result(res)

		end
	end
	
	class ChinaStock < Service

	end
	class USStock < Service

	end

end
