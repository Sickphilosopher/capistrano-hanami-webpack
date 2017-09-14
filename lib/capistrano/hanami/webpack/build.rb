namespace :deploy do
	desc 'Compile assets'
  task build_webpack: [:set_hanami_env] do
    on release_roles(fetch(:assets_roles)) do
      within release_path do
        with hanami_env: fetch(:hanami_env) do
          execute :hanpack, 'build'
        end
      end
    end
  end

  after 'yarn:install', 'deploy:build_webpack'
end

namespace :load do
  task :defaults do
    # Chruby, Rbenv and RVM integration
    append :chruby_map_bins, 'hanpack'
    append :rbenv_map_bins, 'hanpack'
    append :rvm_map_bins, 'hanpack'

    # Bundler integration
    append :bundle_bins, 'hanpack'
  end
end