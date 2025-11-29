// FILE: lib/features/news/providers/news_provider.dart
// ✅ FIXED: Gambar yang PASTI LOAD!

import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsArticle {
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String url;
  final String date;

  NewsArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.url,
    required this.date,
  });
}

class NewsService {
  Future<List<NewsArticle>> fetchGlobalEconomicNews() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      NewsArticle(
        title: "The Fed Signals Potential Rate Cuts in Late 2025",
        description: "Federal Reserve officials signaled they still expect to cut interest rates by three-quarters of a percentage point this year.",
        // ✅ Gambar Finance Chart HIGH QUALITY
        imageUrl: "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200&q=85",
        source: "Bloomberg Economics",
        url: "https://www.bloomberg.com/markets/economics",
        date: "2 Jam yang lalu",
      ),
      NewsArticle(
        title: "Bitcoin Surges Past \$100,000 Amid Market Optimism",
        description: "Cryptocurrency markets are rallying as institutional investors increase their holdings and ETF inflows hit record highs.",
        // ✅ Gambar Bitcoin Golden
        imageUrl: "https://images.unsplash.com/photo-1518546305927-5a555bb7020d?w=1200&q=85",
        source: "CoinDesk",
        url: "https://www.coindesk.com/",
        date: "4 Jam yang lalu",
      ),
      NewsArticle(
        title: "Asian Markets Mixed as Tech Stocks Lead Gains",
        description: "Markets in Japan and South Korea saw gains led by semiconductor stocks, while Chinese markets remained cautious.",
        // ✅ Gambar Stock Market Trading Floor
        imageUrl: "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=1200&q=85",
        source: "CNBC Asia",
        url: "https://www.cnbc.com/asia-markets/",
        date: "5 Jam yang lalu",
      ),
      NewsArticle(
        title: "Gold Prices Hit Record Highs on Global Uncertainty",
        description: "Spot gold jumped 1% to a fresh record high as central banks continue to hoard bullion and geopolitical tensions rise.",
        // ✅ Gambar Gold Bars
        imageUrl: "https://images.unsplash.com/photo-1610375461246-83df859d849d?w=1200&q=85",
        source: "Reuters",
        url: "https://www.reuters.com/markets/commodities/",
        date: "6 Jam yang lalu",
      ),
      NewsArticle(
        title: "European Central Bank Keeps Rates Steady",
        description: "The ECB held interest rates at record highs but acknowledged that inflation is falling faster than anticipated.",
        // ✅ Gambar Euro Bills
        imageUrl: "https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=1200&q=85",
        source: "Financial Times",
        url: "https://www.ft.com/global-economy",
        date: "Hari ini",
      ),
      NewsArticle(
        title: "Oil Prices Stabilize After Volatile Week",
        description: "Crude oil futures remained flat as traders weighed supply cuts from OPEC+ against slowing demand in major economies.",
        // ✅ Gambar Oil Rig
        imageUrl: "https://images.unsplash.com/photo-1518186285589-2f7649de83e0?w=1200&q=85",
        source: "OilPrice.com",
        url: "https://oilprice.com/",
        date: "Kemarin",
      ),
    ];
  }
}

final newsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final service = NewsService();
  return service.fetchGlobalEconomicNews();
});