# nftgen

NFT unique image generator and metadata analyzer. Package and CLI enabled.

**TODO DOCS**

During development:

`flutter run --release --dart-entrypoint-args init,-f,.\project\,-l,.\project\layer\,-o`

Generates EXE in bin/

dart .\tool\build.dart

Use in other packages and call its methods:

`lib/cli.dart`


Also: Code fork between Flutter and pure Dart for image generation.

**nftgen EXE**

A [ready-to-use command line EXE](https://github.com/xErik/nftgen/releases) is available. Always do a security check when downloading executables.

**General NFT Procedure** 

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

nftgen init init -f ./project -l ./project/layers -n "Your NFT" -o
nftgen meta -f ./project    
nftgen rarity -f ./project  
nftgen nft -f ./project      
nftgen cid -f ./project -c yourCID  
```

## Windows: Path warning

Paths are not allowed to have trailing, single backslash when giving the path in quotes.

**BAD** 

```
nftgen.dart meta  -f ".\my project\"
```

**GOOD** 

```
nftgen.dart meta  -f ".\my project"
nftgen.dart meta  -f ".\\my project\\"
```

## Configuration

`nftgen init` creates `project.json` in a project directory of your choice. The command requires a layers directory. The project directory may be the parent directory of the layers directory.

Regarding all commands: The OPTIONAL parameter ` -f ./project/` specifies the project directory. If not given, the current directory will be used.


### Probability and Weights

Below is the default configuration of ``nftgen init` regarding layer probabilities `-p` and layer-file weights `-w`.

```
nftgen -f ./project -n "Your NFT Name" -w 2.0 -p 0.5
```

`-p` defines between 0.0 and 1.0 the *rare peak* of the NFT collection as a percentage. How many layers are to be rare in general, regardless of the individual weights assigned to layer-files of a layer. The basic assumption is that the later layers are more rare. The parameter generates probability sequences for layers: `0.05, 0.1, 0.2, 0.4, 1.0, 1.0, 1.0, 1.0`.

`-w` defines the **rare** weight distribution between individual layer-files of a layer. The basic assumption is, that the later layer-files are more common. The parameter generates probability sequences for layer-files: `1, 4, 9, 16, 25, 36`. Its function is `pow(item, factor).round()`.

In other words: `-w` determines the steepness of weights within a layer, `-p` determines the probability of the layers themselves.

It follows, that layer-file-weights and layer-probabilities multiply each other upon generation of NFTs.

Once generated, change the weights and probabilities in `project.json` to your liking.

### project.json

Open `project.json`, re-order the layers, and adjust their weights to your liking:

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
  // 
  // `nftgen init` will cap this at 10.000 for your convenience,
  // as 10.000 NFTs is the max size for most collections. Change
  // it manually, if aiming for more NFTs.
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

## How to Use

### Library

```dart
try {
    final sep = Platform.pathSeparator;
    final String projectDir = 'project';
    final String layerDir = '$projectDir${sep}layer';
    final String name = "NFT Test name";

    await cli.init(projectDir, layerDir, name, true);
    await cli.meta(projectDir);
    await cli.rarity(projectDir);
    await cli.cid(projectDir, "NEW-CID");
    await cli.nft(projectDir);
} on NftCliException catch (e) {
    print(e.message);
}
```

### Command Line

Activate and deactive the shell command: 

```shell
dart pub global activate nftgen
dart pub global deactivate nftgen
```

Commands accept an OPTIONAL parameter specifying the project-directory. Otherwise, the current directory will be used.

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

### General Discussion

https://github.com/xErik/nftgen/discussions

### Issue Tracker

https://github.com/xErik/nftgen/discussions

### Layers 

The example layers are from Hashlips (MIT livense)

https://github.com/HashLips/hashlips_art_engine

### License

MIT