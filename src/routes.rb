ActionController::Routing::Routes.draw do |map|
    map.connect '/wikiex/*path/edit', :controller => 'pages', :action => 'edit'
    map.connect '/wikiex/*path/edit/save', :controller => 'pages', :action => 'save'
    map.connect '/wikiex/*path', :controller => 'pages', :action => 'view'
end
