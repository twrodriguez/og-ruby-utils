namespace :cache do
  desc 'Reload API cache in the background'
  task refresh: :environment do
    CacheInvalidateWorker.perform_async('update_all')
  end

  task destroy: :environment do
    require 'fileutils'
    FileUtils.rm_rf(Rails.root + 'db' + 'redis' + '*.rdb')
    FileUtils.rm_rf(Rails.root + 'db' + 'dynalite')
  end
end
