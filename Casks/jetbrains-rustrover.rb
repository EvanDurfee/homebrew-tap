cask "jetbrains-rustrover" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.3,252.26830.136"
  sha256 x86_64_linux: "b96846e7257d14ef38154017cdbe9c63c66d19b59e94ad096db2c9ae2380103b",
         arm64_linux:  "5ffdff2a6617fcc75b68a145bc9dce14a71d0d9dc31a1adde5c8630d954a370d"

  url "https://download.jetbrains.com/rustrover/RustRover-#{version.csv.first}#{arch}.tar.gz"
  name "RustRover"
  desc "Rust IDE"
  homepage "https://www.jetbrains.com/rustrover/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RR&latest=true&type=release"
    strategy :json do |json|
      json["RR"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox"

  binary "RustRover-#{version.csv.first}/bin/rustrover"
  artifact "rustrover.desktop",
           target: "#{Dir.home}/.local/share/applications/rustrover.desktop"
  artifact "RustRover-#{version.csv.first}/bin/rustrover.svg",
           target: "#{Dir.home}/.local/share/icons/rustrover.svg"
  artifact "RustRover-#{version.csv.first}/bin/rustrover.png",
           target: "#{Dir.home}/.local/share/icons/rustrover.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/rustrover.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=RustRover
      Comment=JetBrains Rust IDE
      Exec=#{HOMEBREW_PREFIX}/bin/rustrover -Dawt.toolkit.name=WLToolkit %u
      Icon=rustrover
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;rust;
      Terminal=false
      StartupWMClass=jetbrains-rustrover
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/RustRover#{version.major_minor}",
  ]
end
