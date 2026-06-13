class Kiln < Formula
  desc "Template compiler for GFI (gulp-file-include) syntax"
  homepage "https://github.com/teehemkay/homebrew-kiln"
  version "2026.06.13.01"

  on_macos do
    on_arm do
      url "https://github.com/teehemkay/homebrew-kiln/releases/download/2026.06.13.01/kiln-2026.06.13.01-darwin-arm64"
      sha256 "dd41e57e9a17b6439704aad741312caa844bdb85aa2a7174b5d44db84184013d"
    end
    on_intel do
      url "https://github.com/teehemkay/homebrew-kiln/releases/download/2026.06.13.01/kiln-2026.06.13.01-darwin-x64"
      sha256 "8628afb37466897ec3bbb8792aeabe66bcfb2b9cda358006448827028f991080"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/teehemkay/homebrew-kiln/releases/download/2026.06.13.01/kiln-2026.06.13.01-linux-x64"
      sha256 "b55f74e5a73b39d8819354f24e17682c4e518db342d42ecab132d9121b5120fe"
    end
  end

  def install
    asset = Dir["kiln-*"].first
    chmod 0555, asset
    bin.install asset => "kiln"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kiln --version")
  end
end
