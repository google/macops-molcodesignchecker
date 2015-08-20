Pod::Spec.new do |s|
  s.name         = 'MOLCodesignChecker'
  s.version      = '1.0'
  s.platform     = :osx
  s.license      = 'Apache'
  s.homepage     = 'https://github.com/google/macops-molcodesignchecker'
  s.author       = { 'Google Macops' => 'macops-external@google.com' }
  s.summary      = 'Perform codesign validation simply in Objective-C'
  s.source       = { :git => 'https://github.com/google/macops-molcodesignchecker.git', :tag => 'v1.0' }
  s.source_files = 'Source/MOLCodesignChecker.{h,m}'
  s.framework    = 'Security'
  s.dependency 'MOLCertificate', '~> 1.0'
end
