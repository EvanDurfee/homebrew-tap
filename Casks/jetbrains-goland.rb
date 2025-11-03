cask "jetbrains-goland" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.3,252.26830.102"
  sha256 x86_64_linux: "06d9e18cc840e5bc68db6802ed90cfd5c8629d8c434e51aee6e4a93dad56b3e1",
         arm64_linux:  "09d897264b991a0f63e07b3b34f0878e2967ffbf504748881c43c2b21d638976"

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
  conflicts_with cask: "jetbrains-toolbox"

  binary "goland-#{version.csv.first}/bin/goland"
  artifact "goland.desktop",
           target: "#{Dir.home}/.local/share/applications/goland.desktop"
  artifact "goland-#{version.csv.first}/bin/goland.svg",
           target: "#{Dir.home}/.local/share/icons/goland.svg"
  artifact "goland-#{version.csv.first}/bin/goland.png",
           target: "#{Dir.home}/.local/share/icons/goland.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/goland.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=GoLand
      Comment=JetBrains Golang IDE
      Exec=#{HOMEBREW_PREFIX}/bin/goland -Dawt.toolkit.name=WLToolkit %u
      Icon=goland
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;go;golang;
      Terminal=false
      StartupWMClass=jetbrains-goland
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/GoLand#{version.major_minor}",
  ]
end
