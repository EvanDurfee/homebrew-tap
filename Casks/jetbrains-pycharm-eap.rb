cask "jetbrains-pycharm-eap" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28086.55"
  sha256 x86_64_linux: "32df557617b2e5d4462303a49f977f529341fbb7e08b99f32121b281db1cb846",
         arm64_linux:  "f5e3e509ccbc6d7e1550afad8540953d7f5810d080563f22a8050cda3cfcba80"

  url "https://download.jetbrains.com/python/pycharm-#{version.csv.second}#{arch}.tar.gz"
  name "PyCharm EAP"
  desc "IDE for professional Python development Early Access Program"
  homepage "https://www.jetbrains.com/pycharm/nextversion"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=PCP&release.type=eap"
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
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-pycharm"]

  binary "pycharm-#{version.csv.second}/bin/pycharm"
  artifact "pycharm.desktop",
           target: "#{Dir.home}/.local/share/applications/pycharm.desktop"
  artifact "pycharm-#{version.csv.second}/bin/pycharm.svg",
           target: "#{Dir.home}/.local/share/icons/pycharm.svg"
  artifact "pycharm-#{version.csv.second}/bin/pycharm.png",
           target: "#{Dir.home}/.local/share/icons/pycharm.png"

  preflight do
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
