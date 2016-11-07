Pod::Spec.new do |s|
s.name         = "MLLayout"
s.version      = "0.4.1"
s.summary      = "Flexbox in Objective-C, using Facebook's css-layout."

s.homepage     = 'https://github.com/molon/MLLayout'
s.license      = { :type => 'MIT'}
s.author       = { "molon" => "dudl@qq.com" }

s.source       = {
:git => "https://github.com/molon/MLLayout.git",
:tag => "#{s.version}"
}

s.platform     = :ios, '7.0'
s.public_header_files = 'Classes/**/*.h'
s.source_files  = 'Classes/**/*.{h,m,c}'
s.resource = "Classes/**/*.md"
s.requires_arc  = true

end
