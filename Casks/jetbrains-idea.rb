cask "jetbrains-idea" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.3,252.26830.84"
  sha256 x86_64_linux: "4a54ae8a17d6427f07d2450324132f59391279c6b1094de02f73e408deb5a23c",
         arm64_linux:  "42d0e7c9dbb7c0701883e4801bb77c56415817a41556388373bf71c96b3ab94e"

  url "https://download.jetbrains.com/idea/ideaIU-#{version.csv.first}#{arch}.tar.gz"
  name "IntelliJ IDEA Ultimate"
  desc "Java IDE by JetBrains"
  homepage "https://www.jetbrains.com/idea/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=IIU&latest=true&type=release"
    strategy :json do |json|
      json["IIU"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox"

  binary "idea-IU-#{version.csv.second}/bin/idea"
  artifact "idea.desktop",
           target: "#{Dir.home}/.local/share/applications/idea.desktop"
  artifact "idea-IU-#{version.csv.second}/bin/idea.svg",
           target: "#{Dir.home}/.local/share/icons/idea.svg"
  artifact "idea-IU-#{version.csv.second}/bin/idea.png",
           target: "#{Dir.home}/.local/share/icons/idea.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/idea.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=Intellij IDEA
      Comment=JetBrains Java IDE
      Exec=#{HOMEBREW_PREFIX}/bin/idea -Dawt.toolkit.name=WLToolkit %u
      Icon=idea
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;java;groovy;kotlin;scala;
      Terminal=false
      StartupWMClass=jetbrains-idea
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/IntelliJIdea#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/IntelliJIdea#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/IntelliJIdea#{version.major_minor}",
  ]
end
