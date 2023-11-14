# frozen_string_literal: true

require "cgi"
require "dtext" # Load the C extension.

# The DText class handles Danbooru's markup language, DText. Parsing DText is
# handled by the DTextRagel class in the dtext_rb gem.
#
# @see https://github.com/evazion/dtext_rb
# @see https://danbooru.donmai.us/wiki_pages/help:dtext
class DText
  MENTION_REGEXP = /(?<=^| )@\S+/

  # Convert a string of DText to HTML.
  # @param text [String] The DText input
  # @param inline [Boolean] if true, allow only inline constructs. Ignore
  #   block-level constructs, such as paragraphs, quotes, lists, and tables.
  # @param disable_mentions [Boolean] if true, don't generate @mentions.
  # @param base_url [String, nil] if present, convert relative URLs to absolute URLs.
  # @param domain [String, nil] If present, treat links to this domain as internal links rather than external links.
  # @param alternate_domains [Array<String>] A list of additional domains for this site where direct links will be
  #   converted to shortlinks (e.g on betabooru.donmai.us, https://danbooru.donmai.us/posts/1234 is converted to post #1234).
  # @param data cached wiki/tag/artist data generated by {#preprocess}.
  # @return [String, nil] The HTML output
  def self.format_text(text, data: nil, inline: false, disable_mentions: false, base_url: nil, domain: Danbooru.config.hostname, alternate_domains: Danbooru.config.alternate_domains)
    return nil if text.nil?
    data = preprocess([text]) if data.nil?
    text = parse_embedded_tag_request(text)
    html = DText.parse(text, inline: inline, disable_mentions: disable_mentions, base_url: base_url, domain: domain, internal_domains: [domain, *alternate_domains].compact_blank)
    html = postprocess(html, *data)
    html
  rescue DText::Error
    ""
  end

  # Preprocess a set of DText messages and collect all tag, artist, and wiki
  # page references. Called before rendering a collection of DText messages
  # (e.g. comments or forum posts) to do all database lookups in one batch.
  # @param [Array<String>] a list of DText strings
  # @return an array of wiki pages, tags, and artists
  def self.preprocess(dtext_messages)
    dtext_messages = dtext_messages.map { |message| parse_embedded_tag_request(message) }
    names = dtext_messages.map { |message| parse_wiki_titles(message) }.flatten.uniq
    wiki_pages = WikiPage.where(title: names)
    tags = Tag.where(name: names)
    artists = Artist.where(name: names)

    [wiki_pages, tags, artists]
  end

  # Rewrite the HTML produced by {#format_text} to colorize wiki links.
  # @param wiki_pages [Array<WikiPage>]
  # @param tags [Array<Tag>]
  # @param artists [Array<Artist>]
  # @return [String] the HTML output
  def self.postprocess(html, wiki_pages, tags, artists)
    fragment = parse_html(html)

    fragment.css("a.dtext-wiki-link").each do |node|
      path = Addressable::URI.parse(node["href"]).path
      name = path[%r!\A/wiki_pages/(.*)\z!i, 1]
      name = CGI.unescape(name)
      name = WikiPage.normalize_title(name)
      wiki = wiki_pages.find { |wiki| wiki.title == name }
      tag = tags.find { |tag| tag.name == name }
      artist = artists.find { |artist| artist.name == name }

      if tag.present?
        node["class"] += " tag-type-#{tag.category}"
      end

      if tag.present? && tag.artist?
        node["href"] = "/artists/show_or_new?name=#{CGI.escape(name)}"

        if artist.blank?
          node["class"] += " dtext-artist-does-not-exist"
          node["title"] = "This artist page does not exist"
        end
      else
        if wiki.blank?
          node["class"] += " dtext-wiki-does-not-exist"
          node["title"] = "This wiki page does not exist"
        end

        if WikiPage.is_meta_wiki?(name)
          # skip (meta wikis aren't expected to have a tag)
        elsif tag.blank?
          node["class"] += " dtext-tag-does-not-exist"
          node["title"] = "This wiki page does not have a tag"
        elsif tag.empty?
          node["class"] += " dtext-tag-empty"
          node["title"] = "This wiki page does not have a tag"
        end
      end
    end

    fragment.to_s
  end

  # Wrap a DText message in a [quote] block.
  # @param message [String] the DText to quote
  # @param creator_name [String] the name of the user to quote.
  # @return [String] the quoted DText
  def self.quote(message, creator_name)
    stripped_body = DText.strip_blocks(message, "quote")
    "[quote]\n#{creator_name} said:\n\n#{stripped_body}\n[/quote]\n\n"
  end

  # Convert `[bur:<id>]`, `[ta:<id>]`, `[ti:<id>]` tags to DText.
  # @param text [String] the DText input
  # @return [String] the DText output
  def self.parse_embedded_tag_request(text)
    text = parse_embedded_tag_request_type(text, TagAlias, /\[ta:(?<id>\d+)\]/m)
    text = parse_embedded_tag_request_type(text, TagImplication, /\[ti:(?<id>\d+)\]/m)
    text = parse_embedded_tag_request_type(text, BulkUpdateRequest, /\[bur:(?<id>\d+)\]/m)
    text
  end

  # Convert a `[bur:<id>]`, `[ta:<id>]`, or `[ti:<id>]` tag to DText.
  # @param text [String] the DText input
  # @param tag_request [BulkUpdateRequest, TagAlias, TagImplication]
  # @param pattern [Regexp]
  # @return [String] the DText output
  def self.parse_embedded_tag_request_type(text, tag_request, pattern)
    text.gsub(pattern) do |match|
      obj = tag_request.find_by_id($~[:id])
      tag_request_message(obj) || match
    end
  end

  # Convert a `[bur:<id>]`, `[ta:<id>]`, or `[ti:<id>]` tag to DText.
  # @param obj [BulkUpdateRequest, TagAlias, TagImplication] the object to convert
  # @return [String] the DText output
  def self.tag_request_message(obj)
    if obj.is_a?(TagRelationship)
      if obj.is_active?
        "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] has been approved."
      elsif obj.is_retired?
        "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] has been retired."
      elsif obj.is_deleted?
        "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] has been rejected."
      elsif obj.is_pending?
        "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] is pending approval."
      else # should never happen
        "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] has an unknown status."
      end
    elsif obj.is_a?(BulkUpdateRequest)
      if obj.script.size < 700
        embedded_script = obj.processor.to_dtext
      else
        embedded_script = "[expand]#{obj.processor.to_dtext}[/expand]"
      end

      case obj.status
      when "approved"
        "The \"bulk update request ##{obj.id}\":#{Routes.bulk_update_request_path(obj)} has been approved by <@#{obj.approver.name}>.\n\n#{embedded_script}"
      when "pending"
        "The \"bulk update request ##{obj.id}\":#{Routes.bulk_update_request_path(obj)} is pending approval.\n\n#{embedded_script}"
      when "rejected"
        "The \"bulk update request ##{obj.id}\":#{Routes.bulk_update_request_path(obj)} has been rejected.\n\n#{embedded_script}"
      when "processing"
        "The \"bulk update request ##{obj.id}\":#{Routes.bulk_update_request_path(obj)} is being processed.\n\n#{embedded_script}"
      when "failed"
        "The \"bulk update request ##{obj.id}\":#{Routes.bulk_update_request_path(obj)} has failed.\n\n#{embedded_script}"
      else
        raise ArgumentError, "unknown bulk update request status"
      end
    end
  end

  # Return a list of user names mentioned in a string of DText. Ignore mentions in [quote] blocks.
  # @param text [String] the string of DText
  # @return [Array<String>] the list of user names
  def self.parse_mentions(text)
    text = strip_blocks(text.to_s, "quote")

    names = text.scan(MENTION_REGEXP).map do |mention|
      mention.gsub(/(?:^\s*@)|(?:[:;,.!?\)\]<>]$)/, "")
    end

    names.uniq
  end

  # Return a list of wiki pages mentioned in a string of DText.
  # @param text [String] the string of DText
  # @return [Array<String>] the list of wiki page names
  def self.parse_wiki_titles(text)
    html = DText.parse(text)
    fragment = parse_html(html)

    titles = fragment.css("a.dtext-wiki-link").map do |node|
      title = node["href"][%r{\A/wiki_pages/(.*)\z}i, 1]
      title = CGI.unescape(title)
      title = WikiPage.normalize_title(title)
      title
    end

    titles.uniq
  end

  # Return a list of external links mentioned in a string of DText.
  # @param text [String] the string of DText
  # @return [Array<String>] the list of external URLs
  def self.parse_external_links(text)
    html = DText.parse(text)
    fragment = parse_html(html)

    links = fragment.css("a.dtext-external-link").map { |node| node["href"] }
    links.uniq
  end

  # Return whether the two strings of DText have the same set of links.
  # @param a [String] a string of DText
  # @param b [String] a string of DText
  # @return [Boolean]
  def self.dtext_links_differ?(a, b)
    Set.new(parse_wiki_titles(a)) != Set.new(parse_wiki_titles(b)) ||
      Set.new(parse_external_links(a)) != Set.new(parse_external_links(b))
  end

  # Rewrite wiki links to [[old_name]] with [[new_name]]. We attempt to match
  # the capitalization of the old tag when rewriting it to the new tag, but if
  # we can't determine how the new tag should be capitalized based on some
  # simple heuristics, then we skip rewriting the tag.
  # @param dtext [String] the DText input
  # @param old_name [String] the old wiki name
  # @param new_name [String] the new wiki name
  # @return [String] the DText output
  def self.rewrite_wiki_links(dtext, old_name, new_name)
    old_name = old_name.downcase.squeeze("_").tr("_", " ").strip
    new_name = new_name.downcase.squeeze("_").tr("_", " ").strip

    # Match `[[name]]` or `[[name|title]]`
    dtext.gsub(/\[\[(.*?)(?:\|(.*?))?\]\]/) do |match|
      name = $1
      title = $2

      # Skip this link if it isn't the tag we're trying to replace.
      normalized_name = name.downcase.tr("_", " ").squeeze(" ").strip
      next match if normalized_name != old_name

      # Strip qualifiers, e.g. `atago (midsummer march) (azur lane)` => `atago`
      unqualified_name = name.tr("_", " ").squeeze(" ").strip.gsub(/( \(.*\))+\z/, "")

      # If old tag was lowercase, e.g. [[ink tank (Splatoon)]], then keep new tag in lowercase.
      if unqualified_name == unqualified_name.downcase
        final_name = new_name
      # If old tag was capitalized, e.g. [[Colored pencil (medium)]], then capitialize new tag.
      elsif unqualified_name == unqualified_name.downcase.capitalize
        final_name = new_name.capitalize
      # If old tag was in titlecase, e.g. [[Hatsune Miku (cosplay)]], then titlecase new tag.
      elsif unqualified_name == unqualified_name.split.map(&:capitalize).join(" ")
        final_name = new_name.split.map(&:capitalize).join(" ")
      # If we can't determine how to capitalize the new tag, then keep the old tag.
      # e.g. [[Suzumiya Haruhi no Yuuutsu]] -> [[The Melancholy of Haruhi Suzumiya]]
      else
        next match
      end

      if title.present?
        "[[#{final_name}|#{title}]]"
      # If the new name has a qualifier, then hide the qualifier in the link.
      elsif final_name.match?(/( \(.*\))+\z/)
        "[[#{final_name}|]]"
      else
        "[[#{final_name}]]"
      end
    end
  end

  # Remove all [<tag>] blocks from the DText.
  # @param string [String] the DText input
  # @param tag [String] the type of block to remove
  # @return [String] the DText output
  def self.strip_blocks(string, tag)
    n = 0
    stripped = "".dup
    string = string.dup

    string.gsub!(/\s*\[#{tag}\](?!\])\s*/mi, "\n\n[#{tag}]\n\n")
    string.gsub!(%r{\s*\[/#{tag}\]\s*}mi, "\n\n[/#{tag}]\n\n")
    string.gsub!(/(?:\r?\n){3,}/, "\n\n")
    string.strip!

    string.split(/\n{2}/).each do |block|
      case block
      when "[#{tag}]"
        n += 1

      when "[/#{tag}]"
        n -= 1

      else
        if n == 0
          stripped << "#{block}\n\n"
        end
      end
    end

    stripped.strip
  end

  # Remove all DText formatting from a string of DText, converting it to plain text.
  # @param dtext [String] the DText input
  # @return [String] the plain text output
  def self.strip_dtext(dtext)
    html = DText.parse(dtext)
    text = to_plaintext(html)
    text
  end

  # Remove all formatting from a string of HTML, converting it to plain text.
  # @param html [String] the HTML input
  # @return [String] the plain text output
  def self.to_plaintext(html)
    text = from_html(html) do |node|
      case node.name
      when "a", "strong", "em", "u", "s", "h1", "h2", "h3", "h4", "h5", "h6"
        node.name = "span"
        node.content = node.text
      when "blockquote"
        node.name = "span"
        node.content = to_plaintext(node.inner_html).gsub(/^/, "> ")
      when "details"
        node.name = "span"
        node.content = to_plaintext(node.css("div").inner_html)
      end
    end

    text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
  end

  # Convert DText formatting to Markdown.
  # @param dtext [String] the DText input
  # @return [String] the Markdown output
  def self.to_markdown(dtext)
    html_to_markdown(format_text(dtext))
  end

  # Convert HTML to Markdown.
  # @param html [String] the HTML input
  # @return [String] the Markdown output
  def self.html_to_markdown(html)
    html = parse_html(html)

    html.children.map do |node|
      case node.name
      when "div", "blockquote", "table"
        "" # strip [expand], [quote], and [table] tags
      when "br"
        "\n"
      when "text"
        node.text.gsub(/_/, '\_').gsub(/\*/, '\*')
      when "p", "h1", "h2", "h3", "h4", "h5", "h6"
        html_to_markdown(node.inner_html) + "\n\n"
      else
        html_to_markdown(node.inner_html)
      end
    end.join
  end

  # Convert HTML to DText.
  # @param html [String] the HTML input
  # @param inline [Boolean] if true, convert <img> tags to plaintext
  # @return [String] the DText output
  def self.from_html(text, inline: false, &block)
    html = parse_html(text)

    dtext = html.children.map do |element|
      block.call(element) if block.present?

      case element.name
      when "text"
        element.content.gsub(/(?:\r|\n)+$/, "")
      when "br"
        "\n"
      when "p", "ul", "ol"
        from_html(element.inner_html, &block).strip + "\n\n"
      when "blockquote"
        "[quote]#{from_html(element.inner_html, &block).strip}[/quote]\n\n" if element.inner_html.present?
      when "small", "sub"
        "[tn]#{from_html(element.inner_html, &block)}[/tn]" if element.inner_html.present?
      when "b", "strong"
        "[b]#{from_html(element.inner_html, &block)}[/b]" if element.inner_html.present?
      when "i", "em"
        "[i]#{from_html(element.inner_html, &block)}[/i]" if element.inner_html.present?
      when "u"
        "[u]#{from_html(element.inner_html, &block)}[/u]" if element.inner_html.present?
      when "s", "strike"
        "[s]#{from_html(element.inner_html, &block)}[/s]" if element.inner_html.present?
      when "li"
        "* #{from_html(element.inner_html, &block)}\n" if element.inner_html.present?
      when "h1", "h2", "h3", "h4", "h5", "h6"
        hN = element.name
        title = from_html(element.inner_html, &block)
        "#{hN}. #{title}\n\n"
      when "a"
        title = from_html(element.inner_html, inline: true, &block).strip
        url = element["href"]

        if title.blank? || url.blank?
          ""
        elsif title == url
          "<#{url}>"
        else
          %("#{title}":[#{url}])
        end
      when "img"
        alt_text = element.attributes["title"] || element.attributes["alt"] || ""
        src = element["src"]

        if inline
          alt_text
        elsif alt_text.present? && src.present?
          %("#{alt_text}":[#{src}]\n\n)
        else
          ""
        end
      when "comment"
        # ignored
      else
        from_html(element.inner_html, &block)
      end
    end.join

    dtext
  end

  # Return the first paragraph the search string `needle` occurs in.
  # @param needle [String] the string to search for
  # @param dtext [String] the DText input
  # @return [String] the first paragraph mentioning the search string
  def self.extract_mention(dtext, needle)
    dtext = dtext.gsub(/\r\n|\r|\n/, "\n")
    excerpt = ActionController::Base.helpers.excerpt(dtext, needle, separator: "\n\n", radius: 1, omission: "")
    excerpt
  end

  # Generate a short plain text excerpt from a DText string.
  # @param length [Integer] the max length of the output
  # @return [String] a plain text string
  def self.excerpt(text, length: 160)
    strip_dtext(text).split(/\r\n|\r|\n/).first.to_s.truncate(length)
  end

  # Parse a string of HTML to a document object.
  # @param html [String]
  # @return [Nokogiri::HTML5::DocumentFragment]
  def self.parse_html(html)
    Nokogiri::HTML5.fragment(html, max_tree_depth: -1)
  end
end
