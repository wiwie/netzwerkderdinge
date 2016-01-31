class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :init_r
 
	def set_locale
	  I18n.locale = params[:locale] || I18n.default_locale
	end

	def default_url_options(options = {})
	  { locale: I18n.locale }.merge options
	end

	def init_r
		# TODO: huge segfault problems
	    #require 'rsruby'
	    #@@r = RSRuby.instance
	    #r_cmd = 'myplot = function(filename, r_text) {png(filename = filename);eval(parse(text=r_text));dev.off();};'
	    #puts r_cmd
	    #@@r.eval_R(r_cmd)
	end
end
