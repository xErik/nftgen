```dart
final sep = Platform.pathSeparator;
final assets = Directory('assets');

final layersDir = Directory('${assets.path}${sep}layers');
final imagesDir = Directory('${assets.path}${sep}images');
final metaDir = Directory('${assets.path}${sep}meta');

final csvNft = File('${assets.path}${sep}rarity_nft.csv');
final csvLayers = File('${assets.path}${sep}rarity_layers.csv');

// Write config JSON based on layers directory.

final Map<String, dynamic> config = Config.generate(layersDir, factor: 3);
final configFile = File('${assets.path}${sep}config_generated.json');
Io.writeJson(configFile, config);

// Generate NFTs based on config JSON.

Nft.generate(configFile, layersDir, imagesDir, metaDir);

// Analyze generated NFT metadata and save it

final nftAnalysis = Rarity.nfts(metaDir);
final layersAnalysis = Rarity.layers(metaDir);
Io.save(nftAnalysis, csvNft);
Io.save(layersAnalysis, csvLayers);

// Update metadata json with CID code given in config.
// Adjust cidCode in config before running this command.

Config.updateCidMetadata(configFile, metaDir);
```