require 'java'
require 'rubygems'

begin
  # will work from gem, since lib dir is in gem require_paths
  require 'red_storm'
rescue LoadError
  # will work within RedStorm dev project
  $:.unshift './lib'
  require 'red_storm'
end

# see https://github.com/colinsurprenant/redstorm/issues/7
module Backtype
  java_import 'backtype.storm.Config'
end

java_import 'backtype.storm.LocalCluster'
java_import 'backtype.storm.StormSubmitter'
java_import 'backtype.storm.topology.TopologyBuilder'
java_import 'backtype.storm.tuple.Fields'
java_import 'backtype.storm.tuple.Tuple'
java_import 'backtype.storm.tuple.Values'

java_import 'redstorm.storm.jruby.JRubyBolt'
java_import 'redstorm.storm.jruby.JRubySpout'

java_package 'redstorm'

# TopologyLauncher is the application entry point when launching a topology. Basically it will 
# call require on the specified Ruby topology class file path and call its start method
class TopologyLauncher

  java_signature 'void main(String[])'
  def self.main(args)
    unless args.size > 1 
      puts("Usage: redstorm local|cluster topology_class_file_name")
      exit(1)
    end

    puts("****TOPOLOGY LAUNCHER ** PWD=#{Dir.pwd}")
    puts("****TOPOLOGY LAUNCHER ** RedStorm::JAR_CONTEXT=#{RedStorm::JAR_CONTEXT}")
    puts("****TOPOLOGY LAUNCHER ** RedStorm::LAUNCH_PATH=#{RedStorm::LAUNCH_PATH}")
    puts("****TOPOLOGY LAUNCHER ** RedStorm::REDSTORM_HOME=#{RedStorm::REDSTORM_HOME}")
    puts("****TOPOLOGY LAUNCHER ** RedStorm::TARGET_PATH=#{RedStorm::TARGET_PATH}")
    puts("****TOPOLOGY LAUNCHER ** RedStorm::GEM_PATH=#{RedStorm::GEM_PATH}")
    puts("****TOPOLOGY LAUNCHER ** ENV['BUNDLE_GEMFILE']=#{ENV['BUNDLE_GEMFILE']}")
    puts("****TOPOLOGY LAUNCHER ** ENV['BUNDLE_PATH']=#{ENV['BUNDLE_PATH']}")
    puts("****TOPOLOGY LAUNCHER ** ENV['GEM_PATH']=#{ENV['GEM_PATH']}")

    RedStorm.setup_gems

    env = args[0].to_sym
    class_path = args[1]


    require "./#{class_path}" # ./ for 1.9 compatibility

    topology_name = RedStorm::Configuration.topology_class.respond_to?(:topology_name) ? "/#{RedStorm::Configuration.topology_class.topology_name}" : ''
    puts("RedStorm v#{RedStorm::VERSION} starting topology #{RedStorm::Configuration.topology_class.name}#{topology_name} in #{env.to_s} environment")
    RedStorm::Configuration.topology_class.new.start(class_path, env)
  end

  private 

  def self.camel_case(s)
    s.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
end
