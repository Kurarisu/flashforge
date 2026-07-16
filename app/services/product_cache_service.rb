class ProductCacheService
  CACHE_KEY = "products:all"
  TTL = 1.hour

  def self.fetch_all
    if (cached = Rails.cache.read(CACHE_KEY))
      Rails.logger.info "[ProductCacheService] cache hit #{CACHE_KEY}"
      cached
    else
      Rails.logger.info "[ProductCacheService] cache miss #{CACHE_KEY}"
      products = Product.all.as_json
      Rails.cache.write(CACHE_KEY, products, expires_in: TTL)
      products
    end
  end

  def self.clear
    Rails.logger.info "[ProductCacheService] cache clear #{CACHE_KEY}"
    Rails.cache.delete(CACHE_KEY)
  end
end
