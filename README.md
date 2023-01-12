# nftgen

NFT unique image generator and metadata analyzer. It can be used as a Dart library or from the command line.

This is work in progress. At the moment, it cannot be used with Flutter Web.

Generate NFTs follows these procedure:

1. Generate config-file based on layers directory
2. Manually: Adjust probabilities in config-file  
3. Generate NFT metadata files
4. Analyse rarity distribution, backtrace to 2.
5. Generate NFT images
6. Manually: Upload NFT images and get a CID
7. Update all metadata files with CID 
8. Manually: Upload metadata files

Which boils down to these commands:

1. nftgen config ...
2. ( ... )
3. nftgen meta ...
4. nftgen rarity ...
5. nftgen nft ...
6. ( ... )
8. nftgen cid ...
9. ( ... )

## Quickstart


Point to existing directory holding layers and the `nftgen` will create a `project.json` in a project directory of your choice.

The command parameter ` -p ./yourProject/` is optional, if not given the current directory will be used.

```shell
dart pub global activate nftgen

nftgen init -p ./yourProject/ - n "NFT Name" -l ./yourLayerDir/ 
nftgen meta -p ./yourProject/    
nftgen rarity -p ./yourProject/  
nftgen nft -p ./yourProject/      
nftgen cid -p ./yourProject/ -c yourCID  
```

**nftgen init**

Running `nftgen init` will generate `./yourProject/project.json`. Open this file, re-order the layers and adjust the layer's weights to your liking:


```JSON
// project.json

{
  // IGNORE THIS SECTION BELOW

  "layerDir": "<Path to your layers>",
  "metaDir": "meta",
  "imageDir": "image",
  "rarityDir": "rarity",
  "rarityNftCsv": "rarity_nft.csv",
  "rarityNftPng": "rarity_nft.png",
  "rarityLayersCsv": "rarity_layers.csv",
  "rarityLayersPng": "rarity_layers.png",

  // IGNORE EVERYTHING ABOVE, EDIT BELOW
  
  "name": "Your NFT name",
  // How many NFTs to generate.
  // Defaults to 0.6 * all-combinations-equal-weights 
  // to avoid rendering slowing down when reaching
  // all-combinations-equal-weights number. 
  "generateNfts": 250, 
  // Run "nftgen cid" to update the metadata files.
  "cidCode": "current CID code", 
  // The order of layer entries matters.
  "layers": [ 
    {
      // Shown in generated metadata JSON.
      "name": "Eyeball",  
      // Your local directory.
      "directory": "Eyeball",
      // Probability: 0.0...1.0 
      // Which euqals: = 0...100% 
      "probability": 1.0, 
      // Sum of all weights is 17
      "weights": {
        // Probability: 1 / 17
        "Red.png": 1, 
        // Probability: 16 / 17
        "White.png": 16 
      }
    },
    
    // ( ... more layers ...)

}
```

Notes

1. The probability of the rare layers can be set to e.g. `0.05, 0.1, 0.25` etc.
2. The larger the NFTs collection, the steeper the weights within each layer have to be. This can be achived setting the exponential factors to `2.0, 3.0, 4.0` etc. Possible numerical sequences are:

```shell
 x*2 1,4,9,16,...
 x^3 1,8,27,64,125,216,343,512
 x^4 1, 16, 81, 256, 625, 1296, 2401, 4096
```

## How to Use

### Library

Please refer to the API for details, some functions have additonal parameters.

```dart
final sep = Platform.pathSeparator;
final project = Directory('project');
// For CONFIG and NFT
final layerDir = Directory('${project.path}${sep}layer');
final imageDir = Directory('${project.path}${sep}image');
final metaDir = Directory('${project.path}${sep}meta');
// To ANALYZE NFT
final csvNft = File('${project.path}${sep}rarity_nft.csv');
final csvLayers = File('${project.path}${sep}rarity_layers.csv');

// Write config JSON based on layers directory

final Map<String, dynamic> config =
    Config.generate('Your NFT', layerDir, factor: 3);
final configFile = File('${project.path}${sep}config_gen.json');
Io.writeJson(configFile, config);

// Generate metadata based on config JSON

Nft.generateMeta(configFile, metaDir);

// Generate NFTs based on config JSON

await Nft.generateNft(configFile, layerDir, imageDir, metaDir);

// Analyze generated NFT metadata and save it

final nftAnalysis = Rarity.nfts(metaDir);
final layersAnalysis = Rarity.layers(metaDir);
Io.writeCsv(nftAnalysis, csvNft);
Io.writeCsv(layersAnalysis, csvLayers);

// Update metadata json with CID code given in config

Config.updateCidMetadata(configFile, metaDir,
    cidSearch: "<-- Your CID Code-->", cidReplace: "NEW-CID");
```

### Command Line

* Activate shell command: `dart pub global activate nftgen`

* Deactivate shell command: `dart pub global deactivate nftgen`

Command line invocations accept an optional parameter specifying the project-directory, without, the current directory will be used:

* Runs in current directory: `nftgen config`

* Runs in `./differentFolder/`: `nftgen config -p differentFolder`

All commands available:

```shell
>dart pub global activate nftgen

> nftgen.dart help  
Generate NFTs

Usage: nftgen <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  cid      Updates CID of generated metadata
  init     Initiates a new project
  meta     Generates NFT metadata
  nft      Generates NFT images based on metadata
  rarity   Generates rarity CSV reports

Run "nftgen help <command>" for more information about a command.
```

## References

The example layers are from Hashlips (MIT livense):

https://github.com/HashLips/hashlips_art_engine

## License

MIT