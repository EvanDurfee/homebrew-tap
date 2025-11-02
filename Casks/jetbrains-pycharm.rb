cask "jetbrains-pycharm" do
  arch arm64_linux: "-aarch64"
  # https://www.jetbrains.com/pycharm/download/other.html
  # cksum -a sha256 <file>
  # or at https://download.jetbrains.com/python/pycharm-2025.2.4.tar.gz.sha256
  # Also ref https://github.com/Homebrew/homebrew-cask/blob/143bed19c5895fed23f87bf30f0f1865c2e689ae/Casks/i/intellij-idea.rb
  version "2025.2.4,252.27397.106"
  sha256 x86_64_linux: "f1613a171ab07ba0e7ccd13cb537af4da8920c89cf4a13c64a3f7ae72e803701",
         arm64_linux: "91569e7ba9988af1aa4d9973f52dfa8af8a94f32a53faa8457c7ba17d25f43b3"

  url "https://download.jetbrains.com/python/pycharm-#{version.csv.first}#{arch}.tar.gz"
  name "PyCharm"
  desc "IDE for professional Python development"
  homepage "https://www.jetbrains.com/pycharm/"

  livecheck do
    # curl ... | jq '.PCP[0] | .version, .build'
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

  # TODO: can we disable auto-updates and use brew to update instead?
  auto_updates false
  conflicts_with cask: "jetbrains-toolbox"

  binary "pycharm-#{version.csv.first}/bin/pycharm"
  artifact "pycharm.desktop",
           target: "#{Dir.home}/.local/share/applications/pycharm.desktop"
  artifact "pycharm-#{version.csv.first}/bin/pycharm.svg",
           target: "#{Dir.home}/.local/share/icons/pycharm.svg"
  artifact "pycharm-#{version.csv.first}/bin/pycharm.png",
           target: "#{Dir.home}/.local/share/icons/pycharm.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    # We need this file to start, but Jetbrains Toolbox will overwrite it on its first run with a proper one
    # It will also extract the icon from somewhere, but it doesn't exist until first run, so we just point to where it
    # should be, and it will get fixed on first run
    File.write("#{staged_path}/pycharm.desktop", <<~EOS)
      [Desktop Entry]
      Name=PyCharm
      Version=1.0
      Icon=pycharm
      Exec=#{HOMEBREW_PREFIX}/pycharm-#{version.csv.first}/bin/pycharm -Dawt.toolkit.name=WLToolkit %u
      Type=Application
      Comment=JetBrains Python IDE
      Categories=Development;IDE;
      Keywords=jetbrains;ide;code;python;
      Terminal=false
      StartupWMClass=jetbrains-pycharm
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.config/JetBrains/PyCharm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/PyCharm#{version.major_minor}",
  ]
end
