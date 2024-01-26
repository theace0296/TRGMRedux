const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');
const { exec } = require('child_process');

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

const ensuredCopy = async (from, to) => {
  if (!fs.existsSync(from)) {
    throw new Error(`From file/directory does not exist! ${from}`);
  }
  const stat = await fsp.stat(from);
  if (stat.isDirectory()) {
    await fsp.cp(from, to, { recursive: true, force: true });
  } else {
    if (!fs.existsSync(path.dirname(to))) {
      await fsp.mkdir(path.dirname(to), { recursive: true });
    }
    await fsp.copyFile(from, to);
  }
}

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
      await ensuredCopy(path.join(cwd, file), path.join(folderPath, file));
    })
  );
  if (makePbos) {
    const process = exec(`makepbo -P -A -$ -B -X=".bak,.txt" "${folderPath}"`, { cwd: parentFolder });
    await new Promise(resolve => {
      process.on('close', resolve);
    })
    await ensuredCopy(path.join(parentFolder, `${folder}.pbo`), path.join(destinationDir, `${folder}.pbo`));
    await fsp.rm(path.join(parentFolder, `${folder}.pbo`), { force: true });
  }
  // console.log(`-----------------------------------------------------\nMission Folder: ${folder}\n-----------------------------------------------------`);
};


const progress = new class Progress {
  constructor() {
    if (!process.stdout.isTTY) {
      this.width = 100;
    } else {
      this.width = Math.ceil((process.stdout.getWindowSize()[0] + 1) / 2);
    }
  }
  print(current, total, name = '') {
    if (total <= 0) {
      total = 1;
    }
    if (current >= total) {
      current = total;
    }
    const percent = Math.round((current / total) * 100);
    const completeCount = Math.round((current / total) * this.width);
    const barCompleteChar = '\u2588';
    const barIncompleteChar = '\u2591';
    const bar = `${barCompleteChar.repeat(completeCount)}${barIncompleteChar.repeat(this.width - completeCount)}`;
    let string = `| ${bar} ${percent}% | ${current}/${total} |`;
    if (name) {
      string = `${string} ${name} |`
    }

    if (!process.stdout.isTTY) {
      process.stdout.write(`${string}\n`);
    } else {
      process.stdout.cursorTo(0, null);
      process.stdout.write(string);
      process.stdout.clearLine(1);
    }
  }
}

const operations = new Proxy({ total: 0, complete: 0, name: '' }, {
  get(target, property) {
    return Reflect.get(target, property);
  },
  set(target, property, value) {
    const result = Reflect.set(target, property, value);
    if (!result) {
      return false;
    }
    progress.print(target.complete, target.total, target.name);
    return true;
  }
});



(async () => {
  operations.total += additionalFolders.length;
  for (const additionalFolder of additionalFolders) {
    operations.name = additionalFolder;
    await copyTrgmReduxFiles(additionalFolder, folderParentDir);
    operations.complete++;
  }
  for (const secondaryFolder of secondaryFolders) {
    const parentFolder = path.join(folderParentDir, secondaryFolder);
    const missionFolders = await fsp.readdir(parentFolder);
    operations.total += missionFolders.length;
    for (const missionFolder of missionFolders) {
      operations.name = missionFolder;
      if (copyMissionFiles) {
        await copyTrgmReduxFiles(missionFolder, parentFolder);
      }
      if (makeTemplates && secondaryFolder !== 'TRGM-Custom') {
        await ensuredCopy(path.join(parentFolder, missionFolder, 'mission.sqm'), path.join(templateFolder, missionFolder, 'mission.sqm'));
      }
      operations.complete++;
    }
  }
  process.stdout.write('\nDONE\n\n');
})();
