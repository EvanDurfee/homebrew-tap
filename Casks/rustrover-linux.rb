cask "rustrover-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.3.1.1,263.7307.349"
  sha256 arm64_linux:  "7ad87ac25a4ac9f41e6d2ab34e08d4096bd69ad5125d5ecd05e67229060e0fdc",
         x86_64_linux: "fdc47941292bcda56ff6e1f165ae1f8bab70b3e34803d3a0e9ab144a15216ad6"

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
  conflicts_with cask: "jetbrains-toolbox-linux"
  depends_on linux: :any

  binary "#{HOMEBREW_PREFIX}/Caskroom/rustrover-linux/#{version}/RustRover-#{version.csv.first}/bin/rustrover"
  artifact "jetbrains-rustrover.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-rustrover.desktop"
  artifact "RustRover-#{version.csv.first}/bin/rustrover.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/rustrover.svg"

  preflight_steps do
    run "/bin/sh",
        args:  ["-c", "for f in */bin/*64.vmoptions; do printf -- '%s\\n' \"$1\" >> \"$f\"; done", "sh",
                "-Dide.no.platform.update=true"],
        chdir: "."
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-rustrover.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=RustRover
      Comment=A powerful IDE for Rust
      Exec={{HOMEBREW_PREFIX}}/bin/rustrover %u
      Icon=rustrover
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;rust;
      Terminal=false
      StartupWMClass=jetbrains-rustrover
      StartupNotify=true
    EOS
  end

  postflight_steps do
    touch ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
    remove ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/RustRover#{version.major_minor}",
  ]
end
