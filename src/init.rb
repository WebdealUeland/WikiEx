require 'redmine'

Redmine::Plugin.register :redmine_wikiex do
  name 'Wiki Ex(tended) plugin'
  author 'Tor Henning Ueland - Webdeal AS'
  description 'This is a extended wiki plugin'
  version '0.0.1'

  #menu :application_menu, :wikiex, { :controller => 'wikiex', :action => 'frontpage' }, :caption => 'Wiki Extended'
  #permission :wikiex, {:wikiex => [:index, :edit]}, :public => true
  #menu :project_menu, :wikiex, { :controller => 'wikiex', :action => 'pages' }, :caption => 'Wiki Extended', :after => :activity, :param => :project_id
  menu :top_menu, :wikiex, { :controller => 'wikiex', :action => 'frontpage' }, :caption => 'Wiki Extended'

  project_module :wikiex_module do
    permission :view, {:wikiex => [:show, :project]}
    permission :edit, {:wikiex => [:edit, :update, :new, :create, :destroy]}
  end
 
  menu :project_menu, :wikiex, {:controller => 'wikiex', :action => 'project'}, :caption => "Wiki Extended"

end
