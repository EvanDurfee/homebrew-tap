cask "jetbrains-datagrip-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28294.90"
  sha256 x86_64_linux: "f8b7a9d4c32a575e13c07b2858dbb5704d27550d35d6aa542d8a2bd2bcc84533",
         arm64_linux:  "665205ef83f269fd4682539a15aec49f7841bf2de94363408ebf2b01307e5cfa"

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

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/datagrip.wrapper.sh"
  binary shimscript, target: "datagrip"
  artifact "datagrip.desktop",
           target: "#{Dir.home}/.local/share/applications/datagrip.desktop"
  artifact "DataGrip-#{version.csv.second}/bin/datagrip.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/datagrip.svg"

  preflight do
    File.write("#{staged_path}/DataGrip-#{version.csv.second}/bin/datagrip64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{HOMEBREW_PREFIX}/Caskroom/jetbrains-datagrip-eap/#{version}/DataGrip-#{version.csv.second}/bin/datagrip' "$@"
    EOS
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
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

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/DataGrip#{version.major_minor}",
  ]
end
