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
    if (!releaseName) {
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
      .filter(file => extname(file).toLowerCase().includes('pbo'))
      .map(file =>
        isAbsolute(file) ? normalize(file) : normalize(resolve(releaseAssetsPath, file))
      )
      .filter(file => existsSync(file));

    let body = getInput('body');
    if (!body) {
      throw new Error('Body was empty!');
    }

    startGroup('Getting list of repositories...');
    const allReleases = await github.repos.listReleases({ ...context.repo });
    const releases = allReleases.data;
    endGroup();

    startGroup('Getting assets for the release...');
    const release = releases.find(rel => rel.name === releaseName);
    if (!release.id || release.id < 0) {
      throw new Error('Existing release could not be found!');
    }
    const existingAssets = (await github.repos.listAssetsForRelease({ ...context.repo, release_id: release.id })).data;
    endGroup();

    for (const existingAsset of existingAssets) {
      if (releaseAssets.map(file => basename(file)).includes(existingAsset.name)) {
        startGroup('Deleting existing asset: ' + existingAsset.id + '...');
        await github.repos.deleteReleaseAsset({ ...context.repo, asset_id: existingAsset.id });
        endGroup();
      }
    }

    if (body.includes('Change log:')) {
      startGroup('Adding commit messages to body...');
      body = body.substr(0, body.indexOf('Change log:') + 11);
      const allCommits = await github.repos.listCommits({ ...context.repo });
      const commits = allCommits.data;
      const prevRelease = releases.find(rel => Date.parse(rel.created_at) < Date.parse(release.created_at));
      const prevReleaseDate = Date.parse(prevRelease.created_at);
      for (const commit of commits) {
        const date = Date.parse(commit.commit.author.date);
        if (date > prevReleaseDate) {
          const commitMessage = commit.commit.message.includes('This reverts commit') ? commit.commit.message.substr(0, commit.commit.message.indexOf('This reverts commit')) : commit.commit.message;
          body = `${body}\n* [${commitMessage}](${commit.commit.url})`;
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
        file: readFileSync(releaseAsset),
      });
      endGroup();
    }

    endGroup();
  } catch (error) {
    console.error('An error occured while updating release assets:');
    console.error(error);
    setFailed(error);
    process.exit(2);
  }
};

run();
