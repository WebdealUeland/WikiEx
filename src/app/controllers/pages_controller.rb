class PagesController < PluginCore
  unloadable;

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
	end
	@page['content'] = toWikiCode(params['text'])
	@page['title'] = params['title']
	@page['url']  = path.to_s
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
