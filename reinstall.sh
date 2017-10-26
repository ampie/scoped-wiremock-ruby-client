gem uninstall automation-ruby-support -a
gem build automation-ruby-support.gemspec

# This line needs access to the internet due to transitive dependencies
#gem install automation-ruby-support-0.0.19.gem -l

# This line does not need access to the internet provided that all the transitive dependencies are already installed.
cp -rfv lib $GEM_HOME/gems/automation-ruby-support-0.0.19/
