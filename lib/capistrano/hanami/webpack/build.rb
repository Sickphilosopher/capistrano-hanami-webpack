require 'tmpdir'

namespace :deploy do
  namespace :hanami do
    namespace :webpack do
      desc 'Compile assets'
      task build: [:set_hanami_env] do
        on release_roles(fetch(:assets_roles)) do
          within release_path do
            with hanami_env: fetch(:hanami_env) do
              execute :hanami, :webpack, :build
            end
          end
        end
      end

      task build_local: [:set_hanami_env] do
        on release_roles(fetch(:assets_roles)) do
          within release_path do
            with hanami_env: fetch(:hanami_env) do
              execute :hanami, :webpack, :build
            end
          end
        end
      end

      desc "Actually precompile the webpack assets locally"
      task :precompile_locally do
        on roles(fetch(:assets_roles)) do |server|
          run_locally do
            with hanami_env: fetch(:precompile_env) do
              wp_config = "\"public_path=#{fetch(:webpack_precompile_dir)} stage=#{fetch(:stage) || fetch(:hanami_env)} manifest.dir=#{fetch(:webpack_manifest_dir)}\""
              execute :hanami, :webpack, :build, wp_config
            end
          end
        end
      end

      desc "Performs rsync to app servers"
      task :rsync do
        on roles(fetch(:assets_roles)) do |server|
          run_locally do
            with hanami_env: fetch(:precompile_env) do
              execute "#{fetch(:rsync_cmd)} #{fetch(:webpack_precompile_dir)}/ #{fetch(:user)}@#{server.hostname}:#{release_path}/#{fetch(:webpack_target_dir)}/"
              execute "#{fetch(:rsync_cmd)} #{fetch(:webpack_manifest_dir)}/ #{fetch(:user)}@#{server.hostname}:#{release_path}/#{fetch(:webpack_manifest_target_dir)}/"
            end
          end
        end
      end

      desc "Remove all local precompiled webpack assets"
      task :cleanup do
        run_locally do
          execute "rm -rf #{fetch(:webpack_precompile_dir)}"
          execute "rm -rf #{fetch(:webpack_manifest_dir)}"
        end
      end
    end
  end

  after 'bundler:install', 'deploy:hanami:webpack:precompile_locally'
  after 'deploy:hanami:webpack:precompile_locally', 'deploy:hanami:webpack:rsync'
  after 'deploy:hanami:webpack:rsync', 'deploy:hanami:webpack:cleanup'
end

namespace :load do
  task :defaults do
    set :webpack_precompile_dir, Dir.mktmpdir
    set :webpack_manifest_dir, Dir.mktmpdir
    set :webpack_manifest_target_dir, '.webpack'
    set :precompile_env,   fetch(:hanami_env) || 'production'
    set :webpack_target_dir,       "public"
    set :rsync_cmd,        "rsync -azq"
  end
end