class PagesController < PluginCore
  unloadable;
  require 'date'
  before_filter :find_project

  def view
	@path = getPage()
	@page = Page.find(:first, :conditions => ["url=?", @path])
  end

  def edit
        @path = getPage(true)
        @page = Page.find(:first, :conditions => ["url=?", @path])
	if(@page.nil? == false)
		@page['content'] = fromWikiCode(@page['content'])
	end
  end

  def save
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
		@rev['content'] = @page['content']
		@rev['when']    = Date.new
		@rev['author']  = "n/a"
		@rev.save()
	end
	@page['content'] = toWikiCode(params['text'])
	@page['title'] = params['title']
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
