cask "goland-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.5,252.28238.32"
  sha256 x86_64_linux: "7b748b7f5af267e8bd4d90d44bbeea8cb58b262115d884d2cd567af8d9d753c1",
         arm64_linux:  "c9bdfe1a106c470ee335d779ab59f61898098d4769dac8c2975113dba6d8dcf5"

  url "https://download.jetbrains.com/go/goland-#{version.csv.first}#{arch}.tar.gz"
  name "GoLand"
  desc "Go (golang) IDE"
  homepage "https://www.jetbrains.com/goland/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=GO&latest=true&type=release"
    strategy :json do |json|
      json["GO"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/goland-linux/#{version}/GoLand-#{version.csv.first}/bin/goland"
  artifact "jetbrains-goland.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-goland.desktop"
  artifact "GoLand-#{version.csv.first}/bin/goland.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/goland.svg"

  preflight do
    File.write("#{staged_path}/GoLand-#{version.csv.first}/bin/goland64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-goland.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=GoLand
      Comment=An IDE for Go and Web
      Exec=#{HOMEBREW_PREFIX}/bin/goland %u
      Icon=goland
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;go;golang;
      Terminal=false
      StartupWMClass=jetbrains-goland
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/GoLand#{version.major_minor}",
  ]
end
