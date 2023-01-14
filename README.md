# nftgen

NFT unique image generator and metadata analyzer. It can be used as a Dart library or from the command line.

This package is work in progress. At the moment, it cannot be used with Flutter Web as 
browser cannot write to the local file system and thus exporting NFTs is not possible.

Generating NFTs follows this procedure:

1. Generate project-file based on layers directory
2. **Manually**: Adjust probabilities in project-file  
3. Generate NFT metadata files
4. Analyse rarity distribution, backtrace to 2.
5. Generate NFT images
6. **Manually**: Upload NFT images and get a CID
7. Update all metadata files with CID 
8. **Manually**: Upload metadata files

Which translates to these commands:

1. `nftgen init ...`
2. ( ... )
3. `nftgen meta ...`
4. `nftgen rarity ...`
5. `nftgen nft ...`
6. ( ... )
7. `nftgen cid ...`
8. ( ... )

## Quickstart

```shell
dart pub global activate nftgen

nftgen init init -p ./project/ -l ./project/layers/ -n "Your NFT" -o
nftgen meta -p ./project/    
nftgen rarity -p ./project/  
nftgen nft -p ./project/      
nftgen cid -p ./project/ -c yourCID  
```

`nftgen init` creates `project.json` in a project directory of your choice. The command requires a layers directory. The project directory may be the parent directory of the layers directory.

Regarding all commands: The OPTIONAL parameter ` -p ./project/` specifies the project directory. If not given, the current directory will be used.

### project.json

Open `project.json`, re-order the layers and adjust their weights to your liking:

```JSON
// project.json
{
  // IGNORE INTERNAL SECTION BELOW

  "layerDir": "<Path to your layers>",
  "metaDir": "meta",
  "imageDir": "image",
  "rarityDir": "rarity",
  "rarityNftCsv": "rarity_nft.csv",
  "rarityNftPng": "rarity_nft.png",
  "rarityLayersCsv": "rarity_layers.csv",
  "rarityLayersPng": "rarity_layers.png",

  // IGNORE INTERNAL SECTION ABOVE
  
  "name": "Your NFT",
  // How many NFTs to generate.
  // Defaults to 0.6 * all-combinations-equal-weights 
  // to avoid rendering slowing down when reaching
  // all-combinations-equal-weights number. 
  "generateNfts": 250, 
  // Run "nftgen cid -c yourNewCID" to update the metadata files.
  // Do NOT change manually:
  "cidCode": "<-- Your CID code -->", 
  // The order of layer entries matters.
  "layers": [ 
    {
      // Shown in generated metadata JSON.
      "name": "Eyeball",  
      // Your local layer directory.
      "directory": "Eyeball",
      // Probability of layer to be used: 0.0...1.0 
      // Which eqals: 0...100% 
      "probability": 1.0, 
      // Probability of files to be used.
      // Here, sum of all weights is 17.
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

**Probability**

1. Change the steepness of a layer's `weights` sequence with the `-w` parameter: `nftgen init -p ./project/ -w 3.0`. The larger the NFT collection, the steeper the weights within each layer have to be. Set `-w` to `3.0, 4.0, 5.0, ...`. 

2. Set the `probability` of rare layers in `project.json` manually to `0.05, 0.1, 0.25` etc.

## How to Use

### Library

Please refer to the API for details, some functions have additonal parameters.

```dart
final sep = Platform.pathSeparator;
final String projectDir = 'project';
final String layerDir = '$projectDir${sep}layer';
final String name = "NFT Test name";

await cli.init(projectDir, layerDir, name, true);
await cli.meta(projectDir);
await cli.rarity(projectDir);
await cli.cid(projectDir, "NEW-CID");
await cli.nft(projectDir);
```

### Command Line

Activate and deactive the shell command: 

```shell
dart pub global activate nftgen
dart pub global deactivate nftgen
```

Commands accept an OPTIONAL parameter specifying the project-directory. 
Without it, the current directory will be used.

Try `nftgen.dart help` and `nftgen.dart help <COMMAND>` for further information.

```shell
> dart pub global activate nftgen

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

The example layers are from Hashlips (MIT livense)

https://github.com/HashLips/hashlips_art_engine

## License

MIT