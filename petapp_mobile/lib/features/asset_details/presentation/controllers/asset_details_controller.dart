import 'package:flutter/foundation.dart';
import 'package:petrimonium/features/asset_details/data/repositories/asset_details_repository.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_data_status.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/user_position.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';

/// Manages loading and state for the Asset Details screen.
///
/// Follows the same pattern as [PortfolioController]: receives an existing
/// [Holding] for instant cached display, then enriches from the backend.
/// This means the screen opens immediately with user-known data, and
/// progressively enhances with real market data.
class AssetDetailsController extends ChangeNotifier {
  AssetDetailsController({
    required AssetDetailsRepository repository,
  }) : _repository = repository;

  final AssetDetailsRepository _repository;

  bool isLoading = true;
  String? error;
  AssetDetails? assetDetails;

  /// Loads asset details for the given ticker. If a [holding] is provided
  /// (user already owns the asset), it's used to show position data
  /// immediately while the enriched data loads from the backend.
  Future<void> loadAssetDetails(String ticker, {Holding? holding}) async {
    isLoading = true;
    error = null;

    // If we have a holding, create an immediate preview from it
    if (holding != null && assetDetails == null) {
      assetDetails = _previewFromHolding(ticker, holding);
      notifyListeners();
    }

    try {
      final details = await _repository.fetchAssetDetails(ticker);
      assetDetails = details;
    } catch (e) {
      error = e.toString();
      // Keep the preview if we had one — better than showing nothing
    }

    isLoading = false;
    notifyListeners();
  }

  /// Refreshes the asset details from the backend.
  Future<void> refresh() async {
    if (assetDetails == null) return;
    await loadAssetDetails(assetDetails!.ticker);
  }

  /// Creates a minimal AssetDetails from an existing Holding so the
  /// screen can display immediately without waiting for the backend.
  AssetDetails _previewFromHolding(String ticker, Holding holding) {
    return AssetDetails(
      ticker: ticker,
      assetType: _typeFromEnum(holding.type),
      currentPrice: holding.currentPrice,
      currency: 'BRL',
      userPosition: UserPosition(
        quantity: holding.quantity,
        averagePrice: holding.averagePrice,
        investedValue: holding.investedValue,
        currentValue: holding.currentValue,
        unrealizedGain: holding.gainValue,
        unrealizedGainPercent: holding.gainPercent,
        portfolioWeight: holding.portfolioPercent,
      ),
      dataStatus: AssetDataStatus.cached,
    );
  }

  String _typeFromEnum(dynamic type) {
    final name = type.toString().split('.').last;
    switch (name) {
      case 'REAL_ESTATE':
        return 'fii';
      case 'FUNDS':
        return 'etf';
      case 'CRYPTO':
        return 'crypto';
      default:
        return 'stock';
    }
  }
}
