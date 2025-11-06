cask "jetbrains-rustrover-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.4.1,252.27397.133"
  sha256 x86_64_linux: "a51a62af4801f7f4caf8586dde0354d06f6bc351660b75feff554e756874cb37",
         arm64_linux:  "83d868b92b79907dc42d9e4aacc2a2aae3f9838d392c5a7593487bf4cbb8c641"

  url "https://download.jetbrains.com/rustrover/RustRover-#{version.csv.first}#{arch}.tar.gz"
  name "RustRover EAP"
  desc "Rust IDE Early Access Program"
  homepage "https://www.jetbrains.com/rustrover/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RR&release.type=eap"
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
      Exec=#{HOMEBREW_PREFIX}/bin/rustrover %u
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
