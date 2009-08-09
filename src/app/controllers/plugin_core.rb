class PluginCore < ApplicationController
	unloadable

	def getPage(skipEdit=false, skipSave=false)
		str = request.request_uri
		if(skipEdit)
			str['/edit'] = ""
		end
		if(skipSave)
			str['/save'] = ""
		end
		#str['/wikiex'] = ""
		return str
	end

	def toWikiCode(orig)

		str = ""
		
		#Table(s)
		inTable = 0
		inTh = 0
		inTr = 0
		inTd = 0
		lineBreaks = 0
		tmp = orig.scan(/./)
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
					str += "<table class='inline'>\n"
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
							str+= "\t<tr>"
						end
						inTh = 1
					end
					str += "\n\t\t<th>"
				end
				if(c == "|")

					if(inTable == 0)
						str +="<table border='1' width='1'>\n"
					end
					if(inTh == 1 && inTr == 1)
						str += "\t\t</th>"
						inTh = 0
					end
					if(inTr == 0)
						str += "\t<tr>"
						inTr = 1
					end
					if(inTd == 0)
						str += "\n\t\t<td>"
						inTd = 1
					end
					if(inTd == 1)
						str += "</td>\n\t\t<td>"
					end
				end
			else
				if(inTh == 1 && lineBreaks > 0)
					str += "</th>"
					inTh = 0
				end
				if(inTd == 1 && lineBreaks > 0)
					str += "</td>\n"
					inTd = 0
				end
				if(inTr == 1 && lineBreaks > 0)
					str += "\n\t</tr>"
					inTr = 0
				end
				if(inTable == 1 && lineBreaks > 1)
					str += "</table>"
					inTable = 0	
				end
				str += c
			end
		end

		#table cleanup(TODO: Remove this)
		str = str.gsub("<td></td>", "")
		str = str.gsub("<td> </td>", "")
		str = str.gsub("<th>\r\t\t</th>", "")

                #Line breaks
                str = str.gsub("\r", "<br />")


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

	def fromWikiCode(str)

		#remove autoformated newlines
		str = str.gsub("\n", "")

		#br
		str = str.gsub("<br />", "\n")
		str = str.gsub("\t", "")

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
