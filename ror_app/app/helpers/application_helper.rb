module ApplicationHelper
	def lesc(text)
	  LatexToPdf.escape_latex(text)
	end
	
	# set R_HOME if not set
	  if ENV['R_HOME'].nil?
	    ENV['R_HOME'] = "/usr/lib/R"
	  end

	def ding_to_html(ding, link_options={}, html_options={}, &block)
		with_symbol = link_options.has_key?(:with_symbol) ? link_options[:with_symbol] : true
		only_list_items = link_options.has_key?(:only_list_items) ? link_options[:only_list_items] : false
		as_link = link_options.has_key?(:as_link) ? link_options[:as_link] : true
		button_classes = link_options.has_key?(:button_classes) ? link_options[:button_classes] : "btn btn-default btn-ding"
		badge_text = link_options[:badge_text] || nil
		badge_icon = link_options[:badge_icon] || nil

		link_text = "".html_safe

		if button_classes
			link_text += ("<button class=\"" + button_classes + "\" type=\"button\" title=\"" + (h(ding.name) || "") + "\">").html_safe
		end
		if not only_list_items
			link_text += "<ul class=\"list-inline\">".html_safe
		end

		if with_symbol
			link_text += ("<li>" + fa_icon(ding.get_symbol) + "</li>").html_safe
		end

		#link_text += "<b>".html_safe

		if ding.published
			name = ding.name || ""
			name = name.truncate(25)
		else
			name = ding.name || ""
			name = ("<i>" + (name.truncate(25) || "") + "</i>")
		end

		#link_text += "</b>".html_safe

		link_text += ("<li>" + name + "</li>").html_safe

		if badge_text
			badge = "<li><span class=\"badge\">" + badge_text + " "

			if badge_icon
				badge += fa_icon(badge_icon)
			end
			badge += "</span></li>"
			link_text += badge.html_safe
		end

		if not only_list_items
			link_text += "</ul>".html_safe
		end

		if button_classes
			link_text += "</button>".html_safe
		end

		if as_link
			return (link_to ding_path(ding), html_options do
			#return "<a href=\"" + ding_path(ding) + "\">" + link_text + "</a>"
				link_text
			end)
		else
			return link_text
		end
	end



	def assoziation_to_html(assoziation, link_options={}, html_options={}, &block)
		with_ding_symbol = link_options[:with_ding_symbol] || true
		button_classes = link_options.has_key?(:button_classes) ? link_options[:button_classes] : "btn btn-success btn-assoziation"
		badge_text = link_options[:badge_text] || nil
		badge_icon = link_options[:badge_icon] || nil
		redirect_to = link_options.has_key?(:redirect_to) ? link_options[:redirect_to] : ""
		#show_add_remove_button = 

		ding_params = {
			with_symbol: with_ding_symbol,
			as_link: (button_classes.nil?),
			only_list_items: (not button_classes.nil?)}

		if button_classes
			ding_params[:button_classes] = nil
		end

		ding_eins_link = ding_to_html(assoziation.ding_eins, ding_params)
		ding_zwei_link = ding_to_html(assoziation.ding_zwei, ding_params)

		link_text = "".html_safe

		if button_classes
			link_text += ("<button class=\"" + button_classes + "\" type=\"button\">").html_safe
		end

		link_text += "<ul class=\"list-inline\">".html_safe
		link_text += ("<li><span class=\"text-responsive\">" + ding_eins_link + "</span></li>").html_safe

		
		if button_classes
			link_text += ("<li>" + fa_icon("long-arrow-right") + "</li>").html_safe
		else
			link_text += ("<li>" + (link_to assoziation_path(assoziation), html_options do
				fa_icon("long-arrow-right")
			end) + "</li>").html_safe
		end

		link_text += ("<li>" + ding_zwei_link + "</li>").html_safe
		if badge_text
			link_text += ("<li>" + badge(badge_text.html_safe, :warning) + "</li>").html_safe
		end

		user_has_ass = UserAssoziation.where(:user_id => current_user.id).where(:assoziation_id => assoziation.id).count > 0
		if user_has_ass
        	link = url_for(:controller => 'assoziations', :action => "remove_for_current_user", :assoziation_id => assoziation.id, :redirect_to => redirect_to)
        	user_add_remove_link = "<a href=\"" + link + "\">" + fa_icon(:minus) + "</a>"
        else
        	link = url_for(:controller => 'assoziations', :action => "create_for_current_user", :assoziation_id => assoziation.id, :redirect_to => redirect_to)
        	user_add_remove_link = "<a href=\"" + link + "\">" + fa_icon(:plus) + "</a>"
        end
        if not button_classes
        	link_text += ("<li>" + user_add_remove_link + "</li>").html_safe
        end
		link_text += "</ul>".html_safe

		if button_classes
			link_text += "</button>".html_safe
			link_text += user_add_remove_link.html_safe
		end

        if button_classes
			return link_to assoziation_path(assoziation), html_options do
				link_text
			end
		else
			link_text
		end
	end
end
