require('dotenv').config();
const { startGroup, getInput, setSecret, endGroup, setFailed } = require('@actions/core');
const { context, GitHub } = require('@actions/github');
const { readdirSync, existsSync, statSync, readFileSync } = require('fs');
const { normalize, extname, isAbsolute, resolve, basename } = require('path');
const { retry } = require('@octokit/plugin-retry');
const { throttling } = require('@octokit/plugin-throttling');

(async () => {
  try {
    startGroup('Updating release assets...');

    const token = getInput('token', { required: true });
    setSecret(token);

    const github = new GitHub(token, { retry, throttling });
    const ref = process.env.GITHUB_REF;

    let release = getInput('release');
    if (!release) {
      release = ref
        .replace(/refs\//, '')
        .replace(/heads\//, '')
        .replace(/tags\//, '')
        .replace(/\//g, '-');
    }

    const tag = getInput('tag');
    if (!tag) {
      throw new Error('Tag was empty!');
    }

    const releaseAssetsPath = getInput('path', { required: true });
    const releaseAssets = readdirSync(normalize(releaseAssetsPath))
      .filter(file => extname(file).toLowerCase().includes('pbo'))
      .map(file =>
        isAbsolute(file) ? normalize(file) : normalize(resolve(releaseAssetsPath, file))
      )
      .filter(file => existsSync(file));

    const body = getInput('body');
    if (!body) {
      throw new Error('Body was empty!');
    }

    startGroup('Getting list of repositories...');
    const allReleases = await github.repos.listReleases({ ...context.repo });
    const repos = allReleases.data;
    endGroup();

    startGroup('Getting assets for the release...');
    const repo = repos.find(repo => repo.name === release);
    if (!repo.id || repo.id < 0) {
      throw new Error('Existing release could not be found!');
    }
    const existingAssets = (await github.repos.listAssetsForRelease({ ...context.repo, release_id: repo.id })).data;
    endGroup();

    for (const existingAsset of existingAssets) {
      if (releaseAssets.map(file => basename(file)).includes(existingAsset.name)) {
        startGroup('Deleting existing asset: ' + existingAsset.id + '...');
        await github.repos.deleteReleaseAsset({ ...context.repo, asset_id: existingAsset.id });
        endGroup();
      }
    }

    const contentType = 'application/octet-stream';
    for (const releaseAsset of releaseAssets) {
      const contentLength = statSync(releaseAsset).size;
      const headers = { 'content-type': contentType, 'content-length': contentLength };
      startGroup('Uploading release asset: ' + basename(releaseAsset) + '...');
      await github.repos.uploadReleaseAsset({
        url: repo.upload_url,
        headers,
        name: basename(releaseAsset),
        file: readFileSync(releaseAsset),
      });
      endGroup();
    }

    endGroup();
  } catch (err) {
    const error = `An error occured while updating release assets: \n${JSON.stringify(err, null, 2)}`;
    console.error(error);
    setFailed(error);
    process.exit(2);
  }
})();
