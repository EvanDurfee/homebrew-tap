cask "jetbrains-datagrip" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.3,252.26199.73"
  sha256 x86_64_linux: "7cac5ce1fc16ee3e7500a675ebf235e3285d6e87c0d61e8370e847f3a48528a7",
         arm64_linux:  "33caa8e0fb4c76e2704bc2457d0b87209f53861517bb43a1c675811b0703a773"

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
  conflicts_with cask: "jetbrains-toolbox"

  binary "DataGrip-#{version.csv.first}/bin/datagrip"
  artifact "datagrip.desktop",
           target: "#{Dir.home}/.local/share/applications/datagrip.desktop"
  artifact "DataGrip-#{version.csv.first}/bin/datagrip.svg",
           target: "#{Dir.home}/.local/share/icons/datagrip.svg"
  artifact "DataGrip-#{version.csv.first}/bin/datagrip.png",
           target: "#{Dir.home}/.local/share/icons/datagrip.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/datagrip.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=DataGrip
      Comment=JetBrains Databases and SQL IDE
      Exec=#{HOMEBREW_PREFIX}/bin/datagrip -Dawt.toolkit.name=WLToolkit %u
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
