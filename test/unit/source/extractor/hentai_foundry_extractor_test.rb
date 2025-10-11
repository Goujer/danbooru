require "test_helper"

module Source::Tests::Extractor
  class HentaiFoundryExtractorTest < ActiveSupport::TestCase
    context "A hentai-foundry post" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/Afrobull/795025/kuroeda",
        image_urls: ["https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png"],
        username: "Afrobull",
        artist_commentary_title: "kuroeda",
        profile_url: "https://www.hentai-foundry.com/user/Afrobull",
        media_files: [{ file_size: 1_349_887 }],
        tags: [["elf", "https://www.hentai-foundry.com/pictures/tagged/elf"]],
      )
    end

    context "A hentai-foundry picture" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/Afrobull/795025/kuroeda",
        image_urls: ["https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png"],
        username: "Afrobull",
        artist_commentary_title: "kuroeda",
        profile_url: "https://www.hentai-foundry.com/user/Afrobull",
        media_files: [{ file_size: 1_349_887 }],
        tags: [["elf", "https://www.hentai-foundry.com/pictures/tagged/elf"]],
      )
    end

    context "A deleted picture" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/faustsketcher/279498",
        image_urls: [],
        username: "faustsketcher",
        profile_url: "https://www.hentai-foundry.com/user/faustsketcher",
        deleted: true,
      )
    end

    context "An old image url" do
      strategy_should_work(
        "http://pictures.hentai-foundry.com//a/AnimeFlux/219123.jpg",
        image_urls: ["https://pictures.hentai-foundry.com/a/AnimeFlux/219123/AnimeFlux-219123-Mobile_Suit_Equestria_rainbow_run.jpg"],
        page_url: "https://www.hentai-foundry.com/pictures/user/AnimeFlux/219123",
        profile_url: "https://www.hentai-foundry.com/user/AnimeFlux",
      )
    end

    context "An image url without the extension" do
      strategy_should_work(
        "http://www.hentai-foundry.com/pictures/user/Ganassa/457176/LOL-Swimsuit---Caitlyn-reworked-nude-ver.",
        image_urls: ["https://pictures.hentai-foundry.com/g/Ganassa/457176/Ganassa-457176-LOL_Swimsuit_-_Caitlyn_reworked_nude_ver..jpg"],
        page_url: "https://www.hentai-foundry.com/pictures/user/Ganassa/457176",
        profile_url: "https://www.hentai-foundry.com/user/Ganassa",
      )
    end

    context "A post with deeply nested commentary" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/LumiNyu/867562/Mona-patreon-winner",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          [b]If you like this picture don't forget to thumbs up and favorite
          [/b][b]"Also you can support my art on ":[https://picarto.tv/LumiNyu][/b][b]"Patreon":[https://www.patreon.com/LumiNyu] and gain instant access to exclusive "patreon":[https://www.patreon.com/LumiNyu] content and also be able to vote for the future set of girls I should draw.[/b]
        EOS
      )
    end

    context "A post with commentary containing quote marks inside the links" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/QueenComplex/1079933/Fucc",
        image_urls: %w[https://pictures.hentai-foundry.com/q/QueenComplex/1079933/QueenComplex-1079933-Fucc.jpg],
        media_files: [{ file_size: 239_826 }],
        page_url: "https://www.hentai-foundry.com/pictures/user/QueenComplex/1079933",
        profile_urls: %w[https://www.hentai-foundry.com/user/QueenComplex],
        display_name: nil,
        username: "QueenComplex",
        tags: [
          ["Beast_Boy", "https://www.hentai-foundry.com/pictures/tagged/Beast_Boy"],
          ["Foursome", "https://www.hentai-foundry.com/pictures/tagged/Foursome"],
          ["Orgy", "https://www.hentai-foundry.com/pictures/tagged/Orgy"],
          ["QueenComplex", "https://www.hentai-foundry.com/pictures/tagged/QueenComplex"],
          ["Raven", "https://www.hentai-foundry.com/pictures/tagged/Raven"],
          ["Robin", "https://www.hentai-foundry.com/pictures/tagged/Robin"],
          ["Starfire", "https://www.hentai-foundry.com/pictures/tagged/Starfire"],
          ["Teen-Titans", "https://www.hentai-foundry.com/pictures/tagged/Teen-Titans"],
        ],
        dtext_artist_commentary_title: "Fucc",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          It's a 4th piece in a set of 6
          Previous ones being - This is a sequel to my drawings "[b]&quot;Butts&quot;[/b]":[https://www.newgrounds.com/art/view/queencomplex/butts], "[b]&quot;Bubbs&quot;[/b]":[https://www.newgrounds.com/art/view/queencomplex/bubbs] and "[b]&quot;Diccs&quot;[/b]":[https://www.newgrounds.com/art/view/queencomplex/diccs]
          "[b]QUEENCOMPLEX.NET[/b]":[https://queencomplex.net/]
          The place to see my newest drawings
          and the place to support my work.
          "[b]@Queen_Complexxx[/b]":[https://twitter.com/Queen_Complexxx] - My Twitter
          "[b]mail@queencomplex.net[/b]":[mailto:<span style=]"&quot;>[b]mail@queencomplex.net[/b]":[mailto:<span style=] - My main Email
        EOS
      )
    end
  end
end
