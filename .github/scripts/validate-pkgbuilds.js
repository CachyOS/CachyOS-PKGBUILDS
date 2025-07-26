import { readdirSync } from "node:fs";
import { join } from "node:path";
import { $ } from "bun";

const pkgbuildsDir = join(import.meta.dir, "..", "..");

const pkgbuildFiles = readdirSync(pkgbuildsDir, {
  recursive: true,
  withFileTypes: true,
})
  .filter((x) => x.isFile() && x.name === "PKGBUILD")
  .map((x) => x.parentPath);

const processedPkgbuilds = await Promise.all(
  pkgbuildFiles.map(async (path) => {
    let pkgName = "";

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
        return {
          code: code.join(" "),
          type,
        };
      });
    return {
      details,
      errored: exitCode !== 0,
      pkgName,
    };
  })
).then((res) => res.filter((x) => x && x.details.length > 0));

if (processedPkgbuilds.length > 0) {
  console.log(
    `\n${processedPkgbuilds.length} PKGBUILDs (out of ${pkgbuildFiles.length}) have issues. Summary of issues:\n`
  );

  processedPkgbuilds.forEach((pkg) => {
    console.log(`PKGBUILD: ${pkg.pkgName}`);
    pkg.details.forEach((detail) => {
      console.log(`  [${detail.type}] ${detail.code}`);
    });
    if (pkg.errored) {
      console.log(
        "  [CRITICAL] Additionally, An error occurred while processing this PKGBUILD"
      );
    }
  });

  console.log(
    `\n${processedPkgbuilds.length} PKGBUILDs (out of ${pkgbuildFiles.length}) have issues.`
  );
  process.exit(1);
}
