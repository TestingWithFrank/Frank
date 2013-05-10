require 'pathname'
ROOT_DIR = Pathname.new(__FILE__).dirname.join("..").realpath
CONTROLS_APP_DIR = ROOT_DIR.join("example").join("Controls")
GEM_LIB_DIR = ROOT_DIR.join("gem").join("lib")

def in_controls_app(&block)
  Dir.chdir( CONTROLS_APP_DIR, &block )
end

def sh_using_local_frank_gem cmd
  full_cmd = "(export RUBYLIB='#{GEM_LIB_DIR}'; #{cmd})"
  sh full_cmd
end

namespace :ci do
  desc "build the controls example app and run all Frank tests against it"
  task :test_controls_example_app => ["ci:example_app:build","ci:example_app:test"]

  namespace :example_app do
    task :build do
      in_controls_app do
        sh_using_local_frank_gem "frank update"
        sh_using_local_frank_gem "frank build"
      end
    end

    task :test do
      in_controls_app do
        sh_using_local_frank_gem "cucumber features/my_first.feature"
      end
    end
  end
end

task :ci => [:build, 'ci:test_controls_example_app']
