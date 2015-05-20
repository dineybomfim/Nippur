include FileUtils::Verbose

namespace :test do

  task :ios do
    run_tests('TDD iOS', 'iphonesimulator')
    tests_failed('iOS') unless $?.success?
  end

end

task :install do
  sh 'sudo easy_install cpp-coveralls'
end

task :test do
  Rake::Task['test:ios'].invoke
end

task :report do
  sh "./coveralls.sh"
end

#task :default => 'test'

#"-configuration", "Debug",
#"-arch", "i386"
#xcodebuild
#xctool
private

def run_tests(scheme, sdk)
  sh("xctool -workspace Nippur.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -configuration Release -arch i386 test ONLY_ACTIVE_ARCH=NO GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
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

