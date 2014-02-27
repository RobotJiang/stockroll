
require 'net/http'
require 'colorize'
require 'em-http-request'
require "curses"

include Curses

module Stockroll 
	class Utils
		ROOT_URL = "http://hq.sinajs.cn/list="
		class << self
			def is_valid_stock_code(code)
				uri = URI("#{ROOT_URL}#{code}")
				res = Net::HTTP.get(uri).force_encoding("GBK").encode("UTF-8")
				val = res.split('=')[1]
				if val =~ /([^\"\n;]+)/
					if !$1.nil? and $1.strip.size > 0
						true
					else
						false
					end
				else
					false
				end
			end
			def run(codes)
				codes = codes.split(',')	
				Curses.noecho
				Curses.init_screen
				Curses.start_color
				Curses.init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)
				Curses.init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK)
				Curses.init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
				Curses.init_pair(COLOR_YELLOW,COLOR_YELLOW,COLOR_BLACK)
				47.times do |i|
					Curses.setpos(0,i)
					Curses.addstr('#')
				end
				curs_set(0)
				Curses.setpos(1,0)
				Curses.addstr('Loading...')

				another_th = Thread.new {
					EventMachine.run do

						do_work = proc{

							codes.each_with_index do |code,index| 
								http = EventMachine::HttpRequest.new("#{ROOT_URL}#{code}").get
								http.errback { p 'Uh oh'; }
								http.callback {
									res = http.response.encode('utf-8')
									val = res.split('=')[1]
									if val =~ /([^\"\n;]+)/
										captures = $1
										if index == 0
											ypos = 1
										else
											ypos = (index * 2) + 1
										end
										
										if captures.strip != ''
											ar = captures.split(',')
											Curses.setpos(ypos,0)
											Curses.attron(A_BOLD|A_UNDERLINE) {
												Curses.addstr(ar[0])
												clrtoeol() #clear line	
											}

											Curses.setpos(ypos,11)
											Curses.attron(A_NORMAL|A_DIM) {
												Curses.addstr(code)
											}

											Curses.setpos(ypos,22)
											Curses.attron(A_NORMAL) {
												Curses.addstr(ar[3])
											}

											Curses.setpos(ypos,32)
											if ar[3].to_f == 0
												diff = 0.00
											else
												diff = (ar[3].to_f - ar[2].to_f).round(2)
											end
											prefix = ' '
											if diff >= 0
												if diff == 0
													Curses.attron(A_BOLD) {
														Curses.addstr("#{prefix}#{diff.abs}")
														Curses.addstr("   ")
														Curses.addstr("0.00%")
														
													}
												else
													prefix = '+'
													Curses.attron(color_pair(COLOR_RED)|A_BOLD) {
														Curses.addstr("#{prefix}#{diff.abs}")
														Curses.addstr("   ")
														Curses.addstr("#{prefix}#{((diff.abs/ar[2].to_f)*100).round(2)}%")
														
													}
												end
											else
												prefix = '-'
												Curses.attron(color_pair(COLOR_GREEN)|A_BOLD) {
														Curses.addstr("#{prefix}#{diff.abs}")
														Curses.addstr("   ")
														Curses.addstr("#{prefix}#{((diff.abs/ar[2].to_f)*100).round(2)}%")
												}
											end
											Curses.refresh
										end
										
									end

								}
							end
						}

						EM::PeriodicTimer.new(10) do
							do_work.call()
						end
						do_work.call()

					end

				}
				while TRUE
					c = getch
					case c
						when /q/i
							another_th.exit()
							Curses.close_screen
							exit(0)

					end
				end
			end
		end
	end
end
