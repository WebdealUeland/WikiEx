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
end
