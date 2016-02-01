namespace :test do
  desc 'Run Rubocop'
  task :rubocop do
    sh 'bundle exec rubocop'
  end

  desc 'Run Karma'
  task karma: :environment do
    Dir.chdir(Rails.root) do
      sh 'node_modules/karma/bin/karma start karma.conf.js'
    end
  end
end

task test: ['test:rubocop', 'spec', 'test:karma']
