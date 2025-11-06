cask "jetbrains-rubymine-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28086.34"
  sha256 x86_64_linux: "75e53a6c6b257d623a40c1a8a36f702bf69396d5c41eb7f19e0c4b7f82550a55",
         arm64_linux:  "1b2f1d2447442da7b4f960c7bbd828a74e89456cadd8a520add454cd989730cb"

  url "https://download.jetbrains.com/ruby/RubyMine-#{version.csv.second}#{arch}.tar.gz"
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
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-rubymine"]

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/rubymine.wrapper.sh"
  binary shimscript, target: "rubymine"
  artifact "rubymine.desktop",
           target: "#{Dir.home}/.local/share/applications/rubymine.desktop"
  artifact "RubyMine-#{version.csv.second}/bin/rubymine.svg",
           target: "#{Dir.home}/.local/share/icons/rubymine.svg"
  artifact "RubyMine-#{version.csv.second}/bin/rubymine.png",
           target: "#{Dir.home}/.local/share/icons/rubymine.png"

  preflight do
    File.write("#{staged_path}/RubyMine-#{version.csv.second}/bin/rubymine64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{HOMEBREW_PREFIX}/Caskroom/jetbrains-rubymine-eap/#{version}/RubyMine-#{version.csv.second}/bin/rubymine' "$@"
    EOS
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
