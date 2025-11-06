cask "jetbrains-rubymine" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.4,252.27397.109"
  sha256 x86_64_linux: "9249ee0e99e24b3898065c5328f56814fb1a8b53afc192e81e7b70e0982eb116",
         arm64_linux:  "4071efa011638cf96f50962b4a7cdf1a28bbdc58af0ebc4c96ddfcc44de48621"

  url "https://download.jetbrains.com/ruby/RubyMine-#{version.csv.first}#{arch}.tar.gz"
  name "RubyMine EAP"
  desc "Ruby on Rails IDE Early Access Program"
  homepage "https://www.jetbrains.com/rubymine/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RM&release.type=eap"
    strategy :json do |json|
      json["RM"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox"

  binary "RubyMine-#{version.csv.first}/bin/rubymine"
  artifact "rubymine.desktop",
           target: "#{Dir.home}/.local/share/applications/rubymine.desktop"
  artifact "RubyMine-#{version.csv.first}/bin/rubymine.svg",
           target: "#{Dir.home}/.local/share/icons/rubymine.svg"
  artifact "RubyMine-#{version.csv.first}/bin/rubymine.png",
           target: "#{Dir.home}/.local/share/icons/rubymine.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/rubymine.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=RubyMine
      Comment=JetBrains Ruby on Rails IDE
      Exec=#{HOMEBREW_PREFIX}/bin/rubymine %u
      Icon=rubymine
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;ruby;gem;
      Terminal=false
      StartupWMClass=jetbrains-rubymine
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/RubyMine#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/RubyMine#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/RubyMine#{version.major_minor}",
  ]
end
