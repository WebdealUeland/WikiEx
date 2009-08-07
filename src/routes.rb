ActionController::Routing::Routes.draw do |map|
    map.connect '/wikiex/*path/edit', :controller => 'editpages', :action => 'view'
    map.connect '/wikiex/*path', :controller => 'pages', :action => 'view'
end
