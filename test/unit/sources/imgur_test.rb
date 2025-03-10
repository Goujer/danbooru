require "test_helper"

module Sources
  class ImgurTest < ActiveSupport::TestCase
    context "Imgur:" do
      context "A direct image URL" do
        strategy_should_work(
          "https://i.imgur.com/AOeREEF.png",
          image_urls: %w[
            https://i.imgur.com/AOeREEF.png
          ],
          page_url: "https://imgur.com/AOeREEF",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: "",
          dtext_artist_commentary_desc: "Karl franz.",
          tags: [],
          media_files: [{ file_size: 1_360_409 }],
        )
      end

      context "A `imgur.com/$file.$ext` URL" do
        strategy_should_work(
          "https://imgur.com/AOeREEF.png",
          image_urls: %w[
            https://i.imgur.com/AOeREEF.png
          ],
          page_url: "https://imgur.com/AOeREEF",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: "",
          dtext_artist_commentary_desc: "Karl franz.",
          tags: [],
          media_files: [{ file_size: 1_360_409 }],
        )
      end

      context "A 7-character sample image URL" do
        strategy_should_work(
          "https://i.imgur.com/AOeREEFl.png",
          image_urls: %w[
            https://i.imgur.com/AOeREEF.png
          ],
          page_url: "https://imgur.com/AOeREEF",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: "",
          dtext_artist_commentary_desc: "Karl franz.",
          tags: [],
          media_files: [{ file_size: 1_360_409 }],
        )
      end

      context "A 5-character sample image URL" do
        strategy_should_work(
          "https://i.imgur.com/kJ2FLm.jpg",
          image_urls: %w[
            https://i.imgur.com/kJ2FL.jpg
          ],
          page_url: "https://imgur.com/kJ2FL",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: "Bow Dash",
          dtext_artist_commentary_desc: "",
          tags: [],
          media_files: [{ file_size: 106_895 }],
        )
      end

      context "An image page URL" do
        strategy_should_work(
          "https://imgur.com/AOeREEF",
          image_urls: %w[
            https://i.imgur.com/AOeREEF.png
          ],
          page_url: "https://imgur.com/AOeREEF",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: "",
          dtext_artist_commentary_desc: "Karl franz.",
          tags: [],
        )
      end

      context "A direct image URL with album referer" do
        strategy_should_work(
          "https://i.imgur.com/AOeREEF.png",
          referer: "https://imgur.com/a/0BDNq",
          image_urls: %w[
            https://i.imgur.com/AOeREEF.png
          ],
          page_url: "https://imgur.com/a/0BDNq",
          profile_url: "https://imgur.com/user/naugrim2875",
          artist_name: "naugrim2875",
          artist_commentary_title: "Random warhammer stuff.",
          dtext_artist_commentary_desc: "",
          tags: %w[inktober warhammer anime drawings art],
        )
      end

      context "An album URL" do
        strategy_should_work(
          "https://imgur.com/a/0BDNq",
          image_urls: %w[
            https://i.imgur.com/AOeREEF.png
            https://i.imgur.com/CAUL554.png
            https://i.imgur.com/aVy85Wc.jpeg
            https://i.imgur.com/hEtFhQs.jpeg
          ],
          page_url: "https://imgur.com/a/0BDNq",
          profile_url: "https://imgur.com/user/naugrim2875",
          artist_name: "naugrim2875",
          artist_commentary_title: "Random warhammer stuff.",
          dtext_artist_commentary_desc: "",
          tags: %w[inktober warhammer anime drawings art],
        )
      end

      context "A .gifv URL" do
        strategy_should_work(
          "https://i.imgur.com/Kp9TdlX.gifv",
          image_urls: %w[
            https://i.imgur.com/Kp9TdlX.gif
          ],
          page_url: "https://imgur.com/Kp9TdlX",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: "",
          dtext_artist_commentary_desc: "",
          tags: [],
          media_files: [{ file_size: 3_818_049 }],
        )
      end

      context "A .mp4 sample of a .gif image" do
        strategy_should_work(
          "https://i.imgur.com/Kp9TdlX.mp4",
          image_urls: %w[
            https://i.imgur.com/Kp9TdlX.gif
          ],
          page_url: "https://imgur.com/Kp9TdlX",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: "",
          dtext_artist_commentary_desc: "",
          tags: [],
          media_files: [{ file_size: 3_818_049 }],
        )
      end

      context "A hidden (unlisted) album" do
        strategy_should_work(
          "https://imgur.com/a/2tWSH1c",
          image_urls: %w[],
          page_url: "https://imgur.com/a/2tWSH1c",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: nil,
          dtext_artist_commentary_desc: "",
          tags: [],
        )
      end

      context "A new anonymous album" do
        strategy_should_work(
          "https://imgur.com/a/ngrBZUg",
          image_urls: %w[
            https://i.imgur.com/E8CE6BM.jpg
            https://i.imgur.com/FN1DRIe.png
            https://i.imgur.com/MdCdHkV.png
          ],
          page_url: "https://imgur.com/a/ngrBZUg",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: "FuwaMoco reaction faces",
          dtext_artist_commentary_desc: "",
          tags: [],
        )
      end

      should "Parse Imgur URLs correctly" do
        assert(Source::URL.image_url?("https://i.imgur.com/c7EXjJu.jpeg"))
        assert(Source::URL.image_url?("https://i.imgur.io/c7EXjJu.jpeg"))
        assert(Source::URL.image_url?("https://imgur.com/c7EXjJu.jpeg"))
        assert(Source::URL.image_url?("https://imgur.com/download/c7EXjJu/"))

        assert(Source::URL.page_url?("https://imgur.com/c7EXjJu"))
        assert(Source::URL.page_url?("https://imgur.io/c7EXjJu"))
        assert(Source::URL.page_url?("https://imgur.com/gallery/0BDNq"))
        assert(Source::URL.page_url?("https://imgur.com/a/0BDNq"))
        assert(Source::URL.page_url?("https://imgur.com/t/anime/g0ua0kg"))

        assert(Source::URL.profile_url?("https://imgur.com/user/naugrim2875"))

        assert_equal("c7EXjJu", Source::URL.parse("https://i.imgur.com/c7EXjJu.jpeg").image_id)
        assert_equal("c7EXjJu", Source::URL.parse("https://i.imgur.com/c7EXjJum.jpeg").image_id)
        assert_equal("c7EXjJu", Source::URL.parse("https://i.imgur.com/c7EXjJu_d.jpeg").image_id)
        assert_equal("c7EXjJu", Source::URL.parse("https://imgur.com/c7EXjJu.jpeg").image_id)

        assert_equal("kJ2FL", Source::URL.parse("https://i.imgur.com/kJ2FL.jpeg").image_id)
        assert_equal("kJ2FL", Source::URL.parse("https://i.imgur.com/kJ2FLm.jpeg").image_id)
        assert_equal("kJ2FL", Source::URL.parse("https://i.imgur.com/kJ2FL_d.jpeg").image_id)
      end
    end
  end
end
