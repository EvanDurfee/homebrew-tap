cask "rubymine-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.1.3,261.25134.97"
  sha256 arm64_linux:  "922b91a7d261752d1a5053d7d5bac8d53f6293f8968609487241efbf86dd3d69",
         x86_64_linux: "d0a17f2045514fc9201e950b126a8ccbd80e7f4e88203038bc457746e8e34281"

  url "https://download.jetbrains.com/ruby/RubyMine-#{version.csv.first}#{arch}.tar.gz"
  name "RubyMine"
  desc "Ruby on Rails IDE"
  homepage "https://www.jetbrains.com/rubymine/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RM&latest=true&type=release"
    strategy :json do |json|
      json["RM"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/rubymine-linux/#{version}/RubyMine-#{version.csv.first}/bin/rubymine"
  artifact "jetbrains-rubymine.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-rubymine.desktop"
  artifact "RubyMine-#{version.csv.first}/bin/rubymine.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/rubymine.svg"

  preflight_steps do
    run "/bin/sh",
        args:  ["-c", "for f in */bin/*64.vmoptions; do printf -- '%s\\n' \"$1\" >> \"$f\"; done", "sh",
                "-Dide.no.platform.update=true"],
        chdir: "."
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-rubymine.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=RubyMine
      Comment=A Ruby and Rails IDE
      Exec={{HOMEBREW_PREFIX}}/bin/rubymine %u
      Icon=rubymine
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;ruby;rails;
      Terminal=false
      StartupWMClass=jetbrains-rubymine
      StartupNotify=true
    EOS
  end

  postflight_steps do
    run "/usr/bin/xdg-icon-resource", args: ["forceupdate"]
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/RubyMine#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/RubyMine#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/RubyMine#{version.major_minor}",
  ]
end
