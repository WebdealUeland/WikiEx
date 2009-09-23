class PluginCore < ApplicationController
	unloadable

	#Figures out project name based on URL
	def getProjectName()
		src = getPage()
		if(src.include? "/project/")
			tmp = src.split("/")
			#Fix redirect to make shure we are in right virtual folder for project	
			if(src.ends_with?("/") == false && src.ends_with?("save") == false && src.ends_with?("edit") == false)
				redirect_to getPage()+"/"
			end
			
			arrayElem =  -1
			i = 0
			tmp.each do |c|
				if(c == 'project')
					arrayElem = (i +1)
				end
				i +=1
			end
			
			return tmp[arrayElem]
		else
			return ""
		end
	end


 	#Returns page URL
	def getPage(skipEdit=false, skipSave=false)
		str = request.request_uri
		if(skipEdit && str.include? "/edit")
			
			str['/edit'] = ""
		end
		if(skipSave && str.include? "/save")
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
		parsed = ""
                #Construct Table Of Contents
		chapters = "<div id='listOfContents' class='contextual'><b>Table of contents</b><br />"
                #chapTmp = orig.scan(/<h1>(.*?)<\/h1>/)
		tmp = orig.split("\n")
		url = getPage(true,true)
		h1 = 0
		h2 = 0
		h3 = 0
		tmp.each do |a|
			
			#Look for h1
			if(a.include?("<h1>"))
				h1 += 1

				a = '<a name="'+h1.to_s+'.'+h2.to_s+'.'+h3.to_s+'"></a>' + a
				a = '<div style="float:right"><a href="'+url+'/edit?chapter='+h1.to_s+'">Edit</a></div>' + a

				#Get chapter name
				chapTmp = a.split("<h1>")
				chapter = chapTmp[1].split("</h1>").first
				chapters = chapters + '<br /><a href="#'+h1.to_s+'.'+h2.to_s+'.'+h3.to_s+'">'+chapter+'</a><br />'
			end

			if(a.include?("<h2>"))
				h2 += 1

				a = '<a name="'+h1.to_s+'.'+h2.to_s+'.'+h3.to_s+'"></a>' + a
				a = '<!-- <div style="float:right"><a href="'+url+'/edit?chapter='+h1.to_s+'&h2='+h2.to_s+'">Edit</a></div> --> ' + a

				#Get chapter name
				chapTmp = a.split("<h2>")
				chapter = chapTmp[1].split("</h2>").first
				chapters = chapters + '|-- <a href="#'+h1.to_s+'.'+h2.to_s+'.'+h3.to_s+'">'+chapter+'</a><br />'
			end

			if(a.include?("<h3>"))
				h3 += 1
				
				a = '<a name="'+h1.to_s+'.'+h2.to_s+'.'+h3.to_s+'"></a>' + a
				a = '<!-- <div style="float:right"><a href="'+url+'/edit?chapter='+h1.to_s+'&h2='+h2.to_s+'&h3='+h3.to_s+'">Edit</a></div> --> ' + a

				#Get chapter name
				chapTmp = a.split("<h3>")
				chapter = chapTmp[1].split("</h3>").first
				chapters = chapters + '|--- <a href="#'+h1.to_s+'.'+h2.to_s+'.'+h3.to_s+'">'+chapter+'</a><br />'
			end
			
			parsed += a
		end

		chapters = chapters + "</div>"

		parsed = chapters + parsed

		return parsed
	end
end
