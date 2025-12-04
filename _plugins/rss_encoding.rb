Jekyll::Hooks.register :site, :post_write do |site|
  # Ensure RSS files are served with UTF-8 encoding
  if Jekyll.env == "development"
    # For local development, we can't easily modify headers,
    # but we can ensure the file is properly formatted
    rss_path = File.join(site.dest, "podcast.rss")
    if File.exist?(rss_path)
      content = File.read(rss_path, encoding: "UTF-8")
      File.write(rss_path, content, encoding: "UTF-8")
    end
  end
end

