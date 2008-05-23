#   r.match("/contact").
#     to(:controller => "info", :action => "contact")
#   r.match("/books/:book_id/:action").
#     to(:controller => "books")
#   r.match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#   r.match("/sleep/:time).
#     to(:controller => "sleeper",:action => "execute").
#     name(:sleeper) # a named route
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  # r.resources :alerts
  # r.default_routes # default route for /:controller/:action/:id
  r.match(%r'/(\w{2})/(.+$)').to(:controller => 'Alerts',:action => 'show', :where => '[2],[1]')
  r.match(%r'/(.+$)').to(:controller => 'Alerts',:action => 'show', :where => '[1]')
  r.match('/').to(:controller => 'Alerts', :action =>'index')
end
