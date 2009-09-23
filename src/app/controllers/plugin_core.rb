class PluginCore < ApplicationController
	unloadable

	#Figures out project name based on URL
	def getProjectName()
		src = getPage()
		if(src.include? "/project/")
			tmp = src.split("/")
			#Fix redirect to make shure we are in right virtual folder for project	
			if(src.ends_with?("/") == false && src.ends_with?("save") == false)
				redirect_to getPage()+"/"
			end
			
			arrayElem =  tmp.size - 1
			return tmp[arrayElem]
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
		
		str = str.gsub("//", "/")

		return str
	end


	#Converts Wiki code to HTML
	def toWikiCode(orig)
                #Construct Table Of Contents
		chapters = "<div id='listOfContents' class='contextual'><b>Table of contents</b><ul>"
                chapTmp = orig.scan(/<h1>(.*?)<\/h1>/)
		i = 0
		chapTmp.each do |c|
			c = c[0]
			i += 1
			chapters += "<li><a href=\"#"+i.to_s+"\">"+c+"</a></li>\n"
		end
		chapters += "</div>";


 		h1tmp = orig.scan(/<h1>(.*?)<\/h1>/)
                i = 0
                h1tmp.each do |c|
			i = i+1
			c = c[0]
			orig = orig.gsub("<h1>"+c+"<\/h1>", '<a name='+i.to_s+'></a><h1>'+c+'</h1><input type="button" value="Edit chapter" style="float:right" onclick="window.location=window.location+\'/edit?chapter='+i.to_s+'\'" />')
		end
		

		#Add table of contents
		str = "<!-- |TOC|--> "+chapters+"  <!-- /|TOC| --> "+orig

		#raise YAML::dump(str)
		return str
	end
end
