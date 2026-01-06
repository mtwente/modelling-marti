# modelling-marti

This repository contains a quantitative text analysis of publications by Hans Marti. The data in this repository is openly available to everyone and is intended to support reproducible research.

[![GitHub issues](https://img.shields.io/github/issues/mtwente/modelling-marti.svg)](https://github.com/mtwente/modelling-marti/issues)
[![GitHub stars](https://img.shields.io/github/stars/mtwente/modelling-marti.svg)](https://github.com/mtwente/modelling-marti/stargazers)
[![Code license](https://img.shields.io/badge/Code-AGPL--3.0-orange)](LICENSE-AGPL.md)
[![Data license](https://img.shields.io/badge/Data-CC_BY--SA_4.0-green)](LICENSE-CCBY.md)
[![DOI](https://zenodo.org/badge/931628871.svg)](https://zenodo.org/badge/latestdoi/931628871)
[![Zotero](https://img.shields.io/badge/Zotero-Hans_Marti-bb393c?logo=zotero)](https://www.zotero.org/groups/5722431/hansmarti-publications)

<!-- [![GitHub forks](https://img.shields.io/github/forks/mtwente/modelling-marti.svg)](https://github.com/mtwente/modelling-marti/network) -->

## Repository Structure

The structure of this repository follows the [Advanced Structure for Data Analysis](https://book.the-turing-way.org/project-design/pd-overview/project-repo/project-repo-advanced/) of _The Turing Way_ and is organized as follows:

- `assets/`: images, fonts, bibliography etc.
- `build/`: built corpus file
- `data/`: article data and geodata
- `docs/`: article metadata, biography timeline, list of works by Marti
- `report/`: report on the data set and analysis
- `src/`: source code for the data (e.g., scripts used to collect or process the data)

## Data Description

For this project, a corpus of journal/newspaper articles is used to carry out a quantitative analysis of publications by Hans Marti. R Scripts used in this analysis are available in `src` for reproduction. During the workflow, publications are stored in `data/clean/` as individual `txt` files, and the resulting corpus object is exported to `build/` as `csv` file with corresponding metadata. Refer to the [analysis (in German)](report/index.qmd) for details and consult the [data documentation](docs/data.qmd) for data models and for a summary of data sources. Additionally, a bibliography is available on [Zotero](https://www.zotero.org/groups/5722431/hansmarti-publications/).

## Installation

Install Node.js, Quarto and R. Run the following commands in the root directory of the repository:

```bash
npm install
```

Set up the R environment using renv:

```bash
npm run setup
```

## Use

Scrape all articles specified in `docs/articles_metadata.csv` and store them in `data/` by executing the script sequence in `src/`.

Check that all files are properly formatted.

```bash
npm run check
```

Format all files.

```bash
npm run format
```

Run the wizard to write meaningful commit messages.

```bash
npm run commit
```

Run the wizard to create a CHANGELOG.md.

```bash
npm run changelog
```

Preview the documentation.

```bash
quarto preview
```

These data are openly available to everyone and can be used for any research or educational purpose. If you use this data in your research, please cite as specified in [CITATION.cff](CITATION.cff). Additional metadata formats such as DublinCore or JSON-LD are available via Zenodo either by export from the [record page](https://doi.org/10.5281/zenodo.17956272) or using the [API (REST & OAI-PMH)](https://developers.zenodo.org).<!-- The following citation formats are also available through _Zenodo_: -->

## Support

This project is maintained by [@mtwente](https://github.com/mtwente). Please understand that we can't provide individual support via email. We also believe that help is much more valuable when it's shared publicly, so more people can benefit from it.

| Type                                   | Platforms                                                                    |
| -------------------------------------- | ---------------------------------------------------------------------------- |
| 🚨 **Bug Reports**                     | [GitHub Issue Tracker](https://github.com/mtwente/modelling-marti/issues)    |
| 📊 **Report bad data**                 | [GitHub Issue Tracker](https://github.com/mtwente/modelling-marti/issues)    |
| 📚 **Docs Issue**                      | [GitHub Issue Tracker](https://github.com/mtwente/modelling-marti/issues)    |
| 🎁 **Feature Requests**                | [GitHub Issue Tracker](https://github.com/mtwente/modelling-marti/issues)    |
| 🛡 **Report a security vulnerability** | See [SECURITY.md](SECURITY.md)                                               |
| 💬 **General Questions**               | [GitHub Discussions](https://github.com/mtwente/modelling-marti/discussions) |

## Roadmap

No changes are currently planned.

## Contributing

All contributions to this repository are welcome! If you find errors or problems with the data, or if you want to add new data or features, please open an issue or pull request. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Versioning

We use [SemVer](http://semver.org/) for versioning. The available versions are listed in the [tags on this repository](https://github.com/mtwente/modelling-marti/tags).

## Authors and acknowledgment

- **Moritz Twente** -- [mtwente](https://github.com/mtwente): _Initial work_

See also the list of [contributors](https://github.com/mtwente/modelling-marti/graphs/contributors) who contributed to this project.

## License

The report in this repository is released under the Creative Commons Attribution 4.0 International (CC BY 4.0) License - see the [LICENSE-CCBY](LICENSE-CCBY.md) file for details. By using this data, you agree to give appropriate credit to the original author(s) and to indicate if any modifications have been made. This licensing does not apply to any third-party material included in the repository, particularly the newspaper articles making up the corpus.

The code in this repository is released under the GNU Affero General Public License v3.0 - see the [LICENSE-AGPL](LICENSE-AGPL.md) file for details. By using this code, you agree to make any modifications available under the same license.
