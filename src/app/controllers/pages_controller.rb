class PagesController < PluginCore
  unloadable;

  def view
	@path = getPage()
	@page = Page.find(:first, :conditions => ["url=?", @path])
  end

  def edit
        @path = getPage(true)
        @page = Page.find(:first, :conditions => ["url=?", @path])
	@page['content'] = fromWikiCode(@page['content'])
  end

  def save
	path = getPage(true, true)
	@page = Page.find(:first, :conditions => ["url=?", path])
	if(@page.nil?)
		@page = Page.new()
	end
	@page['content'] = toWikiCode(params['text'])
	@page['url']  = path.to_s
	@page.save
	#raise YAML::dump @page
	redirect_to path.to_s
  end
end
