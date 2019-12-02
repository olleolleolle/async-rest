# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'json'
require_relative 'url_encoded'

module Async
	module REST
		module Wrapper
			class Form < Generic
				DEFAULT_CONTENT_TYPES = {
					JSON::APPLICATION_JSON => JSON::Parser,
					URLEncoded::APPLICATION_FORM_URLENCODED => URLEncoded::Parser,
				}
				
				def initialize(content_types = DEFAULT_CONTENT_TYPES)
					@content_types = content_types
				end
				
				def prepare_request(payload, headers)
					headers['accept'] ||= @content_types.keys
					
					if payload
						headers['content-type'] = URLEncoded::APPLICATION_FORM_URLENCODED
						
						::Protocol::HTTP::Body::Buffered.new([
							::Protocol::HTTP::URL.encode(payload)
						])
					end
				end
				
				def parser_for(response)
					if content_type = response.headers['content-type']
						return @content_types[content_type]
					end
				end
				
				def process_response(request, response)
					if body = response.body
						if parser = parser_for(response)
							wrap_response(response, parser)
						else
							raise Error, "Unsupported content type: #{content_type}!"
						end
					end
					
					return response
				end
			end
		end
	end
end
