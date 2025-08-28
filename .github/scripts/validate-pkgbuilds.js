import { readdirSync } from "node:fs";
import { join } from "node:path";
import { $ } from "bun";

const mainBranch = "master";
const pkgbuildsDir = join(import.meta.dir, "..", "..");

async function getChangedPkgbuilds() {
  const { stdout } =
    await $`git diff --name-only origin/${process.env.GITHUB_BASE_REF || mainBranch}...HEAD`
      .nothrow()
      .quiet();

  const changedFiles = stdout
    .toString("utf8")
    .trim()
    .split("\n")
    .filter(Boolean);

  const changedPkgbuildDirs = new Set();

  for (const file of changedFiles) {
    const parts = file.split("/");
    for (let i = 0; i < parts.length; i++) {
      const dirPath = parts.slice(0, i + 1).join("/");
      try {
        const pkgbuildPath = join(pkgbuildsDir, dirPath, "PKGBUILD");
        await $`test -f ${pkgbuildPath}`.quiet();
        changedPkgbuildDirs.add(dirPath);
        break;
      } catch {
        // Continue searching parent directories
      }
    }
  }

  return Array.from(changedPkgbuildDirs);
}

async function getAllPkgbuilds() {
  return readdirSync(pkgbuildsDir, {
    recursive: true,
    withFileTypes: true,
  })
    .filter((x) => x.isFile() && x.name === "PKGBUILD")
    .map((x) => x.parentPath);
}

const isPullRequest = process.env.GITHUB_EVENT_NAME === "pull_request";
const isMainBranch = process.env.GITHUB_REF === `refs/heads/${mainBranch}`;
const isPush = process.env.GITHUB_EVENT_NAME === "push";

let pkgbuildFiles;

if (isPullRequest) {
  console.log("PR detected - scanning only changed PKGBUILDs...");
  pkgbuildFiles = await getChangedPkgbuilds();
  console.log(`Found ${pkgbuildFiles.length} changed PKGBUILD(s)`);
} else if (isMainBranch && isPush) {
  console.log("Main branch - scanning all PKGBUILDs...");
  pkgbuildFiles = await getAllPkgbuilds();
} else {
  console.log("Manual trigger - scanning all PKGBUILDs...");
  pkgbuildFiles = await getAllPkgbuilds();
}

if (pkgbuildFiles.length === 0) {
  console.log("No PKGBUILDs to validate.");
  process.exit(0);
}

const processedPkgbuilds = await Promise.all(
  pkgbuildFiles.map(async (path) => {
    let pkgName = "";
    let hasErrors = false;

    const { stdout, exitCode } = await $`namcap -i ${join(path, "PKGBUILD")}`
      .nothrow()
      .quiet();
    const output = stdout.toString("utf8").trim();

    if (!output) {
      return;
    }

    const details = output
      .split("\n")
      .filter((line) => line.trim().startsWith("PKGBUILD ("))
      .map((line) => {
        const [_, detectedPkgName, ...code] = line.split(" ");
        if (!pkgName) {
          pkgName = detectedPkgName.replace(/\(|\)/g, "");
        }
        const type = code.shift().replace(":", "");
        if (type === "E") {
          hasErrors = true;
        }
        return {
          code: code.join(" "),
          type,
        };
      });

    return {
      commandError: exitCode !== 0,
      details,
      hasErrors,
      pkgName,
    };
  }),
).then((res) => res.filter((x) => x && x.details.length > 0));

if (processedPkgbuilds.length > 0) {
  const { length: erroredCount } = processedPkgbuilds.filter(
    (x) => x.hasErrors || x.commandError,
  );

  console.log(
    `\n${processedPkgbuilds.length} PKGBUILDs out of ${pkgbuildFiles.length} have issues and ${erroredCount} have errors. Summary of issues:\n`,
  );

  processedPkgbuilds
    .sort((a, b) => a.pkgName.localeCompare(b.pkgName))
    .forEach((pkg) => {
      console.log(`PKGBUILD: ${pkg.pkgName}`);
      pkg.details
        .sort(
          (a, b) =>
            a.type.localeCompare(b.type) || a.code.localeCompare(b.code),
        )
        .forEach((detail) => {
          console.log(`  [${detail.type}] ${detail.code}`);
        });
      if (pkg.commandError) {
        console.log(
          "  [CRITICAL] Additionally, An error occurred while processing this PKGBUILD",
        );
      }
    });

  console.log(
    `\n${processedPkgbuilds.length} PKGBUILDs out of ${pkgbuildFiles.length} have issues and ${erroredCount} have errors.`,
  );

  if (erroredCount) {
    process.exit(1);
  }
} else {
  console.log("All PKGBUILDs are valid!");
}
