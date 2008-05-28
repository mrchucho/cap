require 'merb-freezer'
Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")
# If you want modules and classes from libraries organized like
# merbapp/lib/magicwand/lib/magicwand.rb to autoload,
# uncomment this.
# Merb.push_path(:lib, Merb.root / "lib") # uses **/*.rb as path glob.
# ==== Dependencies
dependencies %w(open-uri cgi hpricot tzinfo)
dependency "merb-action-args"
# dependency "merb-assets"
# dependency "merb-parts"
# dependency "merb-assets"
Merb::BootLoader.after_app_loads do
  # Add dependencies here that must load after the application loads:
  # dependency "magic_admin" # this gem uses the app's model classes
end
#
# ==== Set up your ORM of choice
# use_orm :datamapper
# use_orm :activerecord
# use_orm :sequel
#
# ==== Pick what you test with
# use_test :test_unit
# use_test :rspec
#
# ==== Set up your basic configuration
#
Merb::Config.use do |c|
  # Sets up a custom session id key, if you want to piggyback sessions of other applications
  # with the cookie session store. If not specified, defaults to '_session_id'.
  # c[:session_id_key] = '_session_id'

  c[:session_secret_key]  = 'd56b9caa3e5159bcae8776500f298082e111d9c3'
  c[:session_store] = 'cookie'
end

# Merb.add_mime_type :rss, nil, %w[text/xml]
