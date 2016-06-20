Pod::Spec.new do |s|
  s.name = 'Ripper'
  s.version = '0.7.1'
  s.license = 'Posse'
  s.summary = 'Simple image downloads for Swift'
  s.homepage = 'https://github.com/goposse/ripper'
  s.social_media_url = 'http://twitter.com/goposse'
  s.authors = { 'Posse Productions LLC' => 'apps@goposse.com' }
  s.source = { :git => 'https://github.com/goposse/ripper.git', :tag => s.version }

  s.platform = :ios
  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/**/*.swift'

  s.requires_arc = true
  s.dependency 'Haitch', '~> 0.7'
end
