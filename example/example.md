```dart
final sep = Platform.pathSeparator;
final project = Directory('project');

final layersDir = Directory('${project.path}${sep}layers');
final imagesDir = Directory('${project.path}${sep}images');
final metaDir = Directory('${project.path}${sep}meta');

final csvNft = File('${project.path}${sep}rarity_nft.csv');
final csvLayers = File('${project.path}${sep}rarity_layers.csv');

// Write config JSON based on layers directory.

final Map<String, dynamic> config = Config.generate(layersDir, factor: 3);
final configFile = File('${project.path}${sep}config_generated.json');
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