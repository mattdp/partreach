module RakeHelper
	include SessionsHelper

	#drawn from http://engineering.nulogy.com/posts/automatically-scaling-heroku-workers/

	def scale_workers(num)
		heroku = get_heroku
		heroku.post_ps_scale(app_name, 'worker', num)
	end

	def count_workers
		heroku = get_heroku
		workers = heroku.get_ps(app_name).body.select { |ps| ps["process"] =~ /worker/ }
		return workers.size
	end

	def get_heroku
		return Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
	end
end