# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
require 'yaml'
require 'ostruct'

UNSET_VALUE = Object.new

confDir = $confDir ||= File.expand_path(File.dirname(__FILE__))

homelyYamlPath = confDir + "/Homely.yaml"
homelyJsonPath = confDir + "/Homely.json"
afterScriptPath = confDir + "/after.sh"
customizationScriptPath = confDir + "/user-customizations.sh"

require File.expand_path(File.dirname(__FILE__) + '/scripts/homely.rb')
require File.expand_path(File.dirname(__FILE__) + '/plugins/provisioners/shell/provisioner.rb')

if File.exist? homelyYamlPath then
    settings = YAML::load(File.read(homelyYamlPath))
elsif File.exist? homelyJsonPath then
    settings = JSON::parse(File.read(homelyJsonPath))
else
    abort "Homely settings file not found in #{confDir}"
end

config = OpenStruct.new(
    :shell => HomelyPlugins::Shell::Provisioner.new
)
Homely.configure(config, settings)

if File.exist? afterScriptPath then
    config.shell.provision "Run after.sh", type: "file", path: afterScriptPath
end

if File.exist? customizationScriptPath then
    config.shell.provision "Run customize script", type: "file", path: customizationScriptPath
end