namespace :assets do
  desc 'Install assets dependencies'
  task :install do
    require 'pathname'
    require 'fileutils'
    app_root = Pathname.new File.expand_path('../../../',  __FILE__)

    Dir.chdir app_root do
      vendor_assets = app_root + 'vendor' + 'assets'
      output = app_root + 'app' + 'assets' + 'compiled'
      FileUtils.rm_rf vendor_assets
      FileUtils.mkdir_p(output + 'js')
      FileUtils.mkdir_p(output + 'css')
      FileUtils.mkdir_p(vendor_assets)

      system 'npm install'
      system 'node_modules/.bin/bower install'

      Dir.chdir(app_root + 'app' + 'assets' + 'stylesheets') do
        system 'bundle exec bourbon install'
        system 'bundle exec neat install'
        system 'bundle exec neat update'
      end
    end
  end
end
