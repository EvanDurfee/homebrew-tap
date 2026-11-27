cask "webstorm-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.3.0.1,263.7307.348"
  sha256 arm64_linux:  "021fac7ad63b0944a987bad5e3ae4d8b9a082389c074daebe7fbd0f3f404860e",
         x86_64_linux: "ec066b78e09be654444bc16c0fea68607592aa616cceead23ef8ec17a0932f5d"

  url "https://download.jetbrains.com/webstorm/WebStorm-#{version.csv.first}#{arch}.tar.gz"
  name "WebStorm"
  desc "JavaScript IDE"
  homepage "https://www.jetbrains.com/webstorm/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=WS&latest=true&type=release"
    strategy :json do |json|
      json["WS"]&.map do |release|
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

  binary "#{HOMEBREW_PREFIX}/Caskroom/webstorm-linux/#{version}/WebStorm-#{version.csv.second}/bin/webstorm"
  artifact "jetbrains-webstorm.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-webstorm.desktop"
  artifact "WebStorm-#{version.csv.second}/bin/webstorm.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/webstorm.svg"

  preflight_steps do
    run "/bin/sh",
        args:  ["-c", "for f in */bin/*64.vmoptions; do printf -- '%s\\n' \"$1\" >> \"$f\"; done", "sh",
                "-Dide.no.platform.update=true"],
        chdir: "."
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-webstorm.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=WebStorm
      Comment=A JavaScript and TypeScript IDE
      Exec={{HOMEBREW_PREFIX}}/bin/webstorm %u
      Icon=webstorm
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;javascript;typescript;
      Terminal=false
      StartupWMClass=jetbrains-webstorm
      StartupNotify=true
    EOS
  end

  postflight_steps do
    touch ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
    remove ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/WebStorm#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/WebStorm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/WebStorm#{version.major_minor}",
  ]
end
