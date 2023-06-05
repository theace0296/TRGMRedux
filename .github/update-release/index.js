// @ts-check
require('dotenv').config();
const { startGroup, getInput, setSecret, endGroup, setFailed } = require('@actions/core');
const { context, GitHub } = require('@actions/github');
const { readdirSync, existsSync, statSync, readFileSync } = require('fs');
const { normalize, extname, isAbsolute, resolve, basename } = require('path');
const { retry } = require('@octokit/plugin-retry');
const { throttling } = require('@octokit/plugin-throttling');

const run = async () => {
  try {
    startGroup('Updating release assets...');

    const token = getInput('token', { required: true });
    setSecret(token);

    const github = new GitHub(token, { retry, throttling });
    const ref = process.env.GITHUB_REF;

    let releaseName = getInput('release');
    if (!releaseName && ref) {
      releaseName = ref
        .replace(/refs\//, '')
        .replace(/heads\//, '')
        .replace(/tags\//, '')
        .replace(/\//g, '-');
    }

    const tag = getInput('tag');
    if (!tag) {
      throw new Error('Tag was empty!');
    }

    const prerelease = getInput('prerelease') !== 'false';
    if (!prerelease) {
      throw new Error('Prerelease was not set!');
    }

    const releaseAssetsPath = getInput('path', { required: true });
    const releaseAssets = readdirSync(normalize(releaseAssetsPath))
      .filter(file => extname(file).toLowerCase().includes('pbo') || extname(file).toLowerCase().includes('zip'))
      .map(file =>
        isAbsolute(file) ? normalize(file) : normalize(resolve(releaseAssetsPath, file))
      )
      .filter(file => existsSync(file));

    let body = getInput('body');
    if (!body) {
      throw new Error('Body was empty!');
    }

    startGroup('Getting list of repositories...');
    const releases = (await github.repos.listReleases({ ...context.repo })).data;
    endGroup();

    startGroup('Getting existing release id...');
    const release = releases.find(rel => rel.name === releaseName);
    if (!release || release.id < 0) {
      throw new Error('Existing release could not be found!');
    }
    endGroup();

    startGroup('Release info:');
    console.log(JSON.stringify({
      release,
      body,
      releaseAssets,
      releaseAssetsPath,
      prerelease,
      tag,
      releaseName,
    }, null, 2));
    endGroup();

    let newAssetsExistAlready = true;
    while (newAssetsExistAlready) {
      const releaseAssetNames = releaseAssets.map(file => basename(file));
      const existingAssets = (await github.repos.listAssetsForRelease({ ...context.repo, release_id: release.id })).data;
      if (existingAssets.find(existingAsset => releaseAssetNames.includes(existingAsset.name))) {
        for (const existingAsset of existingAssets) {
          if (releaseAssetNames.includes(existingAsset.name)) {
            startGroup('Deleting existing asset: ' + existingAsset.name + '...');
            try {
              await github.repos.deleteReleaseAsset({ ...context.repo, asset_id: existingAsset.id });
            } catch (error) {
              console.warn(`Unexpected error occured during asset deletion: ${error}`);
            }
            endGroup();
          }
        }
      } else {
        newAssetsExistAlready = false;
      }
    }

    if (body.includes('Change log:')) {
      startGroup('Adding commit messages to body...');
      body = body.substr(0, body.indexOf('Change log:') + 11);
      const commits = (await github.repos.listCommits({ ...context.repo })).data;
      const prevRelease = releases.find(rel => Date.parse(rel.created_at) < Date.parse(release.created_at));
      const prevReleaseDate = Date.parse(prevRelease && prevRelease.created_at ? prevRelease.created_at : '');
      for (const commit of commits) {
        const date = Date.parse(commit.commit.author.date);
        if (date > prevReleaseDate) {
          const commitMessage = commit.commit.message.includes('[') || commit.commit.message.includes('#') ? commit.commit.message : `[${commit.commit.message}](${commit.html_url})`;
          body = `${body}\n* ${commitMessage.includes('\n') ? commitMessage.substr(0, commitMessage.indexOf('\n')) : commitMessage}`;
        }
      }
      await github.repos.updateRelease({
        ...context.repo,
        release_id: release.id,
        tag_name: tag,
        name: releaseName,
        body: body,
        draft: true,
        prerelease: prerelease
      });
      endGroup();
    }

    const contentType = 'application/octet-stream';
    for (const releaseAsset of releaseAssets) {
      const contentLength = statSync(releaseAsset).size;
      const headers = { 'content-type': contentType, 'content-length': contentLength };
      startGroup('Uploading release asset: ' + basename(releaseAsset) + '...');
      await github.repos.uploadReleaseAsset({
        url: release.upload_url,
        headers,
        name: basename(releaseAsset),
        data: readFileSync(releaseAsset),
      });
      endGroup();
    }

    endGroup();
  } catch (error) {
    console.error('An error occured while updating release assets:');
    console.error(error.name);
    console.error(error.message);
    console.error(error.stack);
    setFailed(error);
    process.exit(2);
  }
};

run();
