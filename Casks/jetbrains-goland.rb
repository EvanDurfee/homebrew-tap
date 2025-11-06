cask "jetbrains-goland" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.4,252.27397.100"
  sha256 x86_64_linux: "fb42978d55271e6fa3165b1d010b3e0bacb8cd5c4f4073712332c62f32d2ebab",
         arm64_linux:  "09e5790b20c5ca952af8c86a6094e83aa250d9eb751d144800ba83701d3512a8"

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
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-goland-eap"]

  binary "GoLand-#{version.csv.first}/bin/goland"
  artifact "goland.desktop",
           target: "#{Dir.home}/.local/share/applications/goland.desktop"
  artifact "GoLand-#{version.csv.first}/bin/goland.svg",
           target: "#{Dir.home}/.local/share/icons/goland.svg"
  artifact "GoLand-#{version.csv.first}/bin/goland.png",
           target: "#{Dir.home}/.local/share/icons/goland.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/goland.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=GoLand
      Comment=JetBrains Golang IDE
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

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/GoLand#{version.major_minor}",
  ]
end
