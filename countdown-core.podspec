Pod::Spec.new do |spec|

  spec.name         = "countdown-core"
  spec.version      = "0.0.1"
  spec.summary      = "A core framework for countdown apps"
  spec.description  = <<-DESC
    A core framework for my countdown apps
                   DESC

  spec.homepage     = "https://github.com/aaisataev/countdown-core"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Assylbek Issatayev" => "aaisataev@gmail.com" }

  spec.platform     = :ios, "14.0"
  spec.source       = { :git => "https://github.com/aaisataev/countdown-core.git", :tag => "#{spec.version}" }
  spec.source_files  = "countdown-core/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"

end
