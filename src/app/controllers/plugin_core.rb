class PluginCore < ApplicationController
	unloadable

	#Figures out project name based on URL
	def getProjectName()
		src = getPage()
		if(src.include? "/project/")
			tmp = src.split("/")
		
			#Fix redirect to make shure we are in right virtual folder for project	
			if(tmp.size == 4 && src.ends_with?("/") == false)
				redirect_to getPage()+"/"
			end
			return tmp[3]
		else
			return ""
		end
	end


 	#Returns page URL
	def getPage(skipEdit=false, skipSave=false)
		str = request.request_uri
		if(skipEdit)
			str['/edit'] = ""
		end
		if(skipSave)
			str['/save'] = ""
		end
	
		#Make shure any params are not dragged along
		if(str.include? "?")
			tmp = str.split("?")
			str = tmp[0]
		end

		return str
	end


	#Converts Wiki code to HTML
	def toWikiCode(orig)

		# Force a bit of air in bottom of pages
		orig = orig+"\r\r"

		# Remove strange newlines and tab characters
		orig = orig.split(/\n+/).join("\n")
		orig = orig.gsub("\t", "  ")

		#Remove other naughty characters
                orig = orig.gsub("<", "&lt;")
                orig = orig.gsub(">", "&gt;")


		afterNoWiki = ""
		tmp = orig.split("\n")
		inDiv = 0
		tmp.each do |d|
			if(d[0,2] == "  ")
				if(inDiv == 0)
					inDiv = 1
					afterNoWiki += '<div class="nowiki">'
				end
				parsed = d
				parsed = parsed.gsub(" ", "&nbsp;")
				parsed = parsed.gsub("*", "&#42;")
				parsed = parsed.gsub("/", "&#47;")
				parsed = parsed.gsub("_", "&#95;")
				afterNoWiki += parsed
			else
				if(inDiv == 1)
					inDiv = 0
					afterNoWiki += "</div>"
				end
				afterNoWiki += d
			end
		end

		#Convert links with spesific title
                afterNoWiki = afterNoWiki.gsub(/\[\[(.*?)\|(.*?)\]\]/, '<a class="advanced" href="\1">\2</a>')	

		#Convert links to href`s
		afterNoWiki = afterNoWiki.gsub(/\[\[(.*?)\]\]/, '<a class="simple" href="\1">\1</a>')

		str = ""
		
		#Table(s)
		inTable = 0
		inTh = 0
		inTr = 0
		inTd = 0
		lineBreaks = 0
		tmp = afterNoWiki.scan(/./)
		tmp.each do |c|

			#wait for line break
			if(c == "\r")
				lineBreaks += 1
			else
				lineBreaks = 0
			end

			if(c == "^" || c == "|")
				if(inTable == 0)
					inTable = 1
					str += "<table class='inline'>"
				end
				if(c == "^")
					if(inTd == 1)
						str+= "&nbsp;</td>"
						inTd = 0
					end
					if(inTh == 1)
						str+= "</th>"
					else 
						if(inTr == 0)
							inTr = 1
							str+= "<tr>"
						end
						inTh = 1
					end
					str += "<th>"
				end
				if(c == "|")

					if(inTable == 0)
						str +="<table border='1' width='1'>"
					end
					if(inTh == 1 && inTr == 1)
						str += "</th>"
						inTh = 0
					end
					if(inTr == 0)
						str += "<tr>"
						inTr = 1
					end
					if(inTd == 0)
						str += "<td>"
						inTd = 1
					end
					if(inTd == 1)
						str += "</td><td>"
					end
				end
			else
				if(inTh == 1 && lineBreaks > 0)
					str += "</th>"
					inTh = 0
				end
				if(inTd == 1 && lineBreaks > 0)
					str += "</td>"
					inTd = 0
				end
				if(inTr == 1 && lineBreaks > 0)
					str += "</tr>"
					inTr = 0
				end
				if(inTable == 1 && lineBreaks > 1)
					str += "</table>"
					inTable = 0	
				end
                                if(inTh == 1 || inTd == 1 || inTr == 1 || inTable == 1)
                                        str += c
                                else
                                        str += c.gsub("\r", "<br />")
                                end

			end
		end

		#table cleanup(TODO: Remove this)
		str = str.gsub("<td></td>", "")
		str = str.gsub("<td> </td>", "")
		str = str.gsub("<th>\r\t\t</th>", "")
		str = str.gsub("<th></th>", "")


		#bold/italic/underline
		str = str.gsub(/\*\*(.*?)\*\*/, '<b>\1</b>')
		str = str.gsub(/\/\/(.*?)\/\//, '<i>\\1</i>')
		str = str.gsub(/__(.*?)__/, '<u>\\1</u>')


		#Hn
		str = str.gsub(/======(.*?)======/, '<h1>\1</h1>')
		str = str.gsub(/=====(.*?)=====/, '<h2>\1</h2>')
		str = str.gsub(/====(.*?)====/, '<h3>\1</h3>')
		#raise YAML::dump(str)
		return str
	end


	# Converts from HTML to wiki code
	# (And yes, the function names is mirrored for some reason...)
	def fromWikiCode(str)

		#remove autoformated newlines
		str = str.gsub("\n", "")
		str = str.gsub("\t", "  ")
		str = str.gsub("&nbsp;", " ")

		#Remove nowiki code snippets
		str = str.gsub(/<div class="nowiki">(.*?)<\/div>/, '\1')

		#br
		str = str.gsub("<br />", "\n")
		str = str.gsub("\t", "")

		#Links
		str = str.gsub(/<a class="advanced" href="(.*?)">(.*?)<\/a>/, '[[\1|\2]]')
		str = str.gsub(/<a class="simple" href="(.*?)">(.*?)<\/a>/, '[[\1]]')

		#Table
		str = str.gsub(/<table(.*?)>/, "")
		str = str.gsub("</td></tr>", "|")
		str = str.gsub(/<tr>/, "")
		str = str.gsub("</tr>", "")
		str = str.gsub("<th>", "^")
		str = str.gsub("</th>", "")
		str = str.gsub("<td>", "|")
		str = str.gsub("</td>", "")
		str = str.gsub("</table>", "")
			
	
		#bold/italic/underline
		str = str.gsub(/<b>(.*?)<\/b>/, '**\1**')
		str = str.gsub(/<i>(.*?)<\/i>/, '//\1//')
		str = str.gsub(/<u>(.*?)<\/u>/, '__\1__')

		#Hn
		str = str.gsub(/<h1>(.*?)<\/h1>/, '======\1======')
		str = str.gsub(/<h2>(.*?)<\/h2>/, '=====\1=====')
		str = str.gsub(/<h3>(.*?)<\/h3>/, '====\1====')

		return str
	end
end
