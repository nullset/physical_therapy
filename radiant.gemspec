# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{radiant}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Radiant CMS dev team"]
  s.date = %q{2009-10-19}
  s.description = %q{Radiant is a simple and powerful publishing system designed for small teams.
It is built with Rails and is similar to Textpattern or MovableType, but is
a general purpose content managment system--not merely a blogging engine.}
  s.email = %q{radiant@radiantcms.org}
  s.extra_rdoc_files = ["README", "CONTRIBUTORS", "CHANGELOG", "INSTALL", "LICENSE"]
  s.files = ["CHANGELOG", "config", "config/boot.rb", "config/environment.rb", "config/environments", "config/environments/development.rb", "config/environments/production.rb", "config/environments/test.rb", "config/routes.rb", "CONTRIBUTORS", "db", "db/db_production", "db/schema.rb", "INSTALL", "LICENSE", "log", "panorama.tmproj", "public", "public/404.html", "public/500.html", "public/dispatch.cgi", "public/dispatch.fcgi", "public/dispatch.rb", "public/favicon.ico", "public/images", "public/images/admin", "public/images/admin/add_child.png", "public/images/admin/add_tab.png", "public/images/admin/avatar_32x32.png", "public/images/admin/brown_bottom_line.gif", "public/images/admin/buttons_background.png", "public/images/admin/collapse.png", "public/images/admin/draft_page.png", "public/images/admin/expand.png", "public/images/admin/layout.png", "public/images/admin/login_shadow.png", "public/images/admin/metadata_toggle.png", "public/images/admin/minus.png", "public/images/admin/minus_grey.png", "public/images/admin/navigation_background.gif", "public/images/admin/navigation_secondary_background.png", "public/images/admin/navigation_secondary_separator.gif", "public/images/admin/navigation_shadow.png", "public/images/admin/navigation_tabs.png", "public/images/admin/new_homepage.png", "public/images/admin/new_layout.png", "public/images/admin/new_snippet.png", "public/images/admin/new_user.png", "public/images/admin/page.png", "public/images/admin/plus.png", "public/images/admin/plus_grey.png", "public/images/admin/popup_border_background.png", "public/images/admin/popup_border_bottom_left.png", "public/images/admin/popup_border_bottom_right.png", "public/images/admin/popup_border_top_left.png", "public/images/admin/popup_border_top_right.png", "public/images/admin/remove.png", "public/images/admin/remove_disabled.png", "public/images/admin/snippet.png", "public/images/admin/spacer.gif", "public/images/admin/spinner.gif", "public/images/admin/status_background.png", "public/images/admin/status_bottom_left.png", "public/images/admin/status_bottom_right.png", "public/images/admin/status_spinner.gif", "public/images/admin/status_top_left.png", "public/images/admin/status_top_right.png", "public/images/admin/tab_close.png", "public/images/admin/vertical_tan_gradient.png", "public/images/admin/view_site.png", "public/images/admin/virtual_page.png", "public/javascripts", "public/javascripts/admin", "public/javascripts/admin/application.js", "public/javascripts/admin/codearea.js", "public/javascripts/admin/controls.js", "public/javascripts/admin/cookie.js", "public/javascripts/admin/dragdrop.js", "public/javascripts/admin/effects.js", "public/javascripts/admin/lowpro.js", "public/javascripts/admin/pngfix.js", "public/javascripts/admin/popup.js", "public/javascripts/admin/prototype.js", "public/javascripts/admin/ruledtable.js", "public/javascripts/admin/shortcuts.js", "public/javascripts/admin/sitemap.js", "public/javascripts/admin/status.js", "public/javascripts/admin/tabcontrol.js", "public/javascripts/admin/utility.js", "public/robots.txt", "public/stylesheets", "public/stylesheets/admin", "public/stylesheets/admin/main.css", "public/stylesheets/admin/styles.css", "public/stylesheets/sass", "public/stylesheets/sass/admin", "public/stylesheets/sass/admin/_avatars.sass", "public/stylesheets/sass/admin/_base.sass", "public/stylesheets/sass/admin/_content.sass", "public/stylesheets/sass/admin/_footer.sass", "public/stylesheets/sass/admin/_forms.sass", "public/stylesheets/sass/admin/_header.sass", "public/stylesheets/sass/admin/_layout.sass", "public/stylesheets/sass/admin/_messages.sass", "public/stylesheets/sass/admin/_popup.sass", "public/stylesheets/sass/admin/_reset.sass", "public/stylesheets/sass/admin/_status.sass", "public/stylesheets/sass/admin/_tabcontrol.sass", "public/stylesheets/sass/admin/main.sass", "public/stylesheets/sass/admin/styles.sass", "Rakefile", "README", "script", "script/about", "script/autospec", "script/breakpointer", "script/console", "script/cucumber", "script/dbconsole", "script/extension", "script/generate", "script/performance", "script/performance/benchmarker", "script/performance/profiler", "script/performance/request", "script/process", "script/process/inspector", "script/process/reaper", "script/process/spawner", "script/process/spinner", "script/runner", "script/server", "script/spec", "script/spec_server", "script/version", "vendor", "vendor/extensions", "vendor/plugins", "log/.keep", "public/.htaccess"]
  s.homepage = %q{http://radiantcms.org}
  s.rdoc_options = ["--title", "Radiant -- Publishing for Small Teams", "--line-numbers", "--main", "README", "--exclude", "config", "--exclude", "db", "--exclude", "log", "--exclude", "public", "--exclude", "script", "--exclude", "tmp", "--exclude", "vendor"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{radiant}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A no-fluff content management system designed for small teams.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0.8.3"])
      s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<RedCloth>, [">= 4.0.0"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.3"])
      s.add_dependency(%q<rack>, [">= 1.0.0"])
      s.add_dependency(%q<RedCloth>, [">= 4.0.0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.3"])
    s.add_dependency(%q<rack>, [">= 1.0.0"])
    s.add_dependency(%q<RedCloth>, [">= 4.0.0"])
  end
end
