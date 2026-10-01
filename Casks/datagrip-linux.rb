cask "datagrip-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.1.3,261.24374.56"
  sha256 arm64_linux:  "1beb629c3ffea8ce47551e2ed84d1c357b5d56c6f080af3f3dd67789cea17f83",
         x86_64_linux: "5f1c2f5e269601f2b7d7c0636f328f2d50de30194eaf9045b83d9ba94f3ed76a"

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

  preflight_steps do
    run "/bin/sh",
        args:  ["-c", "for f in */bin/*64.vmoptions; do printf -- '%s\\n' \"$1\" >> \"$f\"; done", "sh",
                "-Dide.no.platform.update=true"],
        chdir: "."
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-datagrip.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=DataGrip
      Comment=The IDE for databases and SQL
      Exec={{HOMEBREW_PREFIX}}/bin/datagrip %u
      Icon=datagrip
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;database;sql;
      Terminal=false
      StartupWMClass=jetbrains-datagrip
      StartupNotify=true
    EOS
  end

  postflight_steps do
    touch ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
    remove ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/DataGrip#{version.major_minor}",
  ]
end
