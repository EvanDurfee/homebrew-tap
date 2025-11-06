cask "jetbrains-pycharm" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.4,252.27397.106"
  sha256 x86_64_linux: "f1613a171ab07ba0e7ccd13cb537af4da8920c89cf4a13c64a3f7ae72e803701",
         arm64_linux:  "91569e7ba9988af1aa4d9973f52dfa8af8a94f32a53faa8457c7ba17d25f43b3"

  url "https://download.jetbrains.com/python/pycharm-#{version.csv.first}#{arch}.tar.gz"
  name "PyCharm"
  desc "IDE for professional Python development"
  homepage "https://www.jetbrains.com/pycharm/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=PCP&latest=true&type=release"
    strategy :json do |json|
      json["PCP"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  # The IDEs have their own auto-update, but it doesn't work with this setup
  # seemingly due to hard-links on the artifacts
  auto_updates false
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-pycharm-eap"]

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/pycharm.wrapper.sh"
  binary shimscript, target: "pycharm"
  artifact "pycharm.desktop",
           target: "#{Dir.home}/.local/share/applications/pycharm.desktop"
  artifact "pycharm-#{version.csv.first}/bin/pycharm.svg",
           target: "#{Dir.home}/.local/share/icons/pycharm.svg"
  artifact "pycharm-#{version.csv.first}/bin/pycharm.png",
           target: "#{Dir.home}/.local/share/icons/pycharm.png"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{prefix}/pycharm-#{version.csv.first}/bin/pycharm' -Dide.no.platform.update=true "$@"
    EOS
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/pycharm.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=PyCharm
      Comment=JetBrains Python IDE
      Exec=#{HOMEBREW_PREFIX}/bin/pycharm %u
      Icon=pycharm
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;python;
      Terminal=false
      StartupWMClass=jetbrains-pycharm
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/PyCharm#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/PyCharm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/PyCharm#{version.major_minor}",
  ]
end
