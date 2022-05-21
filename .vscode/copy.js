const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');
const { execSync } = require('child_process');

const cwd = process.cwd();
const unwantedFoldersAndFiles = ['mission.sqm', '.vscode', '.github', '.git', '.gitignore', 'Mission-Templates', 'Pbo-Tools', 'Tools'];
const additionalFolders = ['TRGM2-refactoringEmpty.Malden', 'TRGM2-refactoring.Malden'];
const secondaryFolders = ['TRGM-Empty', 'TRGM-Filled', 'TRGM-Custom'];
const templateFolder = path.join(cwd, 'Mission-Templates');
const filesToCopy = fs.readdirSync(cwd).filter(file => !unwantedFoldersAndFiles.includes(file));

const folderParentDir = process.argv[2];
const destinationDir = process.argv[3];
const copyMissionFiles = process.argv[4] === 'true';
const makeTemplates = process.argv[5] === 'true';
const makePbos = process.argv[6] === 'true';

console.log({
  folderParentDir,
  destinationDir,
  copyMissionFiles,
  makeTemplates,
  makePbos,
});

if (!folderParentDir || !fs.existsSync(folderParentDir)) {
  throw new Error('Parent dir not provided or does not exist!');
}

const copyTrgmReduxFiles = async (folder, parentFolder) => {
  const folderPath = path.join(parentFolder, folder);
  if (!fs.existsSync(folderPath)) {
    console.warn(`'${folder}' does not exist!`);
    return;
  }
  await Promise.all(
    (await fsp.readdir(folderPath)).filter(file => file !== 'mission.sqm').map(async file => await fsp.rm(path.join(folderPath, file), { recursive: true, force: true }))
  );
  await Promise.all(
    filesToCopy.map(async file => {
      if (fs.lstatSync(path.join(cwd, file)).isDirectory()) {
        await fsp.cp(path.join(cwd, file), path.join(folderPath, file), { recursive: true, force: true });
      } else {
        await fsp.copyFile(path.join(cwd, file), path.join(folderPath, file));
      }
    })
  );
  if (makePbos) {
    execSync(`makepbo -P -A -$ -B -X=".bak,.txt" "${folderPath}"`, { cwd: parentFolder });
    await fsp.copyFile(path.join(parentFolder, `${folder}.pbo`), path.join(destinationDir, `${folder}.pbo`));
    await fsp.rm(path.join(parentFolder, `${folder}.pbo`), { force: true });
  }
  console.log(`-----------------------------------------------------\nMission Folder: ${folder}\n-----------------------------------------------------`);
};

(async () => {
  await Promise.all(additionalFolders.map(additionalFolder => copyTrgmReduxFiles(additionalFolder, folderParentDir)));
  for (const secondaryFolder of secondaryFolders) {
    await Promise.all(
      fs.readdirSync(path.join(folderParentDir, secondaryFolder)).map(async missionFolder => {
        const parentFolder = path.join(folderParentDir, secondaryFolder);
        if (copyMissionFiles) {
          await copyTrgmReduxFiles(missionFolder, parentFolder);
        }
        if (makeTemplates && secondaryFolder !== 'TRGM-Custom') {
          await fsp.copyFile(path.join(parentFolder, missionFolder, 'mission.sqm'), path.join(templateFolder, missionFolder, 'mission.sqm'));
        }
      })
    );
  }
})();
