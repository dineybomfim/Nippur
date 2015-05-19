include FileUtils::Verbose

namespace :test do

  desc "Run the TDD for iOS"
  task :ios do
    run_tests('TDD iOS', 'iphonesimulator')
    tests_failed('iOS') unless $?.success?
  end

end

desc "Run all Tests"
task :test do
  #Rake::Task['test:ios'].invoke
  ENV['GHUNIT_CLI'] = "1"
  if system("xctool -workspace Nippur.xcworkspace -scheme TDD iOS")
    puts "\033[0;32m** All tests executed successfully"
  else
    puts "\033[0;31m! Unit tests failed"
    exit(-1)
  end
end

task :default => 'test'


private

def run_tests(scheme, sdk)
  sh("xcodebuild -workspace Nippur.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -configuration Release clean test | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
end

def is_mavericks_or_above
  osx_version = `sw_vers -productVersion`.chomp
  Gem::Version.new(osx_version) >= Gem::Version.new('10.9')
end

def tests_failed(platform)
  puts red("#{platform} tests failed")
  exit $?.exitstatus
end

def red(string)
 "\033[0;31m! #{string}"
end

