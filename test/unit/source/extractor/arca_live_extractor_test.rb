require "test_helper"

module Source::Tests::Extractor
  class ArcaLiveExtractorTest < ActiveSupport::TestCase
    context "An Arca.live page URL" do
      strategy_should_work(
        "https://arca.live/b/arknights/66031722?p=1",
        image_urls: [
          %r{https://ac\.namu\.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5\.jpg\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        media_files: [{ file_size: 273_206 }],
        profile_urls: %w[https://arca.live/u/@Si리링],
        page_url: "https://arca.live/b/arknights/66031722",
        display_name: nil,
        username: "Si리링",
        artist_commentary_title: "엑샤 스작함",
        dtext_artist_commentary_desc: "알게또 뽑으려했는데 못뽑아서 엑샤 스작함\n엑샤에 보카디 3스나 와파린 2스 붙이는거 맞음?",
        tags: [],
      )
    end

    context "An Arca.live image URL with a referer" do
      strategy_should_work(
        "https://ac.namu.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg\?expires=1750243516&key=mQiH3KTgkEkAEDjO4GfTlA",
        referer: "https://arca.live/b/arknights/66031722?p=1",
        image_urls: [
          %r{https://ac\.namu\.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5\.jpg\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        media_files: [{ file_size: 273_206 }],
        profile_urls: %w[https://arca.live/u/@Si리링],
        page_url: "https://arca.live/b/arknights/66031722",
        display_name: nil,
        username: "Si리링",
        artist_commentary_title: "엑샤 스작함",
        dtext_artist_commentary_desc: "알게또 뽑으려했는데 못뽑아서 엑샤 스작함\n엑샤에 보카디 3스나 와파린 2스 붙이는거 맞음?",
        tags: [],
      )
    end

    context "An Arca.live image URL without a referer" do
      strategy_should_work(
        "https://ac.namu.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg\?expires=1750243516&key=mQiH3KTgkEkAEDjO4GfTlA",
        image_urls: [
          %r{https://ac\.namu\.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5\.jpg\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        media_files: [{ file_size: 273_206 }],
        profile_urls: [],
        page_url: nil,
        display_name: nil,
        username: nil,
        artist_commentary_title: nil,
        dtext_artist_commentary_desc: "",
        tags: [],
      )
    end

    context "An Arca.live /b/breaking page URL" do
      strategy_should_work(
        "https://arca.live/b/breaking/66031722",
        image_urls: [
          %r{https://ac\.namu\.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5\.jpg\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        media_files: [{ file_size: 273_206 }],
        profile_urls: %w[https://arca.live/u/@Si리링],
        page_url: "https://arca.live/b/arknights/66031722",
        display_name: nil,
        username: "Si리링",
        artist_commentary_title: "엑샤 스작함",
        dtext_artist_commentary_desc: "알게또 뽑으려했는데 못뽑아서 엑샤 스작함\n엑샤에 보카디 3스나 와파린 2스 붙이는거 맞음?",
        tags: [],
      )
    end

    context "An Arca.live page URL with an animated .gif" do
      strategy_should_work(
        "https://arca.live/b/bluearchive/65031202",
        image_urls: [
          %r{https://ac\.namu\.la/20221211sac/5ea7fbca5e49ec16beb099fc6fc991690d37552e599b1de8462533908346241e\.png\?expires=\d+&key=[\w_-]+&type=orig},
          %r{https://ac\.namu\.la/20221211sac/7f73beefc4f18a2f986bc4c6821caba706e27f4c94cb828fc16e2af1253402d9\.gif\?expires=\d+&key=[\w_-]+&type=orig},
          %r{https://ac\.namu\.la/20221211sac2/3e72f9e05ca97c0c3c0fe5f25632b06eb21ab9f211e9ea22816e16468ee241ca\.png\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        media_files: [
          { file_size: 28_519 },
          { file_size: 2_016_818 },
          { file_size: 887_464 },
        ],
        profile_urls: %w[https://arca.live/u/@맛있는팥양갱],
        page_url: "https://arca.live/b/bluearchive/65031202",
        display_name: nil,
        username: "맛있는팥양갱",
        artist_commentary_title: "스포)부들부들 떠는 아리스 그림 점프 추가해봤어",
        dtext_artist_commentary_desc: "스포방지짤\n움짤 만들기 귀찮은데 재밌다\n안움직이는 버젼",
        tags: [],
      )
    end

    context "An Arca.live page URL with an animated .webp" do
      strategy_should_work(
        "https://arca.live/b/arknights/122263340",
        image_urls: [
          %r{https://ac\.namu\.la/20241126sac/b2175d9ef4504945d3d989526120dbb6aded501ddedfba8ecc44a64e7aae9059\.gif\?expires=\d+&key=[\w_-]+&type=orig},
          %r{https://ac\.namu\.la/20241126sac/bc1f3cb388a3a2d099ab67bc09b28f0a93c2c4755152b3ef9190690a9f0a28fb\.webp\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        media_files: [
          { file_size: 749_653 },
          { file_size: 3_918_854 },
        ],
        page_url: "https://arca.live/b/arknights/122263340",
        profile_urls: %w[https://arca.live/u/@음악한모금],
        display_name: nil,
        username: "음악한모금",
        tags: [],
        dtext_artist_commentary_title: "스즈맘 모금콘 마따끄, 코로스 콘 추가했습니다",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          많이 써주세요
          감사합니다
        EOS
      )
    end

    context "An Arca.live page URL with an .mp4 video" do
      strategy_should_work(
        "https://arca.live/b/bluearchive/117240135",
        image_urls: [
          %r{https://ac\.namu\.la/20240926sac/16f07778a97f91b935c8a3394ead01a223d96b2a619fdb25c4628ddba88b5fad\.mp4\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        media_files: [{ file_size: 1_687_382 }],
        page_url: "https://arca.live/b/bluearchive/117240135",
        profile_urls: %w[https://arca.live/u/@horuhara/77430289],
        display_name: nil,
        username: "horuhara",
        tags: [],
        dtext_artist_commentary_title: "말랑고양이 마구 흔들기.mp4",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          말랑하네요
          "더 말랑하고 귀여운 그림 보러가기":[https://x.com/horuhara/status/1839132898785636671?t=RtemijMNpG1bdpziXac6-Q&s=19]
        EOS
      )
    end

    context "An Arca.live page URL with a fake .mp4 GIF" do
      strategy_should_work(
        "https://arca.live/b/bluearchive/111191955",
        image_urls: [
          %r{https://ac\.namu\.la/20240714sac/c8fcadeb0b578e5121eb7a7e8fb05984cb87c68e7a6e0481a1c8869bf0ecfd2b\.gif\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        media_files: [{ file_size: 1_284_465 }],
        page_url: "https://arca.live/b/bluearchive/111191955",
        profile_urls: %w[https://arca.live/u/@horuhara/77430289],
        display_name: nil,
        username: "horuhara",
        tags: [],
        dtext_artist_commentary_title: "바로 들기 마려운 말랑말랑 마리.gif",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          바로 들어서 높이높이 할거임
          <https://x.com/horuhara/status/1812316701817811068?t=8SumD241f8myyzgB8bobSA&s=19>
        EOS
      )
    end

    context "An Arca.live page URL with a static emoticon" do
      strategy_should_work(
        "https://arca.live/b/arknights/49406926",
        image_urls: [
          %r{https://ac\.namu\.la/20220428sac2/41f472adcea674aff75f15f146e81c27032bc4d6c8073bd7c19325bd1c97d335\.png\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        profile_urls: %w[https://arca.live/u/@유즈비],
        page_url: "https://arca.live/b/arknights/49406926",
        display_name: nil,
        username: "유즈비",
        artist_commentary_title: "누비 솜털이 그려왔어",
        dtext_artist_commentary_desc: "그리고 있으니까 픽업 뚫고 나와주겠지...?",
        tags: [],
      )
    end

    context "An Arca.live page URL with an animated emoticon" do
      strategy_should_work(
        "https://arca.live/b/commission/63658702",
        image_urls: [
          %r{https://ac\.namu\.la/20221123sac2/14925c5e22ab9f17f2923ae60a39b7af0794c43e478ecaba054ab6131e57e022\.png\?expires=\d+&key=[\w_-]+&type=orig},
          %r{https://ac\.namu\.la/20221123sac2/50c385a4004bca44271a2f6133990f086cfefd29a7968514e9c14d6017d61265\.png\?expires=\d+&key=[\w_-]+&type=orig},
        ],
        profile_urls: %w[https://arca.live/u/@크림/55256970],
        page_url: "https://arca.live/b/commission/63658702",
        display_name: nil,
        username: "크림",
        artist_commentary_title: "최고로 이쁜 산짤써맛이에용",
        dtext_artist_commentary_desc: "울이쁜이들과함께 같이 다과회를 즐겨요",
        tags: [],
      )
    end
  end
end
