namespace 'public' do
	desc 'Make .css.css files into .css files'
	task :css_css do
		Dir.glob('public/blog/css/*.css.css').each do |file|
			puts `mv #{file} #{file.gsub(/\.css\.css$/, '.css')}`
		end
	end
end