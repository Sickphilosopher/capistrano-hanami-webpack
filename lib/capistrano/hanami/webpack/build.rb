namespace :deploy do
	desc 'Compile assets'
  task build_webpack: [:set_hanami_env] do
    on release_roles(fetch(:assets_roles)) do
      within release_path do
        with hanami_env: fetch(:hanami_env) do
          execute :hanami, 'webpack build'
        end
      end
    end
  end

  after 'yarn:install', 'deploy:build_webpack'
end

namespace :load do
  task :defaults do
    # Chruby, Rbenv and RVM integration
    append :chruby_map_bins, 'hanami'
    append :rbenv_map_bins, 'hanami'
    append :rvm_map_bins, 'hanami'

    # Bundler integration
    append :bundle_bins, 'hanami'
  end
end