Pod::Spec.new do |s|
  s.name         = 'MOLCodesignChecker'
  s.version      = '1.10'
  s.platform     = :osx, '10.8'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.homepage     = 'https://github.com/google/macops-molcodesignchecker'
  s.authors      = { 'Google Macops' => 'macops-external@google.com' }
  s.summary      = 'Perform codesign validation simply in Objective-C'
  s.source       = { :git => 'https://github.com/google/macops-molcodesignchecker.git',
                     :tag => "v#{s.version}" }
  s.source_files = 'Source/MOLCodesignChecker/MOLCodesignChecker.{h,m}'
  s.framework    = 'Security'
  s.dependency 'MOLCertificate', '~> 1.8'
end
