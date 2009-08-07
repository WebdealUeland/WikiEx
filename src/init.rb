require 'redmine'

Redmine::Plugin.register :redmine_wikiex do
  name 'Wiki Ex(tended) plugin'
  author 'Tor Henning Ueland - Webdeal AS'
  description 'This is a extended wiki plugin'
  version '0.0.1'

  menu :application_menu, :polls, { :controller => 'wikiex', :action => 'pages' }, :caption => 'Wiki Extended'
  menu :project_menu, :polls, { :controller => 'wikiex', :action => 'pages' }, :caption => 'Wiki Extended'
  menu :top_menu, :polls, { :controller => 'wikiex', :action => 'pages' }, :caption => 'Wiki Extended'
end
