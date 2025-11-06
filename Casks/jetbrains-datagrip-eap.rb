cask "jetbrains-datagrip-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.27864.43"
  sha256 x86_64_linux: "05d9cf205d2babce5e068bf6f9998503f3d49819bfd4372197ad09a5d4321f41",
         arm64_linux:  "55b244e18068375335981e974959f4674f843f1575fa3f0aeef49f6e889c51a7"

  url "https://download.jetbrains.com/datagrip/datagrip-#{version.csv.second}#{arch}.tar.gz"
  name "DataGrip EAP"
  desc "Databases and SQL IDE Early Access Program"
  homepage "https://www.jetbrains.com/datagrip/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=DG&release.type=eap"
    strategy :json do |json|
      json["DG"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-datagrip"]

  binary "DataGrip-#{version.csv.second}/bin/datagrip"
  artifact "datagrip.desktop",
           target: "#{Dir.home}/.local/share/applications/datagrip.desktop"
  artifact "DataGrip-#{version.csv.second}/bin/datagrip.svg",
           target: "#{Dir.home}/.local/share/icons/datagrip.svg"
  artifact "DataGrip-#{version.csv.second}/bin/datagrip.png",
           target: "#{Dir.home}/.local/share/icons/datagrip.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/datagrip.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=DataGrip
      Comment=JetBrains Databases and SQL IDE
      Exec=#{HOMEBREW_PREFIX}/bin/datagrip %u
      Icon=datagrip
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;database;sql;
      Terminal=false
      StartupWMClass=jetbrains-datagrip
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/DataGrip#{version.major_minor}",
  ]
end
