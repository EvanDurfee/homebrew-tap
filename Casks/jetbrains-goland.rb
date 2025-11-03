cask "jetbrains-goland" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.4,252.27397.106"
  sha256 x86_64_linux: "f1613a171ab07ba0e7ccd13cb537af4da8920c89cf4a13c64a3f7ae72e803701",
         arm64_linux:  "91569e7ba9988af1aa4d9973f52dfa8af8a94f32a53faa8457c7ba17d25f43b3"

  url "https://download.jetbrains.com/python/goland-#{version.csv.first}#{arch}.tar.gz"
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
