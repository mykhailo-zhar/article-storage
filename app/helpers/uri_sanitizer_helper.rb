module UriSanitizerHelper
  def self.safe_external_url(url)
    return if url.blank?

    uri = URI.parse(url.to_s)
    return url if uri.is_a?(URI::HTTP) && uri.host.present?

    nil
  rescue URI::InvalidURIError
    nil
  end
end
