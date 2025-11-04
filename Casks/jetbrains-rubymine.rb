cask "jetbrains-rubymine" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.3,252.26830.94"
  sha256 x86_64_linux: "cf989d2e3851eb19db747eae0ee5cf4898645209397f955ac28870454a2a390e",
         arm64_linux:  "ed784cb51ab7272fbf6728f896321c039cb07c4979abbda2ea4a1962783c8da8"

  url "https://download.jetbrains.com/ruby/RubyMine-#{version.csv.first}#{arch}.tar.gz"
  name "RubyMine"
  desc "Ruby on Rails IDE"
  homepage "https://www.jetbrains.com/rubymine/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RM&latest=true&type=release"
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
      Exec=#{HOMEBREW_PREFIX}/bin/rubymine -Dawt.toolkit.name=WLToolkit %u
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
