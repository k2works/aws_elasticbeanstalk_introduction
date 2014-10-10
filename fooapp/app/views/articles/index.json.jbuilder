json.array!(@articles) do |article|
  json.extract! article, :id, :url, :title, :category, :published, :access, :comments_count, :losed
  json.url article_url(article, format: :json)
end
