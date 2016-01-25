module ApplicationHelper
	def lesc(text)
	  LatexToPdf.escape_latex(text)
	end
	
	# set R_HOME if not set
	  if ENV['R_HOME'].nil?
	    ENV['R_HOME'] = "/usr/lib/R"
	  end
end
