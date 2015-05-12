Pod::Spec.new do |s|
  s.name             = "Nippur"
  s.version          = "1.0.1"
  s.summary          = "Nippur is a framework for daily work. To make it easier and reliable."
  s.description      = <<-DESC
                       Nippur is a framework made with several years of daily work, reusing the most common and most complexes part of the code.
                       It is separated in parts (similar to packages) that allows you to import only the necessary parts to your project,
                       since there are codes for many situations inside it.

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://db-in.com/nippur"
  s.license          = 'MIT'
  s.author           = { "Diney Bomfim" => "diney@db-in.com" }
  s.source           = { :git => "https://bitbucket.org/dineybomfim/nippur.git", :tag => s.version, :submodules => true }
  s.social_media_url = 'https://twitter.com/dineybomfim'

  s.requires_arc = false
  s.ios.deployment_target = '6.0'

  s.subspec 'Core' do |ss|
    ss.public_header_files = 'Nippur/Source/Core/*.h'
    ss.source_files = 'Nippur/Source/Core/*.{h,m}'
    ss.ios.frameworks = 'Foundation', 'CoreGraphics', 'QuartzCore'
  end

  s.subspec 'Animation' do |ss|
    ss.dependency 'Nippur/Core'

    ss.public_header_files = 'Nippur/Source/Animation/*.h'
    ss.private_header_files = 'Nippur/Source/Animation/NPPAction?*.h'
    ss.source_files = 'Nippur/Source/Animation/*.{h,m}'
  end

  s.subspec 'Interface' do |ss|
    ss.dependency 'Nippur/Core'
    ss.dependency 'Nippur/Animation'

    ss.public_header_files = 'Nippur/Source/Interface/*.h'
    ss.source_files = 'Nippur/Source/Interface/*.{h,m}'
    ss.ios.frameworks = 'UIKit'

    ss.resource_bundles = {
      'Nippur' => ['Nippur/Resource/Nippur.bundle']
    }
  end

  s.subspec 'Geolocation' do |ss|
    ss.dependency 'Nippur/Core'

    ss.public_header_files = 'Nippur/Source/Geolocation/*.h'
    ss.source_files = 'Nippur/Source/Geolocation/*.{h,m}'
    ss.ios.frameworks = 'CoreLocation'
  end

  s.subspec 'Media' do |ss|
    ss.dependency 'Nippur/Core'

    ss.public_header_files = 'Nippur/Source/Media/*.h'
    ss.source_files = 'Nippur/Source/Media/*.{h,m}'
    ss.ios.frameworks = 'AudioToolbox', 'AVFoundation', 'CoreMedia', 'CoreVideo'
  end

end
