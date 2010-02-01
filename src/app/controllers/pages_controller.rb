class PagesController < PluginCore
  unloadable;
  require 'date'
  before_filter :find_project

  # View wiki page
  def view
	@path = getPage()
	@page = Page.find(:first, :conditions => ["url=?", @path])

	if(@page.nil? == false)
		if(@page.url.ends_with?("/") == false)
			url = @page.url+"/"
		else
			url = @page.url
		end	
		@subPages = Page.find(:all, :conditions => ["url LIKE '#{url}%%' AND URL !='#{url}'"], :order => ["title ASC"])
	end
  end

  # Edit wiki page
  def edit
	@hasChapter = 0
	@chapID = 0
        @path = getPage(true)
        @page = Page.find(:first, :conditions => ["url=?", @path])
	if(@page.nil? == false)
		@versions = Revision.find(:all, :conditions => ["pageid=?", @page.id], :limit => 25, :order => "id DESC")

		#Make shure version number is set	
		if(!@page['version']) 
			@page['version'] = 1
		end

	end

	#Load a spesific chapter?
        if(params[:chapter].nil? == false)
                @chapID = params[:chapter].to_i
		chContent = @page['original']+"<h1></h1>" #Hack, ugh
		chk = chContent.scan(/<\/h1>(.*?)<h1>/m)
		@page['original'] = chk[(@chapID -1)]
		@hasChapter = 1
	end

	#Load a spesific version?
	if(params['showversion'])
		@oldVersion = Revision.find(:first, :conditions => ["id=?", params['showversion']])
	end
  end

  #Save wiki page
  def save
	@user = User.find_by_id(session[:user_id])	
	path = getPage(true, true)
	@page = Page.find(:first, :conditions => ["url=?", path])
	if(@page.nil?)
		@page = Page.new()
	else
		#Save old page content to revision list before we convert it
		#pageid:integer, version:integer, title:string, content:text, when:date, author:string	
		@rev = Revision.new()
		@rev['pageid']  = @page['id']
		@rev['version'] = @page['version']
		@rev['title']   = @page['title']
		@rev['content'] = @page['original']
		@rev['when']    = Date.today
		if(@user.nil?)
			@rev['author']  = "N/A"
		else
			@rev['author']  = @user['firstname']+" "+@user['lastname']
		end

		#Doublecheck version for new pages
		if(!@rev['version'])
			@rev['version'] = 1
		end
		@rev.save()
	end

	#chapter magic
	if(params['chapter'].to_i > 0)
		chap = params['text']
		text = @page['original']

		newText = ""
		tmp = text.split(/<h1>/)
		counter = 0
		tmp.each do |c|
			if(counter == params['chapter'].to_i)
				title = c.split(/<\/h1>/)
				newText += "\n<h1>"+title[0]+"</h1>\n"+chap
			else
				if(counter > 0)	
					newText += "\n<h1>"+c
				else
					newText += c	
				end
			end
			counter += 1
		end
		params['text'] = newText
	end

	@page['content'] = toWikiCode(params['text']+"\r\r")
	@page['original'] = params['text'];
	if(params['chapter'].to_i == 0)
		@page['title'] = params['title']
	end
	@page['url']  = path.to_s
	if(@page['version'])
		@page['version'] += 1
	else 
		@page['version'] = 1
	end
	@page.save

	#raise YAML::dump @page
	redirect_to path.to_s
  end

private
  
  #Find a project based on project name
  def find_project
    @project = Project.first(:conditions => ["identifier = ?",getProjectName() ])
      rescue ActiveRecord::RecordNotFound
	#do nothing
  end
end
