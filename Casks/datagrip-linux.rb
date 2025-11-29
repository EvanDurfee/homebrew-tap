cask "datagrip-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.5,252.28238.33"
  sha256 x86_64_linux: "cc0ed935e2d9f52c037e79fe9ed5485702d23feaf94646ea448a5eef341fae04",
         arm64_linux:  "426fb71e1edb2d6a7c5aa0e2b62b3b766f0982404054595e3a5aae79f72ee2f8"

  url "https://download.jetbrains.com/datagrip/datagrip-#{version.csv.first}#{arch}.tar.gz"
  name "DataGrip"
  desc "Databases and SQL IDE"
  homepage "https://www.jetbrains.com/datagrip/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=DG&latest=true&type=release"
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
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/datagrip-linux/#{version}/DataGrip-#{version.csv.first}/bin/datagrip"
  artifact "jetbrains-datagrip.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-datagrip.desktop"
  artifact "DataGrip-#{version.csv.first}/bin/datagrip.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/datagrip.svg"

  preflight do
    File.write("#{staged_path}/DataGrip-#{version.csv.first}/bin/datagrip64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-datagrip.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=DataGrip
      Comment=The IDE for databases and SQL
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
