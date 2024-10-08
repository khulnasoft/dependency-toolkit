# Contributing

[fork]: https://github.com/khulnasoft/dependency-toolkit/fork
[pr]: https://github.com/khulnasoft/dependency-toolkit/compare
[code-of-conduct]: CODE_OF_CONDUCT.md

Hi there! We're thrilled that you'd like to contribute to this project. Your help is essential for keeping it great.

Contributions to this project are
[released](https://help.github.com/articles/github-terms-of-service/#6-contributions-under-repository-license)
to the public under the [project's open source license](LICENSE).

Please note that this project is released with a [Contributor Code of
Conduct][code-of-conduct]. By participating in this project you agree
to abide by its terms.

## Bug reports and other issues

If you've encountered a problem, please let us know by [submitting an issue](https://github.com/khulnasoft/dependency-toolkit/issues/new)!

## Enhancements and feature requests

If you've got an idea for a new feature or a significant change to the code or its dependencies, please submit as [an issue](https://github.com/khulnasoft/dependency-toolkit/issues/new) so that the community can see it, and we can discuss it there. We may not be able to respond to every single issue, but will make a best effort!

If you'd like to make a contribution yourself, we ask that before significant effort is put into code changes, that we have agreement that the change aligns with our strategy. Since this is a repository owned and primarily maintained by GitHub, we want to make sure that contributions are high quality, and that they maintain consistency with the rest of it's behavior.

1. Create an [issue discussing the idea](https://github.com/khulnasoft/dependency-toolkit/issues/new), so that we can discuss it there.
2. If we agree to incorporate the idea into the project, please write-up a high level summary of the approach that you plan to take so we can review

### Bootstrapping the project

```
git clone https://github.com/khulnasoft/dependency-toolkit.git
cd dependency-submission
npm install
```

### Running the tests

```
npm run test
```

## Submitting a pull request

0. [Fork][fork] and clone the repository
1. Configure and install the dependencies: `npm install`
2. Make sure the tests pass on your machine: `npm run test`
3. Create a new branch: `git checkout -b my-branch-name`
4. Make your change, add tests, and make sure the tests still pass
5. Make sure to build and package before pushing: `npm run all`
6. Push to your fork and [submit a pull request][pr]
7. Pat your self on the back and wait for your pull request to be reviewed and merged.

Here are a few things you can do that will increase the likelihood of your pull request being accepted:

- Write tests.
- Keep your change as focused as possible. If there are multiple changes you would like to make that are not dependent upon each other, consider submitting them as separate pull requests.
- Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

## Cutting a new release

1. Update the version number in [package.json](https://github.com/khulnasoft/dependency-toolkit/blob/main/package.json).
1. Go to [Draft a new
   release](https://github.com/khulnasoft/dependency-toolkit/releases/new)
   in the Releases page.
1. Make sure that the `Publish this Action to the GitHub Marketplace`
   checkbox is enabled
1. Click "Choose a tag" and then "Create new tag", where the tag name
   will be your version prefixed by a `v` (e.g. `v1.2.3`).
1. Use a version number for the release title (e.g. "v1.2.3").
1. Add your release notes. If this is a major version make sure to
   include a small description of the biggest changes in the new version.
1. Click "Publish Release".

## Resources

- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [Using Pull Requests](https://help.github.com/articles/about-pull-requests/)
- [GitHub Help](https://help.github.com)
