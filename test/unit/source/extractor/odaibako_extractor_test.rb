require "test_helper"

module Source::Tests::Extractor
  class OdaibakoExtractorTest < ActiveSupport::TestCase
    context "a post URL" do
      strategy_should_work(
        "https://odaibako.net/posts/01923bc559bc0fd9ac983610d654ea2d",
        image_urls: %w[https://ccs.odaibako.net/_/post_images/aaaaaariko/c126b4961cea4a1c9ae016e224db2a62.jpeg],
        media_files: [{ file_size: 696_231 }],
        page_url: "https://odaibako.net/odais/d811a8ae-cc45-4922-9652-d2dcfb9d3492",
        profile_urls: %w[https://odaibako.net/u/aaaaaariko],
        display_name: "ARiKo",
        username: "aaaaaariko",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h6. Original Request

          Wow! Your Azurlane artworks are very cool!! (Suzutsuki💕 Kearsarge💕)
          May I ask you to draw Yoizuki from Azurlane as well?
          If possible, let me show her nipple a little! Her normal outfit is too open to hide her boobs😍

          h6. Artist Response

          Thanks for liking my art!
          Aaand here’s Yoizuki, hope you like it <3
        EOS
      )
    end

    context "an odai URL" do
      strategy_should_work(
        "https://odaibako.net/odais/d811a8ae-cc45-4922-9652-d2dcfb9d3492",
        image_urls: %w[https://ccs.odaibako.net/_/post_images/aaaaaariko/c126b4961cea4a1c9ae016e224db2a62.jpeg],
        media_files: [{ file_size: 696_231 }],
        page_url: "https://odaibako.net/odais/d811a8ae-cc45-4922-9652-d2dcfb9d3492",
        profile_urls: %w[https://odaibako.net/u/aaaaaariko],
        display_name: "ARiKo",
        username: "aaaaaariko",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h6. Original Request

          Wow! Your Azurlane artworks are very cool!! (Suzutsuki💕 Kearsarge💕)
          May I ask you to draw Yoizuki from Azurlane as well?
          If possible, let me show her nipple a little! Her normal outfit is too open to hide her boobs😍

          h6. Artist Response

          Thanks for liking my art!
          Aaand here’s Yoizuki, hope you like it <3
        EOS
      )
    end

    context "a post with multiple images" do
      strategy_should_work(
        "https://odaibako.net/odais/5260af76-be64-447c-9701-c2d74b104643",
        image_urls: %w[
          https://ccs.odaibako.net/_/post_images/zn_bi_nh/00b5b34532da43738dc1d47caf1ae924.jpeg
          https://ccs.odaibako.net/_/post_images/zn_bi_nh/e4106afe1dc246aeb0977d3db129bd10.jpeg
          https://ccs.odaibako.net/_/post_images/zn_bi_nh/419ebaf54b96481e9b23bce88ffa84ac.jpeg
          https://ccs.odaibako.net/_/post_images/zn_bi_nh/df511b8710a349cb89774bb07cbac1d3.jpeg
          https://ccs.odaibako.net/_/post_images/zn_bi_nh/e30a6d9c81734452848d6cc4747f57d0.jpeg
          https://ccs.odaibako.net/_/post_images/zn_bi_nh/0935a74038b040c389b58d43771519ab.jpeg
          https://ccs.odaibako.net/_/post_images/zn_bi_nh/c94806508f2c48449bde5402cb3f9828.jpeg
        ],
        media_files: [
          { file_size: 452_758 },
          { file_size: 480_093 },
          { file_size: 425_878 },
          { file_size: 464_286 },
          { file_size: 451_581 },
          { file_size: 429_118 },
          { file_size: 473_379 },
        ],
        page_url: "https://odaibako.net/odais/5260af76-be64-447c-9701-c2d74b104643",
        profile_urls: %w[https://odaibako.net/u/zn_bi_nh],
        display_name: "亜鉛ビスマス",
        username: "zn_bi_nh",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h6. Original Request

          北海道の温むす全員にチャイナ着せたくなるわね…////////
        EOS
      )
    end

    context "a deleted or nonexistent post" do
      strategy_should_work(
        "https://odaibako.net/odais/4d17c9a0-6125-4a5c-a6ed-243795e69516",
        image_urls: [],
        page_url: "https://odaibako.net/odais/4d17c9a0-6125-4a5c-a6ed-243795e69516",
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "a request without the response" do
      strategy_should_work(
        "https://odaibako.net/odais/21fa2dad-7c69-48ef-9768-885fa6dadf2b",
        image_urls: [],
        page_url: "https://odaibako.net/odais/21fa2dad-7c69-48ef-9768-885fa6dadf2b",
        profile_urls: %w[https://odaibako.net/u/Weakest_Mash],
        display_name: "菌糸🔞",
        username: "Weakest_Mash",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h6. Original Request

          馬乗りになっておっぱいでちんちん擦るのに夢中になってる穹くんを優しい表情で見つめながら受け入れてくれる花火ちゃんをお願いします！
        EOS
      )
    end
  end
end
