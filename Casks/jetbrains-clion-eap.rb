cask "jetbrains-clion-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.4,252.27397.114"
  sha256 x86_64_linux: "72c89e91f6636aa53930288fe02466e5e09a50a3c8b6ed5ad2f69b35ec9bacc5",
         arm64_linux:  "b89010db5272eb6490a0084bd3247c9de657ffd0d12a827147f2c77a406f85b5"

  url "https://download.jetbrains.com/cpp/CLion-#{version.csv.first}#{arch}.tar.gz"
  name "CLion EAP"
  desc "C and C++ IDE Early Access Program"
  homepage "https://www.jetbrains.com/clion/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=CL&release.type=eap"
    strategy :json do |json|
      json["CL"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox"
  conflicts_with cask: "jetbrains-clion"

  binary "clion-#{version.csv.first}/bin/clion"
  artifact "clion.desktop",
           target: "#{Dir.home}/.local/share/applications/clion.desktop"
  artifact "clion-#{version.csv.first}/bin/clion.svg",
           target: "#{Dir.home}/.local/share/icons/clion.svg"
  artifact "clion-#{version.csv.first}/bin/clion.png",
           target: "#{Dir.home}/.local/share/icons/clion.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/clion.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=CLion
      Comment=JetBrains C and C++ IDE
      Exec=#{HOMEBREW_PREFIX}/bin/clion %u
      Icon=clion
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;c;c++;
      Terminal=false
      StartupWMClass=jetbrains-clion
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/CLion#{version.major_minor}",
  ]
end
