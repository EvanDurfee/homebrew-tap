cask "jetbrains-datagrip" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.4,252.26830.46"
  sha256 x86_64_linux: "37d0af4ec30b94c71d3507fe35b3b0bdd389903db7e2f1a8ed73353b22718476",
         arm64_linux:  "7df40778500a599d565ba985d1583f3334903fbb731f53add526b19557208d97"

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
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-datagrip-eap"]

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/datagrip.wrapper.sh"
  binary shimscript, target: "datagrip"
  artifact "datagrip.desktop",
           target: "#{Dir.home}/.local/share/applications/datagrip.desktop"
  artifact "DataGrip-#{version.csv.first}/bin/datagrip.svg",
           target: "#{Dir.home}/.local/share/icons/datagrip.svg"
  artifact "DataGrip-#{version.csv.first}/bin/datagrip.png",
           target: "#{Dir.home}/.local/share/icons/datagrip.png"

  preflight do
    File.write("#{staged_path}/DataGrip-#{version.csv.first}/bin/datagrip64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{HOMEBREW_PREFIX}/Caskroom/jetbrains-datagrip/#{version}/DataGrip-#{version.csv.first}/bin/datagrip' "$@"
    EOS
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
