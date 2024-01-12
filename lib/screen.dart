import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int coin = 0;

  late BannerAd _bannerAd;
  bool _isBannerReady = false;

  late InterstitialAd _interstitialAd;
  bool _isInterstitialReady = false;

  late RewardedAd _rewardedAd;
  bool _isRewardedReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(onAdLoaded: (_) {
        setState(() {
          _isBannerReady = true;
        });
      }, onAdFailedToLoad: (ad, err) {
        _isBannerReady = false;
        ad.dispose();
      }),
      request: AdRequest(),
    );
    _bannerAd.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-3940256099942544/1033173712",
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print("Close Interstitial Add");
            },
          );
          setState(() {
            _isInterstitialReady = true;
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          _isInterstitialReady = false;
          _interstitialAd.dispose();
        },
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: "ca-app-pub-3940256099942544/5224354917",
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _isRewardedReady = false;
              });
              _loadRewardedAd();
            },
          );
          setState(() {
            _isRewardedReady = true;
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          _isInterstitialReady = false;
          _interstitialAd.dispose();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admob")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    size: 50,
                  ),
                  Text(
                    coin.toString(),
                    style: TextStyle(fontSize: 50),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _loadInterstitialAd();
                  if (_isInterstitialReady && _isBannerReady) {
                    _interstitialAd.show();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const testing()),
                  );
                },
                child: Text("Interstitial Ads"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _loadRewardedAd();
                  if (_isRewardedReady && _isBannerReady) {
                    _rewardedAd.show(
                      onUserEarnedReward:
                          (AdWithoutView ad, RewardItem reward) {
                        setState(() {
                          coin += 1;
                        });
                      },
                    );
                  }
                },
                child: Text("Rewarded Ads"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isBannerReady = !_isBannerReady;
                  });
                },
                child: Container(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.block), Text("No Ads")],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isBannerReady
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: _bannerAd.size.width.toDouble(),
                        height: _bannerAd.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd),
                      ),
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}

class testing extends StatelessWidget {
  const testing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
