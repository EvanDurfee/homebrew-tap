cask "jetbrains-idea" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.4,252.27397.103"
  sha256 x86_64_linux: "4d909f989d7fa0a002f5bc669e002e8ab336ee7091f32756a74549cd8c11f432",
         arm64_linux:  "f5687e1d0dc416d6f0fb89495d2b4ad4639d4896497db245272d1fe697b1037b"

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
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-idea-eap"]

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
      Exec=#{HOMEBREW_PREFIX}/bin/idea %u
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
